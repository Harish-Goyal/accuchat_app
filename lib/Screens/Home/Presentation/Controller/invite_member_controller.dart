import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invite_member_with_role_controller.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../Constants/colors.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../utils/common_textfield.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/models/get_company_res_model.dart';

class InviteMemberController extends GetxController {
  late List<TextEditingController> controllers;
  bool isLoading = true;

  var invitedBy;
  var companyName;
  var companyId;

  List<InviteUser> selectedUser = [];

  void _addField(setState) {
    if (controllers.length < 15) {
      setState(() {
        controllers.add(TextEditingController());
        showCountryCode.add(false);
        for (var i = 0; i < controllers.length; i++) {
          focusNodes.add(_makeFocusNode(i));
        }
      });
    } else {
      toast('You can invite maximum 15 members at once');
    }
  }

  initController(){
    controllers = [TextEditingController()];
    showCountryCode = List.generate(controllers.length, (v)=>false);
    for (var i = 0; i < controllers.length; i++) {
      focusNodes.add(_makeFocusNode(i));
    }
  }

  FocusNode _makeFocusNode(int i) {
    final fn = FocusNode();
    fn.addListener(() {
      if (!fn.hasFocus) _commitInput(i); // commit on blur
    });
    return fn;
  }


  void _commitInput(int i) {
    if (i < 0 || i >= controllers.length) return;
    final raw = controllers[i].text.trim();
    if (raw.isEmpty) return;

    // decide email vs phone using your existing validators
    final isPhone = showCountryCode[i]; // you already toggle this elsewhere
    final emailErr = isPhone ? null : raw.isValidEmail();               // returns null when valid
    final mobileErr = isPhone ? raw.validateMobile(raw) : null;         // returns null when valid
    final isValid = (emailErr == null && !isPhone) || (mobileErr == null && isPhone);
    if (!isValid) return;

    if (!selectedInvitesContacts.contains(raw)) {
      selectedInvitesContacts.add(raw);
      // if you also want to store email separately, adapt here:
      selectedUser.add(InviteUser(
        name: '',
        mobile: isPhone ? raw : '', // or keep a separate `email` field if your model has it
        isSelected: true,
      ));
    }
  }

  Future<void> sendInvites() async {
    // for (var controller in controllers) {
    if (controllers.first.text.isNotEmpty) {
      customLoader.show();
      Map<String, dynamic> postData = {
        "companyId": companyId,
        "userInput": controllers.map((v) => v.text.trim()).toList()
      };
      Get.find<PostApiServiceImpl>()
          .sendInvitesToJoinCompanyAPI(dataBody: postData)
          .then((value) async {
        toast(value.message);
        Get.offAllNamed(AppRoutes.home);
        customLoader.hide();
        update();
      }).onError((error, stackTrace) {
        update();
      });
    } else {
      toast("Fields cannot be empty!");
    }
    // }
  }

  CompanyResModel companyResModel = CompanyResModel();

  List<String> selectedInvitesContacts = [];

  Future<List<Contact>> fetchContacts() async {
    try {
      final permissionStatus = await Permission.contacts.request();

      if (!permissionStatus.isGranted) {
        throw Exception("Contact permission not granted");
      }

      // Extra delay to give platform time
      await Future.delayed(const Duration(milliseconds: 200));

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withAccounts: true,
      );

      return contacts;
    } catch (e) {
      print("❌ Error while fetching contacts: $e");
      rethrow;
    }
  }

  List<Map<String, dynamic>> contactItems = [];

  initPreSelectedIDs(contacts) async {
    /*   final invitedList =
    await APIs.getInvitations(company.companyId!); // already done
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
    }).toList();*/
  }

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  Set<Contact> selectedContacts = {};
  String searchQuery = '';
  List<String> invitedContacts = [];

  void onSearchChanged(String value) {
    searchQuery = value.toLowerCase();
    filteredContacts = contacts.where((contact) {
      final fullName = contact.displayName?.toLowerCase() ??
          "${contact.name.first.toLowerCase()} ${contact.name.last
              .toLowerCase()}";
      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number.replaceAll(RegExp(r'\s+|-'), '')
          : '';
      return fullName.contains(searchQuery) || phone.contains(searchQuery);
    }).toList();
    update();
  }



  final emailRegEx = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
  final phoneRegEx = RegExp(r'^\d+$'); // “all digits” check
  List<bool> showCountryCode = [];
  void onTextChanged(String text,{setState,i}) {
    final isEmail = emailRegEx.hasMatch(text);
    final isPhone = phoneRegEx.hasMatch(text);
    final wantCountry = isPhone && !isEmail;

    if (wantCountry != showCountryCode[i]) {
      showCountryCode[i] = wantCountry;
      update();
      setState((){});
    }
  }

  final List<FocusNode> focusNodes = [];


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
                        itemCount: controllers.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Focus( // <-- commit on blur
                              onFocusChange: (hasFocus) {
                                if (!hasFocus) _commitInput(index);
                              },
                              child: CustomTextField(
                                controller: controllers[index],
                                focusNode: focusNodes[index],
                                labletext: "Email or Phone ${index + 1}",
                                hintText: "Enter email address or Phone",
                                // prefix: const Icon(Icons.person_add_alt),
                                // validator: validateEmailOrPhone,
                                textInputType: TextInputType.emailAddress,
                                inputFormatters: showCountryCode[index]
                                    ? <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ]
                                    : <TextInputFormatter>[],
                                validator: (value) {
                                  return showCountryCode[index]
                                      ? value?.validateMobile(controllers[index].text)
                                      : value?.isValidEmail();
                                },

                                prefix: !showCountryCode[index]
                                    ? Icon(Icons.email_outlined, size: 18, color: appColorGreen)
                                    : Text("+91",style: BalooStyles.baloomediumTextStyle(),).paddingOnly(left: 15,top: 15),

                                onChangee: (v)=>onTextChanged(v,setState: setState,i: index),
                                onFieldSubmitted: (v){
                                  _commitInput(index);                    // commit on submit
                                  FocusScope.of(context).nextFocus();

                                },
                              ),
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
                          onPressed:(){
                            Get.toNamed(
                                AppRoutes.invite_user_role,
                                arguments: {
                                  'selectedUser':
                                  selectedUser,
                                  'contactList':selectedInvitesContacts.toSet().toList(),
                                  'companyId':companyId,
                                });
                          } ,
                          icon: const Icon(Icons.navigate_next_outlined),
                          label: const Text("Next"),
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

  Set<String> disabledContactIdentifiers = {};

  Future<void> fetchAllContactsAndStatus(int companyId) async {
    // initPhoneData();
    // 1. Get all invitations
    /* final invited = await APIs.getInvitations(companyId);
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
    disabledContactIdentifiers = {
      ...invitedIds.whereType<String>(),
      ...memberIdentifiers.whereType<String>(),
    }.where((e) => e.isNotEmpty).toSet();
    // 4. Fetch contacts
    contacts = await fetchContacts();

      isLosing = false;

      update();

    // 5. Preselect all disabled contacts
    for (var contact in contacts) {
      final phone = contact.phones.isNotEmpty
          ? contact.phones.first.number.replaceAll(RegExp(r'\s+|-'), '')
          : '';
      final email = contact.emails.isNotEmpty
          ? contact.emails.first.address.toLowerCase()
          : '';
      final identifier = phone.isNotEmpty ? phone : email;

      if (disabledContactIdentifiers.contains(identifier)) {
        selectedContacts.add(contact);
      }
    }

   filteredContacts = contacts;
    update();*/
  }

  Future<void> sendInvitationUsingPhone(Contact phoneNumber) async {
    /* try {
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
          .where('companyId', isEqualTo: company?.id ?? '')
          .where('email', isEqualTo: formattedPhone)
          .where('isAccepted', isEqualTo: false)
          .get();

      if (existingInvites.docs.isNotEmpty) {
        customLoader.hide();
        // errorDialog("❗ This member is already invited.");
        return;
      }

      // Send invite using your shared function
      await APIs.sendInvitation(
          companyId: company?.id ?? '',
          email: formattedPhone,
          invitedBy: invitedBy,
          company: company!,
          name: fullName ?? '');
    } catch (e) {
      print('❌ Error sending phone invite: $e');
      errorDialog("Something went wrong while sending invite.");
    }*/
  }

  String? validateEmailOrPhone(String? value) {
    if (value == null || value
        .trim()
        .isEmpty) {
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
      contacts = await fetchContacts();
      filteredContacts = contacts;

      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
    }
  }

  @override
  void onInit() {
    getArguments();
    initController();
    if (!kIsWeb) {
      initPhoneData();
      // fetchAllContactsAndStatus(companyId);
    } else {
      isLoading = false;
      update();
    }
    super.onInit();
  }

  getArguments() {
    if (kIsWeb) {
      companyId = CompanyData(
          companyId: int.tryParse(Get.parameters['companyId'] ?? '0'));
      invitedBy = Get.parameters['invitedBy'];
      companyName = Get.parameters['companyName'];
    } else if (Get.arguments != null) {
      companyName = Get.arguments['companyName'];
      invitedBy = Get.arguments['invitedBy'];
      companyId = Get.arguments['companyId'];
    }
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
}