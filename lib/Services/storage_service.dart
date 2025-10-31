import 'dart:convert';
import 'package:AccuChat/Services/APIs/local_keys.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _boxName = 'accuchat';
  static GetStorage? _box;
  static SharedPreferences? _prefs;

  static bool _initialized = false;
  static Future<void>? _initFuture;

  static Future<void> init() {
    if (_initialized) return Future.value();
    final ongoing = _initFuture;
    if (ongoing != null) return ongoing;

    final future = _doInit();
    _initFuture = future;
    return future;
  }

  static Future<void> _doInit() async {
    try {
      if (kIsWeb) {
        _prefs ??= await SharedPreferences.getInstance();
      } else {
        // Only init once
        if (!GetStorage().hasData(_boxName)) {
          await GetStorage.init(_boxName);
        } else {
          // still OK to proceed; GetStorage.init is idempotent-ish,
          // but we guard anyway
        }
        _box ??= GetStorage(_boxName);
      }
      _initialized = true;
    } finally {
      _initFuture = null;
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
  static Future<void> saveMobile(String mob) async {
    if (kIsWeb) {
      await _prefs!.setString(user_mob, mob);
    } else {
      await _box!.write(user_mob, mob);
    }
  }

  static String? getMobile() {
    return kIsWeb ? _prefs?.getString(user_mob) : _box?.read<String>(user_mob);
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
 static Future<void> setCompanyCreated(bool v) async {
    if (kIsWeb) {
      await _prefs!.setBool(isCompanyCreated, v);
    } else {
      await _box!.write(isCompanyCreated, v);
    }
  }

  static bool checkCompanyCreated() {
    return kIsWeb
        ? (_prefs?.getBool(isCompanyCreated) ?? false)
        : (_box?.read<bool>(isCompanyCreated) ?? false);
  }

  static Future<void> setFirstTimeTask(bool v) async {
    if (kIsWeb) {
      await _prefs!.setBool(isFirstTimeChatKey, v);
    } else {
      await _box!.write(isFirstTimeChatKey, v);
    }
  }

  static bool checkFirstTimeTask() {
    return kIsWeb
        ? (_prefs?.getBool(isFirstTimeChatKey) ?? false)
        : (_box?.read<bool>(isFirstTimeChatKey) ?? false);
  }


  static Future<void> setIsFirstTime(bool v) async {
    if (kIsWeb) {
      await _prefs!.setBool(isFirstTime, v);
    } else {
      await _box!.write(isFirstTime, v);
    }
  }

  static bool checkISFirstTime() {
    return kIsWeb
        ? (_prefs?.getBool(isFirstTime) ?? false)
        : (_box?.read<bool>(isFirstTime) ?? false);
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



  /// Write a list of JSON maps
  static Future<void> writeJsonList(String key, List<Map<String, dynamic>> list) async {
    final s = jsonEncode(list);
    if (kIsWeb) {
      await _prefs!.setString(key, s);
    } else {
      await _box!.write(key, s);
    }
  }

  /// Read a list of JSON maps
  static List<Map<String, dynamic>>? readJsonList(String key) {
    final s = kIsWeb ? _prefs?.getString(key) : _box?.read<String>(key);
    if (s == null) return null;

    final decoded = jsonDecode(s);
    if (decoded is List) {
      return decoded.map<Map<String, dynamic>>(
            (e) => Map<String, dynamic>.from(e as Map),
      ).toList();
    }
    return null;
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