import 'package:AccuChat/Screens/Chat/models/company_model.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/compnaies_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:AccuChat/utils/shares_pref_web.dart';
import 'package:AccuChat/utils/web_file_picekr.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import '../../../../Constants/themes.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../Services/storage_service.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/text_style.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/get_company_res_model.dart';
import 'package:dio/dio.dart' as multi;

import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'company_service.dart';

class UpdateCompanyController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController websiteController;

  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode addressFocus = FocusNode();
  final FocusNode websiteFocus = FocusNode();

  // Placeholder for file picker result
  String? companyLogoUrl;
  String? filecompanyLogoUrl;
  PickedFileData? filecompanyWeb;
  String? lastMessage;
  bool isLoading = false;

  // CompanyModel? company;

  @override
  void onInit() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    websiteController = TextEditingController();
    getArguments();
    _getMe();
    _getCompany();
    super.onInit();
  }

  getArguments() {
    if (kIsWeb) {
      if (Get.parameters != null) {
        final String? comId = Get.parameters['companyId'];
        getCompanyByIdApi(companyId: int.parse(comId ?? ''));
      }
    } else {
      if (Get.arguments != null) {
        companyResponse = Get.arguments['company'];
        initData();
      }
    }
  }

  getCompanyByIdApi({int? companyId}) async {
    Get.find<PostApiServiceImpl>()
        .getCompanyByIdApiCall(companyId)
        .then((value) async {
      companyResponse = value.data!;

      initData();
    }).onError((error, stackTrace) {
      update();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  deleteCompanyApi() async {
    customLoader.show();
    Get.find<PostApiServiceImpl>()
        .deleteCompanyApiCall(compId: companyResponse?.companyId)
        .then((value) async {
      toast(value.message);
      toast("✅ Company and related data deleted successfully.");
      customLoader.hide();
      update();
      Get.offAllNamed(AppRoutes.landing_r);

    }).onError((error, stackTrace) {
      update();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  CompanyData? companyResponse = CompanyData();

  updateCompanyApi({int? companyId}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "company_id": companyId,
      "company_name": nameController.text.trim(),
      "address": addressController.text.trim(),
      "website": websiteController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
    });
    if (filecompanyLogoUrl != '' && filecompanyLogoUrl != null) {
      reqData.files.add(MapEntry(
          "logo",
          await multi.MultipartFile.fromFile(
            filecompanyLogoUrl ?? '',
            filename: (filecompanyLogoUrl ?? '').split('/').last,
            contentType: MediaType("image", "jpeg"),
          )));
    }

    if(kIsWeb){
      if(filecompanyWeb!=null) {
        final mime = lookupMimeType(
            filecompanyWeb!.name, headerBytes: filecompanyWeb!.bytes)
            ?? 'application/octet-stream';

        final mf = await multi.MultipartFile.fromBytes(
          filecompanyWeb!.bytes,
          filename: filecompanyWeb?.name, // <-- use name, not extension
          contentType: MediaType.parse(mime), // <-- safer than hardcoding
        );

        reqData.files.add(MapEntry('logo', mf));
      }
    }
    Get.find<PostApiServiceImpl>()
        .createCompanyAPICall(dataBody: reqData)
        .then((value) async {
      toast(value.message ?? '');
      companyResponse = value.data!;
      final svc = CompanyService.to;
      await svc.select(companyResponse!);
      await APIs.refreshMe(companyId: svc.id!);
      Get.find<ChatHomeController>().getCompany();
      Get.find<CompaniesController>().hitAPIToGetCompanies();
      customLoader.hide();

      update();

      Get.back();


    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  UserDataAPI? me = UserDataAPI();
  _getMe() {
    me = getUser();
    update();
  }

  CompanyData? selCompany;

  _getCompany() {
    final svc = CompanyService.to;
    selCompany = svc.selected;

    update();
  }

  initData() {
    companyLogoUrl = companyResponse?.logo ?? '';
    nameController = TextEditingController(
        text: (companyResponse?.companyName ?? '').toUpperCase());
    emailController = TextEditingController(text: companyResponse?.email ?? '');
    phoneController = TextEditingController(text: companyResponse?.phone ?? '');
    addressController =
        TextEditingController(text: companyResponse?.address ?? '');
    websiteController =
        TextEditingController(text: companyResponse?.website ?? '');
    update();
  }

  Future<bool> doesCollectionExist(String collectionPath) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionPath)
        .limit(1) // We limit the result to one document
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> deleteCompany(BuildContext context) async {

    final ctx = Get.context!;
    final size = MediaQuery.of(ctx).size;

    // Responsive width breakpoints (desktop / tablet / large phone / phone)
    double targetWidth;
    if (size.width >= 1280) {
      targetWidth = size.width * 0.25; // desktop
    } else if (size.width >= 992) {
      targetWidth = size.width * 0.35;
    } else if (size.width >= 768) {
      targetWidth = size.width * 0.5; // tablet
    } else {
      targetWidth = size.width * 0.85; // phones / small windows
    }
    // Keep width within reasonable min/max
    targetWidth = targetWidth.clamp(360.0, 560.0);

    final maxHeight = size.height * 0.90;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: targetWidth,
              maxHeight: maxHeight,
            ),
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  child: AlertDialog(
                    title: const Text("Delete Company"),
                    backgroundColor: Colors.white,
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        vGap(20),
                        Text(
                          "⚠️ Are you sure you want to delete this company?",
                          style: BalooStyles.balooboldTextStyle(
                              color: AppTheme.redErrorColor, size: 16),
                        ),
                        vGap(20),
                        Text(
                          "All related members, invitations, and references will be permanently removed. You cannot retrieve it again in future, make sure before delete!",
                          style: BalooStyles.baloomediumTextStyle(
                              color: AppTheme.redErrorColor),
                        ),
                        vGap(20),
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel")),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Delete")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (confirm != true) return;

    deleteCompanyApi();
  }

}
