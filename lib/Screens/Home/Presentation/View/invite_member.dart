import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/helper/dialogs.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invite_member_controller.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/gradient_button.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_dialogue.dart';
import '../Controller/invite_member_with_role_controller.dart';

class InviteMembersScreen extends GetView<InviteMemberController> {
  const InviteMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InviteMemberController>(
      builder: (c) {
        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.white,
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
                  onPressed: () => c.pickContactsAndSendInvites(context),
                  child: Text("Custom",
                      style: BalooStyles.balooregularTextStyle(
                          color: appColorYellow)),
                ).paddingOnly(left: 12),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return kIsWeb
                      ? Center(
                          child: Column(
                            children: [
                              Text(
                                (c.companyName ?? ''),
                                style: BalooStyles.baloosemiBoldTextStyle(
                                    color: appColorGreen),
                              ),
                              vGap(35),
                              Text(
                                  "Click below custom button to send invite! Contacts are not available at web!",
                                  style: BalooStyles.balooregularTextStyle(size: 13)),
                              vGap(10),
                              TextButton(
                                onPressed: () =>
                                    c.pickContactsAndSendInvites(context),
                                child: Text("Custom",
                                    style: BalooStyles.baloosemiBoldTextStyle(
                                        color: appColorYellow)),
                              ).paddingOnly(left: 12),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: c.isLoading
                              ? const SizedBox(
                                  height: 300, child: IndicatorLoading())
                              : RefreshIndicator(
                                  onRefresh: () => c.initPhoneData(),
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 700),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (c.companyName ?? ''),
                                            style: BalooStyles
                                                .baloosemiBoldTextStyle(
                                                    color: appColorGreen),
                                          ),
                                          CustomTextField(
                                            prefix: const Icon(
                                                Icons.search_rounded),
                                            onChangee: (v) {
                                              c.onSearchChanged(v);
                                              c.update();
                                            },
                                          ),
                                          if (kIsWeb)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                              child: Column(
                                                children: List.generate(
                                                    c.controllers.length, (i) {
                                                  final ctrl = c.controllers[i];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 10),
                                                    child: CustomTextField(
                                                      controller: ctrl,
                                                      labletext:
                                                          "Email or Phone ${i + 1}",
                                                      hintText:
                                                          "Enter email address or Phone",
                                                      prefix: const Icon(
                                                          Icons.person_add_alt),
                                                      inputFormatters: c
                                                              .showCountryCode[i]
                                                          ? <TextInputFormatter>[
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly,
                                                              LengthLimitingTextInputFormatter(
                                                                  10),
                                                            ]
                                                          : <TextInputFormatter>[],
                                                      validator: c
                                                          .validateEmailOrPhone,
                                                    ),
                                                  );
                                                }),
                                              ),
                                            )
                                          else if (c.filteredContacts.isEmpty)
                                            const Center(
                                                child:
                                                    Text("No contacts found"))
                                          else
                                            SizedBox(
                                              height: Get.height * .63,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount:
                                                    c.filteredContacts.length,
                                                itemBuilder: (_, index) {
                                                  final contact =
                                                      c.filteredContacts[index];
                                                  // show first normalized phone (10-digit)
                                                  final firstPhone = contact
                                                          .phones.isNotEmpty
                                                      ? c.normalizePhone(contact
                                                          .phones.first.number)
                                                      : '';

                                                  // true if any phone/email of contact already invited
                                                  final isDisabled =
                                                      _contactIsDisabled(
                                                          contact, c);

                                                  // keep invited ones checked by default (selectedContacts me seed ho chuka hai)
                                                  final isSelected = c
                                                      .selectedContacts
                                                      .contains(contact);

                                                  if (firstPhone.isEmpty) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }

                                                  return CheckboxListTile(
                                                    title: Text(
                                                      contact.displayName,
                                                      style: BalooStyles
                                                          .baloosemiBoldTextStyle(
                                                        color: isDisabled
                                                            ? Colors
                                                                .grey.shade300
                                                            : null,
                                                      ),
                                                    ),
                                                    subtitle: Row(
                                                      children: [
                                                        Text(
                                                          firstPhone,
                                                          style: BalooStyles
                                                              .balooregularTextStyle(
                                                            color: isDisabled
                                                                ? Colors.grey
                                                                    .shade300
                                                                : null,
                                                          ),
                                                        ),
                                                        if (isDisabled)
                                                          Text(
                                                            '  - Invited',
                                                            style: BalooStyles
                                                                .balooregularTextStyle(
                                                              color: Colors.grey
                                                                  .shade300,
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    // invited -> always checked & disabled
                                                    value: isDisabled
                                                        ? true
                                                        : isSelected,
                                                    checkColor: Colors.white,
                                                    activeColor: appColorYellow,
                                                    onChanged: isDisabled
                                                        ? null // cannot unselect invited
                                                        : (val) {
                                                            final phoneNow = contact
                                                                    .phones
                                                                    .isNotEmpty
                                                                ? c.normalizePhone(
                                                                    contact
                                                                        .phones
                                                                        .first
                                                                        .number)
                                                                : '';
                                                            if (val == true) {
                                                              c.selectedContacts
                                                                  .add(contact);
                                                              if (phoneNow
                                                                      .isNotEmpty &&
                                                                  !c.selectedInvitesContacts
                                                                      .contains(
                                                                          phoneNow)) {
                                                                c.selectedInvitesContacts
                                                                    .add(
                                                                        phoneNow);
                                                              }
                                                              c.selectedUser.add(
                                                                  InviteUser(
                                                                name: contact
                                                                    .displayName,
                                                                mobile:
                                                                    phoneNow,
                                                                isSelected:
                                                                    true,
                                                              ));
                                                            } else {
                                                              c.selectedContacts
                                                                  .remove(
                                                                      contact);
                                                              c.selectedInvitesContacts
                                                                  .remove(
                                                                      phoneNow);
                                                              c.selectedUser.removeWhere((u) =>
                                                                  (u.mobile ??
                                                                          '') ==
                                                                      phoneNow &&
                                                                  (u.name ??
                                                                          '') ==
                                                                      (contact.displayName ??
                                                                          ''));
                                                            }
                                                            c.update();
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
                                                  gradient: c
                                                          .selectedUser.isEmpty
                                                      ? const LinearGradient(
                                                          colors: [
                                                              Colors.grey,
                                                              Colors.grey
                                                            ])
                                                      : buttonGradient,
                                                  onTap: c.selectedUser.isEmpty
                                                      ? () {
                                                          Dialogs.showSnackbar(
                                                              context,
                                                              "User is not selected!");
                                                        }
                                                      : () async {
                                                          await c
                                                              .goToRoleScreen();
                                                        },
                                                ),
                                              ),
                                            ],
                                          ),
                                          vGap(10),
                                          dynamicButton(
                                            name: "Skip",
                                            color: Colors.black,
                                            onTap: () =>
                                                Get.offAllNamed(AppRoutes.home),
                                            isShowText: true,
                                            isShowIconText: false,
                                            leanIcon: null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  bool _contactIsDisabled(Contact contact, InviteMemberController c) {
    for (final p in contact.phones) {
      final id = c.normalizePhone(p.number);
      if (id.isNotEmpty && c.disabledContactIdentifiers.contains(id))
        return true;
    }
    for (final e in contact.emails) {
      final id = e.address.toLowerCase();
      if (id.isNotEmpty && c.disabledContactIdentifiers.contains(id))
        return true;
    }
    return false;
  }
}
