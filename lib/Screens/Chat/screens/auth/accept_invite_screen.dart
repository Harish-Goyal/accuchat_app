import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/models/company_model.dart';
import 'package:AccuChat/utils/custom_container.dart';
import 'package:AccuChat/utils/custom_dialogue.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../Services/APIs/local_keys.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../api/apis.dart';
import '../../models/invite_model.dart';

class AcceptInvitationScreen extends StatefulWidget {
  AcceptInvitationScreen({super.key,required this.company,this.inviteId});
  var inviteId;
  CompanyModel company;

  @override
  State<AcceptInvitationScreen> createState() => _AcceptInvitationScreenState();
}

class _AcceptInvitationScreenState extends State<AcceptInvitationScreen> {
  late Future<List<InvitationModel>> _invitesFuture;

  @override
  void initState() {
    super.initState();
    _invitesFuture = _fetchUserInvitations();
  }


/*  Future<List<InvitationModel>> _fetchUserInvitations() async {
    final userEmail = APIs.me.email;
    final userPhone = APIs.me.phone ?? ''; // Add to ChatUser if not already

    final snap = await FirebaseFirestore.instance
        .collection('invitations').where('email',isEqualTo:userEmail ||userPhone )
        .where('isAccepted', isEqualTo: false)
        .where(Filter.or(
          Filter('email', isEqualTo: userEmail),
          Filter('phone', isEqualTo: userPhone),
        ))
        .get();

    return snap.docs.map((doc) => InvitationModel.fromMap(doc.data())).toList();
  }*/


  Future<List<InvitationModel>> _fetchUserInvitations() async {
    final userEmail = APIs.me.email;
    final userPhone = APIs.me.phone ?? '';

    final invitationsRef = FirebaseFirestore.instance.collection('invitations');

    // Run two queries and combine results
    final emailQuery = await invitationsRef
        .where('email', isEqualTo: userEmail)
        .where('isAccepted', isEqualTo: false)
        .get();

    final phoneQuery = await invitationsRef
        .where('email', isEqualTo: userPhone)
        .where('isAccepted', isEqualTo: false)
        .get();

    // Combine both
    final allDocs = [...emailQuery.docs, ...phoneQuery.docs];

    // Remove duplicates if needed
    final uniqueDocs = {
      for (var doc in allDocs) doc.id: doc,
    }.values.toList();

    return uniqueDocs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return InvitationModel.fromMap(data);
    }).toList();
  }




bool isLoading = false;
  Future<void>  _acceptInvite(InvitationModel invite) async {

    try {
      setState(() {
        isLoading =true;
      });
      // customLoader.show();
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.company.id)
          .collection('members')
          .doc(APIs.me.id)
          .set({
        'role': 'member',
        'joinedAt': DateTime.now().millisecondsSinceEpoch.toString()
      });
      final companyRef = FirebaseFirestore.instance.collection('companies').doc(widget.company.id);
      await companyRef.update({
        'members': FieldValue.arrayUnion([APIs.me.id]),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(APIs.me.id)
          .update({
        'company': FieldValue.arrayUnion([widget.company.toJson()]),
        'selectedCompany': widget.company.toJson(),
        'name': invite.name,
      });
      // 4. Delete the invitation
      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(invite.id)
          .delete();

      // Show success message
      toast("🎉 Invitation accepted!");

      // Fetch and update the selected company model
      var cData = await companyRef.get();
      var selectedCompany = CompanyModel.fromJson(cData.data()!);

      // Update the APIs.selectedCompany with the new company data
      APIs.me.selectedCompany = widget.company;

      // Mark the user as logged in
      storage.write(isLoggedIn, true);
      // customLoader.hide();
      setState(() {
        isLoading =false;
      });
      // Navigate to the home screen
      Get.offAllNamed(AppRoutes.home);
      setState(() {
        _invitesFuture = _fetchUserInvitations();
      });
    } catch (e) {
      customLoader.hide();
      setState(() {
        isLoading =true;
      });
      toast("❌ Error accepting invite");
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pending Invitations", style: BalooStyles.balooboldTitleTextStyle())),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          isLoading?Center(

              child: SizedBox(
                height: Get.height*.6,
                  child: IndicatorLoading())):  FutureBuilder<List<InvitationModel>>(
            future: _invitesFuture,
            builder: (context, snapshot) {
              // Check if the connection is done
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(child: IndicatorLoading());
              }

              // Handle error in future
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final invites = snapshot.data ?? [];

              // No invitations
              if (invites.isEmpty) {
                return Center(child: Text("No pending invitations found.",style: BalooStyles.baloosemiBoldTextStyle(),));
              }

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: ListView.builder(
                  itemCount: invites.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    final invite = invites[i];
                    return CustomContainer(
                      color: Colors.white,
                      vPadding: 15,
                      childWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width:50,
                            child:

                          CustomCacheNetworkImage(
                            invite.company?.logoUrl ?? '',
                            height: 50,
                            width: 50,
                            boxFit: BoxFit.cover,
                            radiusAll: 100,
                            borderColor: Colors.black54,
                          )),
                          hGap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Invited via, ",
                                  style: BalooStyles.balooregularTextStyle(),
                                ),
                                vGap(4),
                                Text(
                                  invite.company?.name ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: BalooStyles.baloosemiBoldTextStyle(),
                                ),
                              ],
                            ),
                          ),
                          dynamicButton(
                            btnColor: appColorGreen,
                            onTap: () => _acceptInvite(invite),
                            gradient: buttonGradient,
                            vPad: 8,
                            name: "Accept",
                            isShowText: true,
                            isShowIconText: false,
                            leanIcon: null,
                          ).paddingSymmetric(vertical: 8)
                        ],
                      ),
                    ).paddingSymmetric(horizontal: 15, vertical: 12);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}
