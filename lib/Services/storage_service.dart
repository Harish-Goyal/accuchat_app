import 'dart:convert';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _boxName = 'accuchat';
  static GetStorage? _box;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    } else {
      await GetStorage.init(_boxName);
      _box = GetStorage(_boxName);
    }
  }

  // --- Token helpers ---
  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      await _prefs!.setString(LOCALKEY_token, token);
    } else {
      await _box!.write(LOCALKEY_token, token);
    }
  }

  static String? getToken() {
    return kIsWeb ? _prefs?.getString(LOCALKEY_token) : _box?.read<String>(LOCALKEY_token);
  }

  static Future<void>? deleteToken() {
    return kIsWeb ? _prefs?.remove(LOCALKEY_token) : _box?.remove(LOCALKEY_token);
  }

  static Future<void> setLoggedIn(bool v) async {
    if (kIsWeb) {
      await _prefs!.setBool(isLoggedIn, v);
    } else {
      await _box!.write(isLoggedIn, v);
    }
  }

  static bool isLoggedInCheck() {
    return kIsWeb
        ? (_prefs?.getBool(isLoggedIn) ?? false)
        : (_box?.read<bool>(isLoggedIn) ?? false);
  }
  static Future<void>? deleteLoggedInCheck() {
    return kIsWeb
        ? (_prefs?.remove(isLoggedIn))
        : (_box?.remove(isLoggedIn));
  }

  static Future<void> setIsFirst(bool v) async {
    if (kIsWeb) {
      await _prefs!.setBool(isFirstTime, v);
    } else {
      await _box!.write(isFirstTime, v);
    }
  }

  static bool getIsFirst() {
    return kIsWeb
        ? (_prefs?.getBool(isFirstTime) ?? false)
        : (_box?.read<bool>(isFirstTime) ?? false);
  }

  // Generic JSON helpers if needed
  static Future<void> writeJson(String key, Map<String, dynamic> json) async {
    final s = jsonEncode(json);
    if (kIsWeb) {
      await _prefs!.setString(key, s);
    } else {
      await _box!.write(key, s);
    }
  }

  static Map<String, dynamic>? readJson(String key) {
    final s = kIsWeb ? _prefs?.getString(key) : _box?.read<String>(key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static Future<void> remove(String key) async {
    if (kIsWeb) {
      await _prefs?.remove(key);
    } else {
      await _box?.remove(key);
    }
  }

  static Future<void> clear() async {
    if (kIsWeb) {
      await _prefs?.clear();
    } else {
      await _box?.erase();
    }
  }
}