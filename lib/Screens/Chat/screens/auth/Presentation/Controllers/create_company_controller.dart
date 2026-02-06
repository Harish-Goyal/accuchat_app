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
  Uint8List? companyLogoBytes;
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
        final  _isHomeBool =  Get.arguments['isHome'];
        isHome = _isHomeBool=="1"?true:false;
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

  Future<void> createCompanyApi() async {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      customLoader.show();

      final form = multi.FormData.fromMap({
        "company_name": nameController.text,
        "address":      addressController.text,
        "website":      websiteController.text,
        "email":        emailController.text.trim(),
        "phone":        phoneController.text.trim(),
      });

      // Attach logo only if a real file path is present
      if (kIsWeb) {
        if (companyLogoBytes != null && companyLogoBytes!.isNotEmpty) {
          form.files.add(
            MapEntry(
              "logo",
              multi.MultipartFile.fromBytes(
                companyLogoBytes!,
                filename: "company_logo.jpg",
                contentType: MediaType("image", "jpeg"),
              ),
            ),
          );
        }
      } else {
      if ((companyLogoUrl ?? '').isNotEmpty) {
        form.files.add(MapEntry(
          "logo",
          await multi.MultipartFile.fromFile(
            companyLogoUrl!,
            filename: companyLogoUrl!.split('/').last,
            contentType: MediaType("image", "jpeg"),
          ),
        ));
      }
      }

      final api = Get.find<PostApiServiceImpl>();
      final resp = await api.createCompanyAPICall(dataBody: form);

      companyResponse = resp.data!;
      _clearFields();
      StorageService.setLoggedIn(true);
      StorageService.setCompanyCreated(true);

      // Persist company selection for refresh-safe access
      if(Get.isRegistered<CompanyService>()) {
        final svc = CompanyService.to;
        await svc.select(companyResponse);

      }
      /*else{
        await Get.putAsync<CompanyService>(
              () async => await CompanyService().init(),
          permanent: true,
        );

        final svc = CompanyService.to;
        await svc.select(companyResponse);
      }*/


      // refresh current user/session for that company
      await APIs.refreshMe(companyId: companyResponse.companyId ?? 0);

      customLoader.hide();
      toast(resp.message ?? 'Company created');

      // ---- Navigate to Invite Member ----
      if (kIsWeb) {
        Get.offAllNamed(
          AppRoutes.home
        );
      } else {
        // Use arguments on mobile
        Get.offAllNamed(
          AppRoutes.invite_member,
          arguments: {
            'companyName': companyResponse.companyName,
            'companyId'  : companyResponse.companyId,
            'invitedBy'  : companyResponse.createdBy,
          },
        );
      }

      update();
    } catch (e) {
      customLoader.hide();
      errorDialog(e.toString());
      update();
    }
  }


  _clearFields() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    websiteController.clear();
    companyLogoUrl = '';
    companyLogoBytes = null;
  }




}





