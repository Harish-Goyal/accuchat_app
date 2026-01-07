import 'dart:async';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'no_internet_dialog.dart';

class NoNetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;

  RxBool isDialogOpen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _subscription = _connectivity.onConnectivityChanged.listen(
          (List<ConnectivityResult> results) {
        _onConnectionChange(results);
      },
    );

  }

  void _onConnectionChange(List<ConnectivityResult> results) {
    if (!hasInternet(results)) {
      showNoInternetDialog();
    } else {
      closeDialogIfOpen();
    }
  }

  bool hasInternet(List<ConnectivityResult> results) {
    return results.any((r) =>
    r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }

  void showNoInternetDialog() {
    if (isDialogOpen.value) return;

    isDialogOpen.value = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
             NoInternetDialog( onRetry: () {
              // Optional: you can ping / re-check connectivity here
              // But STILL do not close dialog manually; auto-close only when net returns
            },),
          ],
        ),
      ),
      barrierDismissible: false,
    );

  }

  void closeDialogIfOpen() {
    if (isDialogOpen.value) {
      isDialogOpen.value = false;
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
