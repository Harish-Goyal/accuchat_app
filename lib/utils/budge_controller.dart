// import 'package:get/get.dart';
//
// enum BadgeType { chat, task }
//
// class AppBadgeController extends GetxController {
//   static AppBadgeController get to => Get.find();
//
//   final currentCompanyId = 0.obs;
//
//   // current company tab badges
//   final chatBadge = 0.obs;
//   final taskBadge = 0.obs;
//
//   // other-company indicator (dot or count)
//   final otherCompanyDot = false.obs;
//
//   // optional: other-company wise counts
//   final otherChatByCompany = <int, int>{}.obs;
//   final otherTaskByCompany = <int, int>{}.obs;
//
//   void setCompany(int id) {
//     currentCompanyId.value = id;
//     // when switch company, reset dot if no other pending
//     _recalcOtherDot();
//   }
//
//   void incCurrent(BadgeType type) {
//     if (type == BadgeType.chat) chatBadge.value++;
//     else taskBadge.value++;
//   }
//
//   void setCurrentCounts({int? chat, int? task}) {
//     if (chat != null) chatBadge.value = chat;
//     if (task != null) taskBadge.value = task;
//   }
//
//   void markOtherCompany(BadgeType type, int companyId, {int incBy = 1}) {
//     otherCompanyDot.value = true;
//     if (type == BadgeType.chat) {
//       otherChatByCompany[companyId] = (otherChatByCompany[companyId] ?? 0) + incBy;
//       otherChatByCompany.refresh();
//     } else {
//       otherTaskByCompany[companyId] = (otherTaskByCompany[companyId] ?? 0) + incBy;
//       otherTaskByCompany.refresh();
//     }
//   }
//
//   void clearCurrentChat() => chatBadge.value = 0;
//   void clearCurrentTask() => taskBadge.value = 0;
//
//   void clearCompany(int companyId) {
//     otherChatByCompany[companyId] = 0;
//     otherTaskByCompany[companyId] = 0;
//     otherChatByCompany.refresh();
//     otherTaskByCompany.refresh();
//     _recalcOtherDot();
//   }
//
//   void _recalcOtherDot() {
//     final has = otherChatByCompany.values.any((v) => v > 0) ||
//         otherTaskByCompany.values.any((v) => v > 0);
//     otherCompanyDot.value = has;
//   }
// }
