import 'dart:typed_data';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Controllers/all_settings_controller.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as multi;
import 'package:http_parser/http_parser.dart';
import '../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../../utils/helper_widget.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/get_company_res_model.dart';
import 'company_service.dart';

class HProfileController extends GetxController {
  UserDataAPI? user;

  String? image;

  String profileImg = '';
  Uint8List? webImageBytes;
  TextEditingController nameC = TextEditingController();
  TextEditingController aboutC = TextEditingController();
  TextEditingController phoneC = TextEditingController();
  TextEditingController mailC = TextEditingController();
  @override
  void onInit() {
    _getCompany();
    super.onInit();
  }

  _initData(UserDataAPI user) {
    profileImg = user.userImage ?? '';
    nameC = TextEditingController(text: user.userName ?? '');
    aboutC = TextEditingController(text: user.about ?? '');
    phoneC = TextEditingController(text: user.phone ?? '');
    mailC = TextEditingController(text: user.email ?? '');
  }

  UserDataAPI userData = UserDataAPI();

  bool isLoading = false;
  CompanyData? myCompany = CompanyData();
  _getCompany() async {
    final svc = CompanyService.to;
    myCompany = svc.selected;
    hitAPIToGetUser();
  }

  hitAPIToGetUser() async {
    isLoading = true;
    update();
    await Get.find<AuthApiServiceImpl>()
        .getUserApiCall(companyId: myCompany?.companyId ?? 0)
        .then((value) async {
      isLoading = false;
      update();
      userData = value.data!;
      saveUser(userData);
      _initData(userData);
    }).onError((error, stackTrace) {
      showCompanyErrorDialog();
      isLoading = false;
      if (!kIsWeb) {
        FirebaseCrashlytics.instance
            .recordError(error, stackTrace, reason: 'apiCall failed');
      }
      errorDialog(error.toString());
      update();
    });
  }

  Future<void> hitAPIToRemoveUserPic() async {
    customLoader.show();
    await Get.find<AuthApiServiceImpl>()
        .removeUserProfileApiCall()
        .then((value) async {
      customLoader.hide();
      toast(value.message);
      hitAPIToGetUser();
      await APIs.refreshMe(companyId: myCompany?.companyId ?? 0);
      Get.find<AllSettingsController>().update();
      Get.back();
    }).onError((error, stackTrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance
            .recordError(error, stackTrace, reason: 'apiCall failed');
      }
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }



  hitAPIToDeleteAccount() async {
    customLoader.show();
    await Get.find<PostApiServiceImpl>()
        .deleteUserAccountApiCall(userID: APIs.me.userId ?? 0)
        .then((value) async {
      toast(value.message);
      customLoader.hide();
      imageCache.clear();
      imageCache.clearLiveImages();
      hitAPIToDeletePushToken();
      // logoutLocal();
      update();
    }).onError((error, stackTrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance
            .recordError(error, stackTrace, reason: 'apiCall failed');
      }
      customLoader.hide();
    });
  }

  hitAPIToUpdateUser() async {
    FocusManager.instance.primaryFocus!.unfocus();
    customLoader.show();
    var reqData = multi.FormData.fromMap({
      "user_name": nameC.text.trim(),
      "about": aboutC.text.trim(),
    });

    if (kIsWeb) {
      if (webImageBytes != null) {
        reqData.files.add(
          MapEntry(
            "user_image",
            multi.MultipartFile.fromBytes(
              webImageBytes!, // Uint8List
              filename: "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
              contentType: MediaType("image", "jpeg"),
            ),
          ),
        );
      }
    } else {
      if (image != '' && image != null) {
        reqData.files.add(MapEntry(
            "user_image",
            await multi.MultipartFile.fromFile(
              image ?? '',
              filename: (image ?? '').split('/').last,
              contentType: MediaType("image", "jpeg"),
            )));
      }
    }

    await Get.find<AuthApiServiceImpl>()
        .updateUserApiCall(dataBody: reqData)
        .then((value) async {
      customLoader.hide();
      userData = value.data!;

      toast(value.message);

      hitAPIToGetUser();
      await APIs.refreshMe(companyId: myCompany?.companyId ?? 0);

      Get.find<AllSettingsController>().update();

      update();
    }).onError((error, stackTrace) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance
            .recordError(error, stackTrace, reason: 'apiCall failed');
      }
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }
}
