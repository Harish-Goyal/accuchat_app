// import 'package:lyhummer/pages/chat_module/presentation/controllers/story_chat_view_Controller.dart';
//
// import '../../../../export.dart';
//
// class StoryChatPageView extends GetView<StoryChatViewController> {
//   @override
//   Widget build(BuildContext context) {
//     return MyAnnotatedRegion(
//       isDark: true,
//       child: Material(
//           child: Scaffold(
//
//               body: StoryView(
//                 onComplete: () {
//
//                   Get.back();
//                 },
//
//
//                 onStoryShow: (StoryItem value) {
//
//
//                   SystemChannels.textInput.invokeMethod('TextInput.hide');
//                 },
//                 storyItems: controller.storyItems ??
//                     [
//                       StoryItem.text(
//                           title: "No Status", backgroundColor: appColor)
//                     ],
//                 controller: controller.storyController,
//                 inline: false,
//                 repeat: false,
//               ))),
//     );
//   }
//
//
// }