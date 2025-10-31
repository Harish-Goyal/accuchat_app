import 'dart:convert';

import 'package:AccuChat/Screens/Chat/api/apis.dart';
import 'package:AccuChat/Screens/Chat/models/get_company_res_model.dart';
import 'package:AccuChat/Services/APIs/post/post_api_service_impl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../../../Services/APIs/local_keys.dart';
import '../../../../../../Services/storage_service.dart';
import '../../../../../../Services/subscription/billing_controller.dart';
import '../../../../../../Services/subscription/billing_service.dart';
import '../../../../../../Services/subscription/payment_method.dart';
import '../../../../../../main.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../utils/custom_flashbar.dart';
import 'package:dio/dio.dart' as multi;

import '../../../../../Home/Presentation/Controller/company_service.dart';

class CreateCompanyController extends GetxController {
  bool isHome = false;
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController websiteController;

  late FocusNode nameFocus;
  late FocusNode emailFocus;
  late FocusNode phoneFocus;
  late FocusNode addressFocus;
  late FocusNode websiteFocus;

  // Placeholder for file picker result
  String? companyLogoUrl;

  bool isLoading = false;




  @override
  void onInit() {
    super.onInit();
    getArguments();

    _initTextField();
  }

  _initTextField() {
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    websiteController = TextEditingController();
    nameFocus = FocusNode();
    emailFocus = FocusNode();
    phoneFocus = FocusNode();
    addressFocus = FocusNode();
    websiteFocus = FocusNode();
  }

  getArguments() {


    if(kIsWeb){
      if (Get.parameters != null) {
      final  _isHomeBool = Get.parameters['isHome'];
      isHome = _isHomeBool=="1"?true:false;
      }
    }else{
      if (Get.arguments != null) {
        isHome = Get.arguments['isHome'];
      }
    }

  }



/*  createCompany(){
    if (formKey.currentState!.validate()) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      customLoader.show();
      APIs.createCompany(
          email:emailController.text.isNotEmpty? emailController.text.trim():"",
          phone:phoneController.text.isNotEmpty?
          "+91${phoneController.text.trim()}":
          APIs.me.phone,
          name: nameController.text.trim(),
          address: addressController.text.trim(),
          logoUrl:companyLogoUrl!=''? File(companyLogoUrl??''):null
      ).then((v){
        storage.write(isLoggedIn, true);
        customLoader.hide();
        toast( "Company created successfully!");
      }).onError((e,v){
        customLoader.hide();
        errorDialog( "Something went wrong!");
      });

    }
  }*/

  CompanyData companyResponse = CompanyData();

  createCompanyApi({String? companyId}) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "company_id": companyId,
      "company_name": nameController.text,
      "address": addressController.text,
      "website": websiteController.text,
      "email": emailController.text.trim(),
      "phone": phoneController.text.trim(),
    });
    if (companyLogoUrl != '' && companyLogoUrl != null ) {
      reqData.files.add(MapEntry(
          "logo",
          await multi.MultipartFile.fromFile(
            companyLogoUrl ?? '',
            filename: (companyLogoUrl ?? '').split('/').last,
            contentType: MediaType("image", "jpeg"),
          )));

    }
    Get.find<PostApiServiceImpl>()
        .createCompanyAPICall(dataBody: reqData)
        .then((value) async {
      companyResponse = value.data!;
      _clearFields();
      customLoader.hide();
      StorageService.setLoggedIn(true);
      toast(value.message??'');
      update();
      StorageService.setCompanyCreated(true);
      final svc = Get.find<CompanyService>();
      await svc.select(companyResponse);

      await APIs.refreshMe(companyId: companyResponse.companyId??0);
      if (isHome) {
        if (kIsWeb) {
          Get.toNamed(AppRoutes.home);
          // Get.offAllNamed('${AppRoutes.invite_member}?companyId=${companyResponse.companyId.toString()}&invitedBy=${companyResponse.createdBy}&companyName=${companyResponse.companyName}');
        } else {
        Get.offAllNamed(AppRoutes.invite_member, arguments: {
          'companyName': companyResponse.companyName,
          'companyId': companyResponse.companyId,
          'invitedBy': companyResponse.createdBy,
        });
      }
      } else {
        if (kIsWeb) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.invite_member, arguments: {
            'companyName': companyResponse.companyName,
            'companyId': companyResponse.companyId,
            'invitedBy': companyResponse.createdBy,
          });
        }
      }


    }).onError((error, stackTrace) {
      update();
      Get.back();
      customLoader.hide();
      errorDialog(error.toString());
    }).whenComplete(() {});
  }

  _clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    websiteController.clear();
    companyLogoUrl = '';
    update();
  }




}





