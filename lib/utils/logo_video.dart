// import 'package:AccuChat_erp_flutter/constants/themes.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class LogoVideoPlayer extends StatefulWidget {
//   @override
//   _LogoVideoPlayerState createState() => _LogoVideoPlayerState();
// }
//
// class _LogoVideoPlayerState extends State<LogoVideoPlayer> {
//   late VideoPlayerController _controller;
//
//   @override
//   void initState() {
//     inti();
//
//     super.initState();
//   }
//
//   inti()async{
//     if(mounted) {
//
//       _controller =
//           VideoPlayerController.asset('assets/images/checkinmyhotellogo.mp4');
//       await Future.wait([_controller.initialize()]);
//       // ..initialize().then((_) {
//       //   setState(() {});
//       // });
//       _controller.setLooping(true);
//       _controller.play();
//       setState(() {});
//     }
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return /*_controller.value.isInitialized
//         ? */Center(
//           child: Container(
//                     // color: AppTheme.redErrorColor,
//                     child: VideoPlayer(
//                         _controller),
//           ),
//         );
//         // : Center(child: CircularProgressIndicator());
//   }
// }
