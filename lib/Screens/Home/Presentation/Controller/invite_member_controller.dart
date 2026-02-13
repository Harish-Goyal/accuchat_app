import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/invite_member_with_role_controller.dart';
import 'package:AccuChat/utils/text_style.dart';
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
import '../../../Chat/screens/auth/models/pending_invites_res_model.dart';
import '../../Models/all_member_res_model.dart';
import '../View/invite_user_with_role.dart';

/// Simple in-memory cache for this session
class InvitesCache {
  static final Set<String> invited =
      <String>{}; // stores 10-digit numbers/emails (lowercase)
}

class InviteMemberController extends GetxController {



  // ---- args / state ----
  var invitedBy;
  var companyName;
  var companyId;

  bool isLoading = true;

  // manual entry
  late List<TextEditingController> controllers;
  final List<FocusNode> focusNodes = [];
  List<bool> showCountryCode = []; // just to reuse your validators/UI toggle

  // contacts (fetched)
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  Set<Contact> selectedContacts =
      {}; // UI selection (includes disabled ones to show checked)
  List<String> selectedInvitesContacts =
      []; // to send to API (10-digit numbers)
  List<InviteUser> selectedUser = [];

  // DISABLED (already invited / members)
  final Set<String> disabledContactIdentifiers =
      <String>{}; // 10-digit numbers or lowercase emails

  // search
  String searchQuery = '';

  // helpers
  final emailRegEx = RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$');
  final phoneRegEx = RegExp(r'^\d+$');

  // ---- lifecycle ----
  @override
  void onInit() {
    getArguments();
    _init();
    super.onInit();
  }

  _init(){
    Future.delayed(Duration(milliseconds: 500),(){
      hitAPIToGetAllMember();
      initController();

      if (!kIsWeb) {
        initPhoneData();
      } else {
        isLoading = false;
        update();
      }
    });
  }

  void getArguments() {
    if (kIsWeb) {
      if(Get.parameters!=null) {
        companyId = Get.parameters['companyId'];
        invitedBy = Get.parameters['invitedBy'];
        companyName = Get.parameters['companyName'];
      }
    } else {
      if (Get.arguments != null) {
        companyName = Get.arguments['companyName'];
        invitedBy = Get.arguments['invitedBy'];
        companyId = Get.arguments['companyId'];
      }
    }
  }

  List<AllMemberData> allInvitedAndJoinedMemberList = [];
  bool isLoadingMember = false;
  hitAPIToGetAllMember() async {
    isLoadingMember = true;
    update();
    Get.find<PostApiServiceImpl>()
        .getAllMembersApiCall(comid: companyId)
        .then((value) async {
      allInvitedAndJoinedMemberList = value.data ?? [];
      isLoadingMember = false;
      _absorbInvitedFromAPI();
      update();
    }).onError((error, stackTrace) {
      isLoadingMember = false;
      update();
    });
  }

  void initController() {
    controllers = [TextEditingController()];
    showCountryCode = List.generate(controllers.length, (_) => false);
    focusNodes.add(_makeFocusNode(0));
  }

  FocusNode _makeFocusNode(int i) {
    final fn = FocusNode();
    fn.addListener(() {
      if (!fn.hasFocus) _commitInput(i);
    });
    return fn;
  }

  // ---- manual input handlers ----
  void _addField(StateSetter setState) {
    if (controllers.length >= 15) {
      toast('You can invite maximum 15 members at once');
      return;
    }
    setState(() {
      controllers.add(TextEditingController());
      showCountryCode.add(false);
      focusNodes.add(_makeFocusNode(controllers.length - 1));
    });
  }

  void onTextChanged(String text,
      {required StateSetter setState, required int i}) {
    final isEmail = emailRegEx.hasMatch(text);
    final isPhone = phoneRegEx.hasMatch(text);
    final wantPhoneMode = isPhone && !isEmail;
    if (wantPhoneMode != showCountryCode[i]) {
      showCountryCode[i] = wantPhoneMode;
      update();
      setState(() {});
    }
  }

  void _commitInput(int i) {
    if (i < 0 || i >= controllers.length) return;
    final raw = controllers[i].text.trim();
    if (raw.isEmpty) return;

    final isPhoneField = showCountryCode[i];
    final emailErr = isPhoneField ? null : raw.isValidEmail();
    final mobileErr = isPhoneField ? raw.validateMobile(raw) : null;
    final isValid = (!isPhoneField && emailErr == null) ||
        (isPhoneField && mobileErr == null);
    if (!isValid) return;

    final normalized = isPhoneField
        ? normalizePhone(raw)
        : raw.toLowerCase(); // phones => 10-digit only
    if (normalized.isEmpty) return;

    if (!selectedInvitesContacts.contains(normalized)) {
      selectedInvitesContacts.add(normalized);
      selectedUser.add(InviteUser(
        name: '',
        mobile: isPhoneField ? normalized : '',
        isSelected: true,
      ));
    }
  }

  // ---- contacts fetch ----
  Future<void> initPhoneData() async {
    try {
      isLoading = true;
      update();

      contacts = await fetchContacts();
      filteredContacts = contacts;

      // very important: pre-select disabled contacts so they render as checked
      _seedDisabledSelection();
    } catch (_) {
      // ignore
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<List<Contact>> fetchContacts() async {
    final permissionStatus = await Permission.contacts.request();
    if (!permissionStatus.isGranted)
      throw Exception("Contact permission not granted");

    await Future.delayed(const Duration(milliseconds: 200));

    final list = await FlutterContacts.getContacts(
      withProperties: true,
      withAccounts: true,
    );
    return list;
  }

  void onSearchChanged(String value) {
    searchQuery = value.toLowerCase();
    filteredContacts = contacts.where((c) {
      final name = (c.displayName ?? '').toLowerCase();
      final firstPhone =
          c.phones.isNotEmpty ? normalizePhone(c.phones.first.number) : '';
      return name.contains(searchQuery) || firstPhone.contains(searchQuery);
    }).toList();
    update();
  }

  void _absorbInvitedFromAPI() {
    if (allInvitedAndJoinedMemberList.isEmpty) return;

    final Set<String> ids = allInvitedAndJoinedMemberList
        .map((m) => _normalizeIdentifierFlexible(m.phone ?? ''))
        .where((s) => s.isNotEmpty)
        .toSet();

    if (ids.isEmpty) return;

    // Keep a cache as well so if user re-enters screen they stay disabled
    InvitesCache.invited.addAll(ids);
    disabledContactIdentifiers.addAll(ids);

    // If contacts are already fetched, mark them selected so tiles show checked
    if (contacts.isNotEmpty) {
      _seedDisabledSelection();
    }

    update();
  }

  // ---- invited/disabled marking ----
  void markAsInvited(Iterable<String> identifiers) {
    final normalized = identifiers
        .map(_normalizeIdentifierFlexible)
        .where((e) => e.isNotEmpty)
        .toSet();
    if (normalized.isEmpty) return;

    // update global cache + local disabled set
    disabledContactIdentifiers.addAll(normalized);

    // ensure UI shows them checked + disabled
    _seedDisabledSelection();

    // remove from pending (so duplicate send nahi hoga)
    selectedInvitesContacts.removeWhere(
        (x) => normalized.contains(_normalizeIdentifierFlexible(x)));
    selectedUser.removeWhere((u) {
      final id = u.mobile?.isNotEmpty == true
          ? normalizePhone(u.mobile!)
          : (u.mobile ?? '').toLowerCase();
      return normalized.contains(id);
    });

    update();
  }

  /// Put all disabled contacts into selectedContacts so Checkbox shows as checked.
  void _seedDisabledSelection() {
    final Set<Contact> keep = {};
    for (final c in contacts) {
      if (_contactMatchesAnyIdentifier(c, disabledContactIdentifiers)) {
        keep.add(c);
      }
    }
    // merge with any current selections (safe)
    selectedContacts = {...selectedContacts, ...keep};
  }

  bool _contactMatchesAnyIdentifier(Contact c, Set<String> ids) {
    final phones = c.phones
        .map((p) => normalizePhone(p.number))
        .where((e) => e.isNotEmpty);
    final emails =
        c.emails.map((e) => e.address.toLowerCase()).where((e) => e.isNotEmpty);
    for (final p in phones) {
      if (ids.contains(p)) return true;
    }
    for (final m in emails) {
      if (ids.contains(m)) return true;
    }
    return false;
  }

  String _normalizeIdentifierFlexible(String raw) {
    final r = raw.trim();
    if (r.isEmpty) return '';
    if (emailRegEx.hasMatch(r)) return r.toLowerCase();
    return normalizePhone(r);
  }

  // ---- navigate to role screen (await result) ----
  Future<void> goToRoleScreen() async {
    final argsContactList = selectedInvitesContacts.toSet().toList();

    if (kIsWeb) {
      // ensure controller exists and init it
      final c = Get.isRegistered<InviteUserRoleController>()
          ? Get.find<InviteUserRoleController>()
          : Get.put(InviteUserRoleController());

      c.initFromArgs(
        usersArg: selectedUser,
        companyIdArg: companyId,
        contactListArg: argsContactList.map((e) => e.toString()).toList(),
      );

      final result = await Get.dialog(
        const Dialog(
          child: SizedBox(
            width: 520,
            child: InviteUserRoleScreen(), // same screen widget
          ),
        ),
        barrierDismissible: false,
      );

      if (result is List && result.isNotEmpty) {
        final list = result.map((e) => e.toString()).toList();
        markAsInvited(list);
      }
      return;
    }

    // mobile: normal route
    final result = await Get.toNamed(
      AppRoutes.invite_user_role,
      arguments: {
        'selectedUser': selectedUser,
        'contactList': argsContactList,
        'companyId': companyId,
      },
    );

    if (result is List && result.isNotEmpty) {
      final list = result.map((e) => e.toString()).toList();
      markAsInvited(list);
    }
  }

/*  Future<void> goToRoleScreen() async {
    // ONLY 10-digit numbers/emails (already normalized) bhej rahe
    final argsContactList = selectedInvitesContacts.toSet().toList();

    if (kIsWeb) {
      InviteUserRoleController c;

      if (Get.isRegistered<InviteUserRoleController>()) {
        c = Get.find<InviteUserRoleController>();
      } else {
        c = Get.put(InviteUserRoleController());
      }

      c.initFromArgs(
        usersArg: selectedUser,
        companyIdArg: companyId,
        contactListArg: argsContactList.map((e) => e.toString()).toList(),
      );

      return;
    }


    final result = await Get.toNamed(
      AppRoutes.invite_user_role,
      arguments: {
        'selectedUser': selectedUser,
        'contactList': argsContactList,
        'companyId': companyId,
      },
    );

    // Expect: List<String> of numbers/emails actually invited by role screen API
    if (result is List && result.isNotEmpty) {
      final list = result.map((e) => e.toString()).toList();
      markAsInvited(list);
    }
  }*/

  // ---- bottom sheet: manual -> Next -> role
  void pickContactsAndSendInvites(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              child: Column(
                children: [
                  vGap(40),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              if (!hasFocus) _commitInput(index);
                            },
                            child: CustomTextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              labletext: "Email or Phone ${index + 1}",
                              hintText: "Enter email address or Phone",
                              textInputType: TextInputType.emailAddress,
                              inputFormatters: showCountryCode[index]
                                  ? <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ]
                                  : <TextInputFormatter>[],
                              validator: (value) => showCountryCode[index]
                                  ? value
                                      ?.validateMobile(controllers[index].text)
                                  : value?.isValidEmail(),
                              prefix: Icon(Icons.person_add_alt,
                                  size: 18, color: appColorGreen),
                              onChangee: (v) => onTextChanged(v, setState: setState, i: index),
                              onFieldSubmitted: (v) {
                                _commitInput(index);
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                          onPressed: () async {
                            for (var i = 0; i < controllers.length; i++) {
                              _commitInput(i);
                            }
                            Navigator.pop(context);
                            await goToRoleScreen(); // await → markAsInvited on return
                          },
                          icon: const Icon(Icons.navigate_next_outlined),
                          label: const Text("Next"),
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 20, vertical: 20),
                ],
              ).marginSymmetric(horizontal: 15,vertical: 15),
            );
          },
        );
      },
    );
  }

  // ---- utilities ----
  /// Return 10-digit (digits-only). If less than 10 digits, returns as-is.
  String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length >= 10) return digits.substring(digits.length - 10);
    return digits;
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
}
