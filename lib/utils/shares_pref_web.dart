import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IStorage {
  Future<void> init();
  Future<void> write(String key, dynamic value);
  T? read<T>(String key);
  Future<bool> remove(String key);
  Future<bool> clear();
}


class PrefsStorage implements IStorage {

   SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    // _prefs = await SharedPreferences.getInstance();
  }

  @override
  T? read<T>(String key) {
    final v = _prefs?.get(key);
    if (v == null) return null;
    // decode JSON strings back to maps if needed
    if (T == Map || T == Map<String, dynamic>) {
      if (v is String) return jsonDecode(v) as T;
    }
    return v as T?;
  }

  @override
  Future<void> write(String key, value) async {
    if (value is String) {
      await _prefs?.setString(key, value);
    } else if (value is int) {
      await _prefs?.setInt(key, value);
    } else if (value is double) {
      await _prefs?.setDouble(key, value);
    } else if (value is bool) {
      await _prefs?.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs?.setStringList(key, value);
    } else if (value is Map) {
      await _prefs?.setString(key, jsonEncode(value));
    } else {
      await _prefs?.setString(key, value.toString());
    }
  }

  @override
  Future<bool> remove(String key) => _prefs!.remove(key);

  @override
  Future<bool> clear() => _prefs!.clear();
}

/// Use this everywhere in your app
class AppStorage {
  static final AppStorage _i = AppStorage._();
  AppStorage._();
  factory AppStorage() => _i;

  late final IStorage _impl;

  Future<void> init({String boxName = 'accu_chat'}) async {
    if (kIsWeb) {
      _impl = PrefsStorage(); // ✅ stable on web
    } else {
      _impl = GetBoxStorage(boxName: boxName);
    }
    await _impl.init();
  }

  Future<void> write(String key, dynamic value) => _impl.write(key, value);
  T? read<T>(String key) => _impl.read<T>(key);
  Future<bool> remove(String key) => _impl.remove(key);
  Future<bool> clear() => _impl.clear();
}




class GetBoxStorage implements IStorage {
  final String boxName;
  late GetStorage _box;
  GetBoxStorage({this.boxName = 'app'});

  @override
  Future<void> init() async {
    await GetStorage.init(boxName);
    _box = GetStorage(boxName);
  }

  @override
  T? read<T>(String key) {
    final v = _box.read(key);
    return v is T ? v : v as T?;
  }

  @override
  Future<void> write(String key, value) async {
    // Ensure web-compat JSON (avoid custom objects).
    await _box.write(key, value);
  }

  @override
  Future<bool> remove(String key) async {
    await _box.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    await _box.erase();
    return true;
  }
}