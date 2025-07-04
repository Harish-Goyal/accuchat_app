import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/models/company_model.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/custom_dialogue.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_flashbar.dart';

class InviteMembersScreen extends StatefulWidget {
  final CompanyModel? company;
  final String invitedBy;

  const InviteMembersScreen({
    Key? key,
    required this.company,
    required this.invitedBy,
  }) : super(key: key);

  @override
  State<InviteMembersScreen> createState() => _InviteMembersScreenState();
}

class _InviteMembersScreenState extends State<InviteMembersScreen> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addField(setState) {
    if (_controllers.length < 15) {
      setState(() {
        _controllers.add(TextEditingController());
      });
    } else {
      toast('You can invite maximum 15 members at once');
    }
  }

  Future<void> _sendInvites() async {
    for (var controller in _controllers) {
      final email = controller.text.trim();
      if (email.isNotEmpty) {
        customLoader.show();
        await APIs.sendInvitation(
                companyId: widget.company?.id ?? '',
                email: email.endsWith(".com") ? email : "+91${email}",
                invitedBy: widget.invitedBy,
                name: '',
                company: widget.company!)
            .then((v) {
          Get.offAllNamed(AppRoutes.home);
          customLoader.hide();
        });
      }
    }
  }

  Future<List<Contact>> fetchContacts() async {
    final permissionGranted = await FlutterContacts.requestPermission();

    if (!permissionGranted) {
      errorDialog("Contact permission not granted");
      throw Exception("Contact permission not granted");

    }

    // ✅ Delay avoids conflict with other permission requests
    await Future.delayed(const Duration(milliseconds: 300));

    return await FlutterContacts.getContacts(
      withProperties: true,
      withAccounts: true,
    );
  }


  List<Map<String, dynamic>> contactItems = [];
  initPreSelectedIDs(contacts) async {
    final invitedList =
        await APIs.getInvitations(widget.company?.id ?? ''); // already done
    final invitedPhonesOrEmails = invitedList
        .map((i) => i.email?.toLowerCase())
        .where((e) => e != null && e.isNotEmpty)
        .toSet();


    contactItems = contacts.map((contact) {
      final phone =
          contact.phones.isNotEmpty ? contact.phones.first.number : '';
      final email =
          contact.emails.isNotEmpty ? contact.emails.first.address : '';

      final identifier = phone.isNotEmpty ? phone : email;
      final alreadyInvited =
          invitedPhonesOrEmails.contains(identifier.toLowerCase());

      return {
        'contact': contact,
        'isInvited': alreadyInvited,
        'isSelected': alreadyInvited, // default select if invited
      };
    }).toList();
  }

  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  Set<Contact> _selectedContacts = {};
  String _searchQuery = '';
  List<String> _invitedContacts = [];
  /* void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
      _filteredContacts = _contacts.where((contact) {
        final fullName = contact.displayName?.toLowerCase() ??
            "${contact.name.first.toLowerCase()} ${contact.name.last.toLowerCase()}";

        final phone = contact.phones.isNotEmpty == true
            ? contact.phones.first.number.replaceAll(RegExp(r'\s+|-'), '') ?? ''
            : '';
        return fullName.contains(_searchQuery) || phone.contains(_searchQuery);
      }).toList();
    });
  }*/

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
      _filteredContacts = _contacts.where((contact) {
        final fullName = contact.displayName?.toLowerCase() ??
            "${contact.name.first.toLowerCase()} ${contact.name.last.toLowerCase()}";
        final phone = contact.phones.isNotEmpty
            ? contact.phones.first.number.replaceAll(RegExp(r'\s+|-'), '')
            : '';
        return fullName.contains(_searchQuery) || phone.contains(_searchQuery);
      }).toList();
    });
  }

  void _toggleSelection(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void pickContactsAndSendInvites(BuildContext context) async {
    try {


      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        builder: (_) {
          return StatefulBuilder(
            builder: (context, setState) {
              /*return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      vGap(30),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              "Select Contacts to Invite",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CustomTextField(
                              prefix: Icon(Icons.search_rounded),
                              onChangee:(v){
                                _onSearchChanged(v);
                                setState((){});

                              } ,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: _filteredContacts.isEmpty
                            ? Center(child: Text('No contacts found'))
                            :ListView.builder(
                          shrinkWrap: true,
                          itemCount:  _filteredContacts.length,
                          itemBuilder: (_, index) {
                            final contact = _filteredContacts[index];
                            final phone = contact.phones.isNotEmpty == true
                                ? contact.phones.first.number.replaceAll(RegExp(r'\s+|-'), '') ?? ''
                                : '';

                            if (phone.isEmpty) return const SizedBox.shrink();

                            // final isSelected = selectedPhones.contains(phone);
                            final isSelecteddd = _selectedContacts.contains(contact);
                            return CheckboxListTile(
                              title: Text(contact.displayName ?? 'No Name',style: BalooStyles.baloosemiBoldTextStyle(),),
                              subtitle: Text(phone,style: BalooStyles.balooregularTextStyle(),),
                              value: isSelecteddd,
                              checkColor: Colors.white,
                              activeColor: appColorYellow,
                              onChanged: (selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedContacts.add(contact);
                                  } else {
                                    _selectedContacts.remove(contact);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text("Send Invites"),
                        onPressed: () async {
                          Navigator.pop(context);
                          if (_selectedContacts.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("No contacts selected")),
                            );
                            return;
                          }

                          customLoader.show();

                          for (Contact phone in _selectedContacts) {
                            await sendInvitationUsingPhone(phone);
                          }
                          Get.offAllNamed(AppRoutes.home);
                          customLoader.hide();
                          Get.snackbar('Invitations Sent', 'All valid invitations have been sent',backgroundColor: appColorGreen,duration: Duration(seconds: 5),colorText: Colors.white);

                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );*/

              return SafeArea(
                child: Column(children: [
                  vGap(40),
                  Expanded(
                      child: ListView.builder(
                    itemCount: _controllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CustomTextField(
                          controller: _controllers[index],
                          labletext: "Email or Phone ${index + 1}",
                          hintText: "Enter email address or Phone",
                          prefix: const Icon(Icons.person_add_alt),
                          validator: validateEmailOrPhone,
                        ),
                      );
                    },
                  )),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _addField(setState),
                          icon: const Icon(Icons.add),
                          label: const Text("Add More"),
                        ),
                      ),
                      hGap(20),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sendInvites,
                          icon: const Icon(Icons.send),
                          label: const Text("Send Invites"),
                        ),
                      ),
                    ],
                  )
                ]).paddingSymmetric(vertical: 40, horizontal: 20),
              );
            },
          );
        },
      );
    } catch (e) {
      print("❌ Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch contacts")),
      );
    }
  }

  Set<String> _disabledContactIdentifiers = {};

  Future<void> fetchAllContactsAndStatus(String companyId) async {
    // initPhoneData();
    // 1. Get all invitations
    final invited = await APIs.getInvitations(companyId);
    final invitedIds = invited.map((i) {
      final phone = normalizePhone(i.email ?? '');
      return phone.isNotEmpty ? phone : i.email.toLowerCase() ?? '';
    });

    // 2. Get all current company members
    final memberSnapshot = await FirebaseFirestore.instance
        .collection('companies')
        .doc(companyId)
        .get();

    final memberIds =
        List<String>.from(memberSnapshot.data()?['members'] ?? []);

    final memberDocs = await FirebaseFirestore.instance
        .collection('users')
        .where('id', whereIn: memberIds)
        .get();

    final memberIdentifiers = memberDocs.docs.map((doc) {
      final data = doc.data();
      final phone = normalizePhone(data['phone'] ?? '');
      final email = data['email']?.toLowerCase() ?? '';
      return phone.isNotEmpty ? phone : email;
    });

    // 3. Combine all disabled identifiers
    _disabledContactIdentifiers = {
      ...invitedIds.whereType<String>(),
      ...memberIdentifiers.whereType<String>(),
    }.where((e) => e.isNotEmpty).toSet();
    // 4. Fetch contacts
    _contacts = await fetchContacts();
    setState(() {
      isLosing = false;
    });
    // 5. Preselect all disabled contacts
    for (var contact in _contacts) {
      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number.replaceAll(RegExp(r'\s+|-'), '')
          : '';
      final email = contact.emails.isNotEmpty
          ? contact.emails.first.address.toLowerCase()
          : '';
      final identifier = phone.isNotEmpty ? phone : email;

      if (_disabledContactIdentifiers.contains(identifier)) {
        _selectedContacts.add(contact);
      }
    }

    _filteredContacts = _contacts;
    setState(() {});
  }

  /*Future<void> fetchInvitedContacts() async {
    // Assuming you have companyId from the selected company
    final companyId = APIs.me.selectedCompany?.id ?? '';

    final invitedContacts = await APIs.getInvitedContacts(companyId);

    setState(() {
      _invitedContacts = invitedContacts;
      _selectedContacts = {
        for (var contact in _filteredContacts)
          contact.phones.first.number: _invitedContacts.contains(contact.phones.first.number);
      };
    });
  }*/

  Future<void> sendInvitationUsingPhone(Contact phoneNumber) async {
    try {
      final fullName = phoneNumber.displayName?.toLowerCase() ??
          "${phoneNumber.name.first.toLowerCase()} ${phoneNumber.name.last.toLowerCase()}";
      final phone = phoneNumber.phones.isNotEmpty == true
          ? phoneNumber.phones.first.number.replaceAll(RegExp(r'\s+|-'), '') ??
              ''
          : '';
      if (phone.trim().isEmpty) {
        errorDialog("Phone number is empty");
        return;
      }
      // Format phone number (you may add more logic here if needed)
      final cleanedPhone = phone.replaceAll(RegExp(r'\s+|-'), '');
      final formattedPhone = cleanedPhone.startsWith("+")
          ? cleanedPhone
          : "+91$cleanedPhone"; // Defaulting to Indian format if not provided

      // Check for existing pending invite
      final existingInvites = await FirebaseFirestore.instance
          .collection('invitations')
          .where('companyId', isEqualTo: widget.company?.id ?? '')
          .where('email', isEqualTo: formattedPhone)
          .where('isAccepted', isEqualTo: false)
          .get();

      if (existingInvites.docs.isNotEmpty) {
        customLoader.hide();
        errorDialog("❗ This member is already invited.");
        return;
      }

      // Send invite using your shared function
      await APIs.sendInvitation(
          companyId: widget.company?.id ?? '',
          email: formattedPhone,
          invitedBy: widget.invitedBy,
          company: widget.company!,
          name: fullName ?? '');
    } catch (e) {
      print('❌ Error sending phone invite: $e');
      errorDialog("Something went wrong while sending invite.");
    }
  }

  String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email or phone number';
    }

    final trimmed = value.trim();

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    final phoneRegex =
        RegExp(r'^\d{10}$'); // You can change for international if needed

    if (!emailRegex.hasMatch(trimmed) && !phoneRegex.hasMatch(trimmed)) {
      return 'Enter a valid email or 10-digit phone number';
    }

    return null;
  }

  initPhoneData() async {
    try {
      _contacts = await fetchContacts();
      _filteredContacts = _contacts;
      setState(() {
        isLosing = false;
      });

    } catch (e) {
      setState(() {
        isLosing = false;
      });
    }
  }

  @override
  void initState() {

    // initPhoneData();
    fetchAllContactsAndStatus(widget.company?.id ?? '');

    super.initState();
  }

  String normalizePhone(String phone) {
    // Remove all non-digit characters
    phone = phone.replaceAll(RegExp(r'\D'), '');

    // Keep only last 10 digits (assuming Indian format)
    if (phone.length > 10) {
      phone = phone.substring(phone.length - 10);
    }

    return phone;
  }

  bool isLosing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        leadingWidth: 25,
        title: Text(
          "Invite Members",
          style: BalooStyles.balooboldTitleTextStyle(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => pickContactsAndSendInvites(context),
            child: Text(
              "Invite Manual",
              style: BalooStyles.balooregularTextStyle(color: appColorYellow),
            ),
          ).paddingOnly(left: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child:isLosing
                ? SizedBox(height: 300, child: IndicatorLoading())
                :  Column(
              children: [
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.company?.name ?? '',
                      style: BalooStyles.baloosemiBoldTextStyle(
                          color: appColorGreen),
                    ),
                    CustomTextField(
                      prefix: Icon(Icons.search_rounded),
                      onChangee: (v) {
                        _onSearchChanged(v);
                        setState(() {});
                      },
                    ),
                    _filteredContacts.isEmpty
                            ? Center(child: Text('No contacts found'))
                            : SizedBox(
                                height: Get.height * .63,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filteredContacts.length,
                                  itemBuilder: (_, index) {
                                    /* final contact = _filteredContacts[index];
                                final phone = contact.phones.isNotEmpty ==
                                        true
                                    ? contact.phones.first.number.replaceAll(
                                            RegExp(r'\s+|-'), '') ??
                                        ''
                                    : '';*/

                                    final contact = _filteredContacts[index];

                                    final phone = contact.phones.isNotEmpty
                                        ? normalizePhone(
                                            contact.phones.first.number)
                                        : '';
                                    final email = contact.emails.isNotEmpty
                                        ? contact.emails.first.address
                                            .toLowerCase()
                                        : '';
                                    final identifier =
                                        phone.isNotEmpty ? phone : email;

                                    final isInvited =
                                        _invitedContacts.contains(identifier);
                                    final isSelected =
                                        _selectedContacts.contains(contact);

                                    final isInvitedOrMember =
                                        _disabledContactIdentifiers
                                            .contains(identifier);
                                    print(_disabledContactIdentifiers);

                                    if (phone.isEmpty)
                                      return const SizedBox.shrink();

                                    // final isSelected = selectedPhones.contains(phone);
                                    // final isSelecteddd =
                                    // _selectedContacts.contains(contact);

                                    return CheckboxListTile(
                                      title: Text(
                                        contact.displayName ?? 'No Name',
                                        style:
                                            BalooStyles.baloosemiBoldTextStyle(
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
                                          isInvitedOrMember
                                              ? Text(
                                                  '  - Invited',
                                                  style: BalooStyles
                                                      .balooregularTextStyle(
                                                          color: Colors
                                                              .grey.shade300),
                                                )
                                              : SizedBox()
                                        ],
                                      ),
                                      value: isSelected,
                                      checkColor: Colors.white,
                                      activeColor: appColorYellow,
                                      onChanged: isInvitedOrMember
                                          ? null
                                          : (selected) {
                                              setState(() {
                                                if (selected == true) {
                                                  _selectedContacts
                                                      .add(contact);
                                                } else {
                                                  _selectedContacts
                                                      .remove(contact);
                                                }
                                              });
                                            },
                                    );
                                  },
                                ),
                              ),
                  ],
                ),
                /*Expanded(
                  child: ListView.builder(
                    itemCount: _controllers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CustomTextField(
                          controller: _controllers[index],
                          labletext: "Email or Phone ${index + 1}",
                          hintText: "Enter email address or Phone",
                          prefix: const Icon(Icons.person_add_alt),
                          validator: validateEmailOrPhone,
                        ),
                      );
                    },
                  ),

                  Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _addField,
                        icon: const Icon(Icons.add),
                        label: const Text("Add More"),
                      ),
                    ),
                    hGap(20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _sendInvites,
                        icon: const Icon(Icons.send),
                        label: const Text("Send Invites"),
                      ),
                    ),
                    /*Expanded(
                      child: ElevatedButton.icon(
                        onPressed:()=> pickContactsAndSendInvites(context),
                        icon: const Icon(Icons.send),
                        label: const Text("Invites Contacts"),
                      ),
                    ),*/
                  ],
                ).paddingSymmetric(vertical: 10,horizontal: 8),
                ),*/
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Send Invites"),
                  onPressed: () async {
                    Navigator.pop(context);
                    if (_selectedContacts.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No contacts selected")),
                      );
                      return;
                    }

                    customLoader.show();

                    for (Contact phone in _selectedContacts) {
                      await sendInvitationUsingPhone(phone);
                    }
                    Get.offAllNamed(AppRoutes.home);
                    customLoader.hide();
                    /* Get.snackbar('Invitations Sent',
                            'All valid invitations have been sent',
                            backgroundColor: appColorGreen,
                            duration: Duration(seconds: 5),
                            colorText: Colors.white);*/
                  },
                ),
                vGap(5),
                dynamicButton(
                    name: "Skip",
                    // gradient: buttonGradient,
                    color: Colors.black,
                    onTap: () => Get.offAllNamed(AppRoutes.home),
                    isShowText: true,
                    isShowIconText: false,
                    leanIcon: null)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
