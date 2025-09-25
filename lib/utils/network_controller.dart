import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController {
  final _isOffline = false.obs;
  StreamSubscription? _connSub;
  bool _dialogShown = false;

  bool get isOffline => _isOffline.value;

  @override
  void onInit() {
    super.onInit();
    _startListening();
    _checkNow(); // initial check
  }

  void _startListening() {
    // connectivity_plus change par re-check (optional)
    _connSub = Connectivity().onConnectivityChanged.listen((_) => _checkNow());
    // aur direct internet status stream bhi use kar sakte ho:
    InternetConnection().onStatusChange.listen((s) { _isOffline.value = s == InternetStatus.disconnected; _handleDialog(); });
  }
  Future<void> _checkNow() async {
    // connectivity may say wifi/mobile, but internet ho ya nahi verify karo
    final hasInternet = await InternetConnection().hasInternetAccess;
    _isOffline.value = !hasInternet;
    _handleDialog();
  }

  void _handleDialog() {
    if (_isOffline.value) {
      _showBlockingDialog();
    } else {
      _closeDialogIfAny();
    }
  }

  void _showBlockingDialog() {
    if (_dialogShown) return;
    _dialogShown = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          // Back press par app close
          SystemNavigator.pop(); // Android पर सही; iOS में Apple discourage karta hai
          return false;
        },
        child: PopScope(
          canPop: false,
          child: Material(
            color: Colors.black54,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.wifi_off, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Network is turned off',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please turn on Mobile Data or Wi-Fi to continue.\nPress Back to exit.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _closeDialogIfAny() {
    if (_dialogShown) {
      if (Get.isDialogOpen ?? false) Get.back();
      _dialogShown = false;
    }
  }

  @override
  void onClose() {
    _connSub?.cancel();
    super.onClose();
  }
}
