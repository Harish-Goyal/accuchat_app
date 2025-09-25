import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/models/company_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invite_member_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invite_member_with_role_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_dialogue.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_flashbar.dart';

class InviteMembersScreen extends GetView<InviteMemberController> {
  const InviteMembersScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InviteMemberController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 25,
            title: Text(
              "Invite Members",
              style: BalooStyles.balooboldTitleTextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              if (!kIsWeb)
                TextButton(
                  onPressed: () =>
                      controller.pickContactsAndSendInvites(context),
                  child: Text(
                    "Custom",
                    style: BalooStyles.balooregularTextStyle(
                        color: appColorYellow),
                  ),
                ).paddingOnly(left: 12),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return kIsWeb ?Center(
                  child: Column(
                    children: [
                      Text(
                        (controller.companyName ?? '').toUpperCase(),
                        style: BalooStyles.baloosemiBoldTextStyle(
                            color: appColorGreen),
                      ),

                      vGap(30),

                      TextButton(
                        onPressed: () =>
                            controller.pickContactsAndSendInvites(context),
                        child: Text(
                          "Custom",
                          style: BalooStyles.balooregularTextStyle(
                              color: appColorYellow),
                        ),
                      ).paddingOnly(left: 12),
                    ],
                  ),
                ):SingleChildScrollView(
                  child: controller.isLoading
                      ? const SizedBox(height: 300, child: IndicatorLoading())
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (controller.companyName ?? '').toUpperCase(),
                                  style: BalooStyles.baloosemiBoldTextStyle(
                                      color: appColorGreen),
                                ),
                                CustomTextField(
                                  prefix: const Icon(Icons.search_rounded),
                                  onChangee: (v) {
                                    controller.onSearchChanged(v);
                                    controller.update();
                                  },
                                ),
                                if (kIsWeb)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: Column(
                                      children: List.generate(
                                          controller.controllers.length, (i) {
                                        final c = controller.controllers[i];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 10),
                                          child: CustomTextField(
                                            controller: c,
                                            labletext:
                                                "Email or Phone ${i + 1}",
                                            hintText:
                                                "Enter email address or Phone",
                                            prefix: const Icon(
                                                Icons.person_add_alt),
                                            inputFormatters: controller.showCountryCode[i]
                                                ? <TextInputFormatter>[
                                              FilteringTextInputFormatter.digitsOnly,
                                              LengthLimitingTextInputFormatter(10),
                                            ]
                                                : <TextInputFormatter>[],
                                            validator:
                                                controller.validateEmailOrPhone,
                                          ),
                                        );
                                      }),
                                    ),
                                  )
                                else if (controller.filteredContacts.isEmpty)
                                  const Center(
                                      child: Text(!kIsWeb
                                          ? 'No contacts found'
                                          : "Download mobile app to Invite Phone's Contacts"))
                                else
                                  SizedBox(
                                    height: Get.height * .63,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount:
                                          controller.filteredContacts.length,
                                      itemBuilder: (_, index) {
                                        final contact =
                                            controller.filteredContacts[index];
                                        final phone = contact.phones.isNotEmpty
                                            ? controller.normalizePhone(
                                                contact.phones.first.number)
                                            : '';
                                        final email = contact.emails.isNotEmpty
                                            ? contact.emails.first.address
                                                .toLowerCase()
                                            : '';
                                        final identifier =
                                            phone.isNotEmpty ? phone : email;

                                        final isInvited = controller
                                            .invitedContacts
                                            .contains(identifier);
                                        final isSelected = controller
                                            .selectedContacts
                                            .contains(contact);
                                        final isInvitedOrMember = controller
                                            .disabledContactIdentifiers
                                            .contains(identifier);

                                        if (phone.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return CheckboxListTile(
                                          title: Text(
                                            contact.displayName ?? 'No Name',
                                            style: BalooStyles
                                                .baloosemiBoldTextStyle(
                                              color: isInvitedOrMember
                                                  ? Colors.grey.shade300
                                                  : null,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                              Text(
                                                phone,
                                                style: BalooStyles
                                                    .balooregularTextStyle(
                                                  color: isInvitedOrMember
                                                      ? Colors.grey.shade300
                                                      : null,
                                                ),
                                              ),
                                              if (isInvitedOrMember)
                                                Text(
                                                  '  - Invited',
                                                  style: BalooStyles
                                                      .balooregularTextStyle(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          value: isSelected,
                                          checkColor: Colors.white,
                                          activeColor: appColorYellow,
                                          onChanged: isInvitedOrMember
                                              ? null
                                              : (selected) {
                                                  final phone =
                                                      contact.phones.isNotEmpty
                                                          ? controller
                                                              .normalizePhone(
                                                                  contact
                                                                      .phones
                                                                      .first
                                                                      .number)
                                                          : '';
                                                  if (selected == true) {
                                                    controller.selectedContacts
                                                        .add(contact);
                                                    controller
                                                        .selectedInvitesContacts
                                                        .add(phone);
                                                    controller.selectedUser.add(
                                                        InviteUser(
                                                            name: contact
                                                                .displayName,
                                                            mobile: phone,
                                                            isSelected: true));
                                                  } else {
                                                    controller.selectedContacts
                                                        .remove(contact);
                                                    controller
                                                        .selectedInvitesContacts
                                                        .remove(phone);
                                                    controller.selectedUser
                                                        .remove(InviteUser(
                                                            name: contact
                                                                .displayName,
                                                            mobile: phone,
                                                            isSelected: true));
                                                  }
                                                  controller.update();
                                                },
                                        );
                                      },
                                    ),
                                  ),
                                vGap(20),
                                Row(
                                  children: [
                                    Expanded(
                                        child: GradientButton(
                                      name: "Next",
                                      gradient: controller.selectedUser.isEmpty?const LinearGradient(colors: [Colors.grey,Colors.grey,]):buttonGradient,
                                      onTap: controller.selectedUser.isEmpty
                                          ? () {

                                      }
                                          : () async {
                                              Get.toNamed(
                                                  AppRoutes.invite_user_role,
                                                  arguments: {
                                                    'selectedUser':
                                                        controller.selectedUser,
                                                    'contactList':controller.selectedInvitesContacts.toSet().toList(),
                                                    'companyId':controller.companyId,
                                                  });
                                              /* if (controller.selectedInvitesContacts
                                        .isEmpty &&
                                        controller.controllers.every((c) =>
                                        c
                                            .text
                                            .trim()
                                            .isEmpty)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(content: Text(
                                            "No contacts selected")),
                                      );
                                      return;
                                    }

                                    customLoader.show();
                                    if (kIsWeb) {
                                      controller
                                          .sendInvites();
                                    } else {
                                      controller.hitAPIToSendInvites();
                                    }*/
                                            },
                                    )),
                                    if (kIsWeb)
                                      IconButton(
                                        onPressed: () {
                                          if (controller.controllers.length <
                                              15) {
                                            controller.controllers
                                                .add(TextEditingController());
                                            controller.update();
                                          }
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                  ],
                                ),
                                vGap(10),
                                dynamicButton(
                                  name: "Skip",
                                  color: Colors.black,
                                  onTap: () => Get.offAllNamed(AppRoutes.home),
                                  isShowText: true,
                                  isShowIconText: false,
                                  leanIcon: null,
                                ),
                              ],
                            ),
                          ),
                        ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<InviteMemberController>(
//       builder: (controller) {
//         return Scaffold(
//           appBar: AppBar(
//             // automaticallyImplyLeading: false,
//             leadingWidth: 25,
//             title: Text(
//               "Invite Members",
//               style: BalooStyles.balooboldTitleTextStyle(),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => controller.pickContactsAndSendInvites(context),
//                 child: Text(
//                   "Custom",
//                   style: BalooStyles.balooregularTextStyle(color: appColorYellow),
//                 ),
//               ).paddingOnly(left: 12),
//             ],
//           ),
//           body: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: SingleChildScrollView(
//                 child: controller.isLoading
//                     ? SizedBox(height: 300, child: IndicatorLoading())
//                     :  Column(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           controller.company.companyName ?? '',
//                           style: BalooStyles.baloosemiBoldTextStyle(
//                               color: appColorGreen),
//                         ),
//                         CustomTextField(
//                           prefix: Icon(Icons.search_rounded),
//                           onChangee: (v) {
//                             controller.onSearchChanged(v);
//                             controller.update();
//                           },
//                         ),
//                         controller.filteredContacts.isEmpty
//                             ? Center(child: Text('No contacts found'))
//                             : SizedBox(
//                           height: Get.height * .63,
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             itemCount:  controller.filteredContacts.length,
//                             itemBuilder: (_, index) {
//                             *//*   final contact = _filteredContacts[index];
//                                     final phone = contact.phones.isNotEmpty ==
//                                             true
//                                         ? contact.phones.first.number.replaceAll(
//                                                 RegExp(r'\s+|-'), '') ??
//                                             ''
//                                         : '';
// *//*
//                               final contact =  controller.filteredContacts[index];
//
//                               final phone = contact.phones.isNotEmpty
//                                   ?  controller.normalizePhone(
//                                   contact.phones.first.number)
//                                   : '';
//                               final email = contact.emails.isNotEmpty
//                                   ? contact.emails.first.address
//                                   .toLowerCase()
//                                   : '';
//                               final identifier =
//                               phone.isNotEmpty ? phone : email;
//
//                               final isInvited =
//                               controller.invitedContacts.contains(identifier);
//                               final isSelected =
//                               controller.selectedContacts.contains(contact);
//
//                               final isInvitedOrMember =
//                               controller.disabledContactIdentifiers
//                                   .contains(identifier);
//
//                               if (phone.isEmpty)
//                                 return const SizedBox.shrink();
//
//                               // final isSelected = selectedPhones.contains(phone);
//                               // final isSelecteddd =
//                               // _selectedContacts.contains(contact);
//
//                               return CheckboxListTile(
//                                 title: Text(
//                                   contact.displayName ?? 'No Name',
//                                   style:
//                                   BalooStyles.baloosemiBoldTextStyle(
//                                     color: isInvitedOrMember
//                                         ? Colors.grey.shade300
//                                         : null,
//                                   ),
//                                 ),
//                                 subtitle: Row(
//                                   children: [
//                                     Text(
//                                       phone,
//                                       style: BalooStyles
//                                           .balooregularTextStyle(
//                                         color: isInvitedOrMember
//                                             ? Colors.grey.shade300
//                                             : null,
//                                       ),
//                                     ),
//                                     isInvitedOrMember
//                                         ? Text(
//                                       '  - Invited',
//                                       style: BalooStyles
//                                           .balooregularTextStyle(
//                                           color: Colors
//                                               .grey.shade300),
//                                     )
//                                         : SizedBox()
//                                   ],
//                                 ),
//                                 value: isSelected,
//                                 checkColor: Colors.white,
//                                 activeColor: appColorYellow,
//                                 onChanged: isInvitedOrMember
//                                     ? null
//                                     : (selected) {
//                                   final phone = contact.phones.isNotEmpty
//                                       ?  controller.normalizePhone(
//                                       contact.phones.first.number)
//                                       : '';
//                                     if (selected == true) {
//                                       controller.selectedContacts
//                                           .add(contact);
//                                       controller.selectedInvitesContacts.add(phone);
//                                       print(controller.selectedInvitesContacts);
//                                     } else {
//                                       controller.selectedContacts
//                                           .remove(contact);
//                                       controller.selectedInvitesContacts.remove(phone);
//                                       print(controller.selectedInvitesContacts);
//                                     }
//                                     controller.update();
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                     *//*Expanded(
//                       child: ListView.builder(
//                         itemCount: _controllers.length,
//                         itemBuilder: (context, index) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 12.0),
//                             child: CustomTextField(
//                               controller: _controllers[index],
//                               labletext: "Email or Phone ${index + 1}",
//                               hintText: "Enter email address or Phone",
//                               prefix: const Icon(Icons.person_add_alt),
//                               validator: validateEmailOrPhone,
//                             ),
//                           );
//                         },
//                       ),
//
//                       Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _addField,
//                             icon: const Icon(Icons.add),
//                             label: const Text("Add More"),
//                           ),
//                         ),
//                         hGap(20),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: _sendInvites,
//                             icon: const Icon(Icons.send),
//                             label: const Text("Send Invites"),
//                           ),
//                         ),
//                         /*Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed:()=> pickContactsAndSendInvites(context),
//                             icon: const Icon(Icons.send),
//                             label: const Text("Invites Contacts"),
//                           ),
//                         ),*//*
//                       ],
//                     ).paddingSymmetric(vertical: 10,horizontal: 8),
//                     ),*//*
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.send),
//                       label: const Text("Send Invites"),
//                       onPressed: () async {
//                         if ( controller.selectedInvitesContacts.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("No contacts selected")),
//                           );
//                           return;
//                         }
//
//                         customLoader.show();
//
//                         *//*for (Contact phone in  controller.selectedContacts) {
//                           await  controller.sendInvitationUsingPhone(phone);
//                         }*//*
//                         controller.hitAPIToSendInvites();
//
//                         *//* Get.snackbar('Invitations Sent',
//                                 'All valid invitations have been sent',
//                                 backgroundColor: appColorGreen,
//                                 duration: Duration(seconds: 5),
//                                 colorText: Colors.white);*//*
//                       },
//                     ),
//                     vGap(5),
//                     dynamicButton(
//                         name: "Skip",
//                         // gradient: buttonGradient,
//                         color: Colors.black,
//                         onTap: () => Get.offAllNamed(AppRoutes.home),
//                         isShowText: true,
//                         isShowIconText: false,
//                         leanIcon: null)
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }
//     );
//   }
