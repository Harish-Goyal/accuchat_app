// import 'package:finsin_tms/Screens/Authentication/ResponseModel/profile_respones_model.dart';
// import 'package:finsin_tms/Services/APIs/local_keys.dart';
// import 'package:finsin_tms/Services/APIs/post/post_api_service_impl.dart';
// import 'package:finsin_tms/Utilities/custom_flashbar.dart';
// import 'package:finsin_tms/main.dart';
// import 'package:get/get.dart';
//
// class GetLoginModalService extends GetxService {
//   ProfileData? _userDataModal;
//
//
//
//   @override
//   void onInit() {
//     updateFromAPI();
//     super.onInit();
//   }
//   ProfileData? getUserDataModal() {
//     return _userDataModal;
//   }
//
//   void setUserDataModal({required ProfileData? userDataModal}) {
//     _userDataModal = userDataModal;
//   }
//
//
//
//   updateFromAPI() async{
//     await  Get.find<PostApiServiceImpl>().getProfileApiCall(secretKey: storage.read(user_key)).then((value) async {
//       storage.write(isFirstTime, false);
//       _userDataModal = value.data;
//     }).onError((error, stackTrace) {
//       errorDialog("Something went wrong");
//     });
//   }
// }