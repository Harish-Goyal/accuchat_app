import 'dart:async';
import 'package:AccuChat/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:share_handler/share_handler.dart';

class ShareHandlerController extends GetxController {
  final Rxn<SharedMedia> sharedMedia = Rxn<SharedMedia>();
  StreamSubscription<SharedMedia>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _initShareHandler();
  }

  Future<void> _initShareHandler() async {
    final handler = ShareHandler.instance;

    final initialMedia = await handler.getInitialSharedMedia();
    print('INITIAL SHARE => ${initialMedia?.imageFilePath}');

    if (initialMedia != null) {
      sharedMedia.value = initialMedia;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.context != null) {
          Get.toNamed(AppRoutes.shareSelectChat, arguments: initialMedia);
        }
      });
    }

    _subscription = handler.sharedMediaStream.listen((SharedMedia media) {
      sharedMedia.value = media;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (Get.context != null) {
          // print(
          //   '=======text: ${initialMedia?.content}, files: ${initialMedia?.attachments?.length ?? 0}',
          // );
          // Get.snackbar(
          //   'Share stream received',
          //   'text: ${media.content}, files: ${media.attachments?.length ?? 0}',
          //   snackPosition: SnackPosition.BOTTOM,
          // );
          Get.toNamed(AppRoutes.shareSelectChat, arguments: media);
        }
      });
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}