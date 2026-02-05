import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/custom_dialogue.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../models/chat_user.dart';

class BroadcastsMembersScreen extends StatefulWidget {
  final BroadcastChat chat;
  const BroadcastsMembersScreen({super.key, required this.chat});

  @override
  State<BroadcastsMembersScreen> createState() => _BroadcastsMembersScreenState();
}

class _BroadcastsMembersScreenState extends State<BroadcastsMembersScreen> {
  List<ChatUser> _members = [];
  List<String> _adminIds = [];
  String? _currentUid;
  bool isUpdate =false;

  TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groupNameController.text = widget.chat.name??'';
    _fetchGroupMembers();
  }

  Future<void> _fetchGroupMembers() async {
    final doc = await FirebaseFirestore.instance
        .collection('broadcasts')
        .doc(widget.chat.id)
        .get();
    final data = doc.data();

    if (data != null) {
      final memberIds = List<String>.from(data['members'] ?? []);
      _adminIds = List<String>.from(data['admins'] ?? []);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', whereIn: memberIds)
          .get();

      final users =
      snapshot.docs.map((e) => ChatUser.fromJson(e.data())).toList();
      setState(() => _members = users);
    }
  }

  Future<void> _makeAdmin(String uid) async {
    await FirebaseFirestore.instance
        .collection('broadcasts')
        .doc(widget.chat.id)
        .update({
      'admins': FieldValue.arrayUnion([uid])
    });
    _fetchGroupMembers();
  }

  Future<void> _removeMember(String uid) async {
    final ref =
    FirebaseFirestore.instance.collection('broadcasts').doc(widget.chat.id);
    await ref.update({
      'members': FieldValue.arrayRemove([uid]),
      'admins': FieldValue.arrayRemove([uid]),
    });
    _fetchGroupMembers();
  }

  Future<void> _updateGroupName() async {
    try {
      await FirebaseFirestore.instance
          .collection('broadcasts')
          .doc(widget.chat.id)
          .update({'name': _groupNameController.text.trim()});
      toast('Broadcasts name updated!');
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {
        isUpdate = false;
      });
    } catch (e) {
      toast('Failed to update name: $e',
      );
    }
  }


  Future<void> _deleteGroup() async {
    try {
      await FirebaseFirestore.instance.collection('broadcasts').doc(widget.chat.id).delete();
      toast('Group deleted successfully')
      ;
      Get.back();
      Get.back();
    } catch (e) {
      toast('Error deleting group: $e')
      ;

    }
  }


  @override
  Widget build(BuildContext context) {
    final isCurrentUserAdmin = _adminIds.contains(_currentUid);

    ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(      scrolledUnderElevation: 0,
        surfaceTintColor: Colors.white,title:  Text('Broadcasts Members',style: BalooStyles.balooboldTitleTextStyle(),),
        actions: [
          // if (isCurrentUserAdmin)
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                if (value == 'delete') _deleteGroup();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,color: AppTheme.redErrorColor,),
                      hGap(5),
                      const Text('Delete Broadcasts'),
                    ],
                  ),
                ),
              ],
            )
        ],),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage(broadcastIcon), // static image
          ),


          CustomTextField(
            hintText: "Broadcasts Name",
            labletext: "",
            // readOnly: !isCurrentUserAdmin?true:false ,
            controller: _groupNameController,
            onChangee:/*!isCurrentUserAdmin?(v){}: */(v){
              setState(() {
                isUpdate = true;
              });
            },

            validator: (value) {
              return value?.isEmptyField(messageTitle:"Broadcasts Name" );
            },
            prefix: Icon(Icons.group,color: appColorPerple,),

          ).marginSymmetric(horizontal: 20,vertical: 20),
          if (isUpdate)
            dynamicButton(
                name: "Update",
                onTap:_groupNameController.text.isNotEmpty? _updateGroupName:(){
                  toast("Broadcasts Name cannot be empty");
                },
                isShowText: true,
                isShowIconText: false,
                gradient: buttonGradient,

                leanIcon: chaticon),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final user = _members[index];
                final isAdmin = _adminIds.contains(user.id);
                final isSelf = user.id == _currentUid;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0,horizontal: 15),
                  leading:
                  SizedBox(
                    width: 55,
                    child: CustomCacheNetworkImage(
                      user.image??'',radiusAll: 100,height: 75,width: 75,defaultImage: userIcon,
                      borderColor: greyColor,),
                  ),
                  title: Row(
                    children: [
                      Text(
                        user.name=='null'||user.name==''||user.name==null?
                        user.phone:user.name,
                        style: themeData.textTheme.bodyMedium,
                      ),
                      if (isAdmin)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: appColorGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('admin',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                      (user.email=='null'||user.email==''||user.email==null && (user.name!='null'||user.name==''||user.name))?
                      user.phone:user.email,
                    style: themeData.textTheme.bodySmall
                        ?.copyWith(color: greyText),
                  ),
                  trailing: /*isCurrentUserAdmin && !isSelf
                      ?*/ PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'make_admin') {
                        _makeAdmin(user.id);
                      } else if (value == 'remove') {
                        _removeMember(user.id);
                      }
                    },
                    itemBuilder: (context) => [
                      // if (!isAdmin)
                       /* PopupMenuItem(
                          value: 'make_admin',
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle_rounded,
                                size: 12,
                                color: appColorGreen,
                              ),
                              hGap(5),
                              Text(
                                'Make Admin',
                                style: themeData.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),*/
                      PopupMenuItem(
                        value: 'remove',
                        child: Row(children: [
                          Icon(
                            Icons.remove_circle,
                            size: 12,
                            color:AppTheme.redErrorColor,
                          ),
                          hGap(5),
                          Text(
                            'Remove Member',
                            style: themeData.textTheme.bodySmall,
                          )
                        ]),
                      ),
                    ],
                    color: Colors.white,
                    icon: const Icon(Icons.more_vert),
                  )
                      // : null,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
