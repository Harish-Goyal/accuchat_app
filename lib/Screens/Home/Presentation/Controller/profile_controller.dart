import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as multi;
import 'package:http_parser/http_parser.dart';
import '../../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../main.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/get_company_res_model.dart';
import 'company_service.dart';

class HProfileController extends GetxController {
  UserDataAPI? user;

  String? image;

  String profileImg = '';

  late TextEditingController nameC;
  late TextEditingController aboutC;
  late TextEditingController phoneC;
  late TextEditingController mailC;
  @override
  void onInit() {
    _getCompany();
    nameC = TextEditingController();
    aboutC = TextEditingController();
    phoneC = TextEditingController();
    mailC = TextEditingController();

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

  bool isLoading = true;
  CompanyData? myCompany = CompanyData();
  _getCompany() async {
    final svc     = Get.find<CompanyService>();
    myCompany =svc.selected;
    update();
    hitAPIToGetUser();
  }

  hitAPIToGetUser() async {
    FocusManager.instance.primaryFocus!.unfocus();
    Get.find<AuthApiServiceImpl>().getUserApiCall(companyId: myCompany?.companyId??0).then((value) async {
      isLoading = false;
      userData = value.data!;
      saveUser(userData);
      _initData(userData);
      update();
    }).onError((error, stackTrace) {
      isLoading = false;
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }


  hitAPIToDeleteAccount() async {
    customLoader.show();
    print(APIs.me.userId??0);
    Get.find<PostApiServiceImpl>()
        .deleteUserAccountApiCall(userID: APIs.me.userId??0)
        .then((value) async {
      customLoader.hide();
      logoutLocal();
      update();
    }).onError((error, stackTrace) {
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
    if (image != '' && image != null ) {
      reqData.files.add(MapEntry(
          "user_image",
          await multi.MultipartFile.fromFile(
            image ?? '',
            filename: (image ?? '').split('/').last,
            contentType: MediaType("image", "jpeg"),
          )));

    }

    Get.find<AuthApiServiceImpl>().updateUserApiCall(
      dataBody: reqData
    ).then((value) async {
      customLoader.hide();
      userData = value.data!;

      toast(value.message);

      hitAPIToGetUser();
      await APIs.refreshMe(companyId: myCompany?.companyId ?? 0);

      update();
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
      update();
    });
  }


}
