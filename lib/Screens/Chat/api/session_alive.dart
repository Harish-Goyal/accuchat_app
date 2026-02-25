import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../Services/storage_service.dart';
import '../../../utils/helper_widget.dart';
import '../../../utils/shares_pref_web.dart';
import '../screens/auth/models/get_uesr_Res_model.dart';
import 'apis.dart';

class Session extends GetxService {
  Session(this._api, this._storage);
  final AuthApiServiceImpl _api;
  final AppStorage _storage;

  static const _userKey = 'user_key';
  final Rxn<UserDataAPI> _user = Rxn<UserDataAPI>();

  UserDataAPI? get user => _user.value;
  Stream<UserDataAPI?> get userStream => _user.stream;
  Rxn<UserDataAPI> get rxUser => _user;


  final Completer<void> _ready = Completer<void>();
  bool _inited = false;
  int? _companyId;
  bool get isReady => _ready.isCompleted;
  Future<void> get ready => _ready.future;
  int? get companyId => _companyId;




  Future<Session> init({required int companyId}) async {
    _loadFromCache();
    _companyId = (companyId == 0) ? null : companyId;

    if (_companyId == null) {
      if (!_ready.isCompleted) _ready.complete();
      _inited = true;
      return this;
    }

    unawaited(refreshUser(companyId: companyId));
    if (!_ready.isCompleted) _ready.complete();
    _inited = true;
    return this;
  }

  Future<Session> initSafe({int? companyId}) async {
    return init(companyId: (companyId ?? 0));
  }

  Future<UserDataAPI?> refreshUser({required int companyId}) async {
    try {
      if (companyId == 0) {
        return _user.value;
      }

      _companyId = companyId;
     await _api.getUserApiCall(companyId: _companyId).then((v) async {
       final fresh = v.data;
       if (fresh != null) {
         await APIs.getFirebaseMessagingToken();
         _saveToCache(fresh);
         _user.value = fresh;

       }
     }).onError((v,e){

     });

    } catch (_) {

    }
    return _user.value;
  }



  Future<void> reinitWithCompany(int companyId) async {
    _companyId = (companyId == 0) ? null : companyId;
    if (_companyId != null) {
      await refreshUser(companyId: _companyId!);
    }
    if (!_ready.isCompleted) _ready.complete();
    _inited = true;
  }


  void patchUserLocally(UserDataAPI updated) {
    _saveToCache(updated);
    _user.value = updated;
  }

  void _loadFromCache() {
    final raw = _storage.read<dynamic>(_userKey);
    if (raw == null) return;
    final map = raw is String
        ? (jsonDecode(raw) as Map<String, dynamic>)
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : null;
    if (map != null) _user.value = UserDataAPI.fromJson(map);
  }

  void _saveToCache(UserDataAPI user) {
    _storage.write(_userKey, user.toJson());
  }

  bool get isLoggedIn {
    final u = _user.value;
    final token = StorageService.getToken();
    final hasId = (u?.userId ?? u?.userId) != null;
    return ((token??'').isNotEmpty || hasId);
  }

  Future<void> whenReady() => ready;

  Future<bool> waitForAuth({Duration timeout = const Duration(milliseconds: 800)}) async {
    if (isLoggedIn) return true;
    final c = Completer<bool>();
    late final StreamSubscription sub;
    sub = userStream.listen((_) {
      if (!c.isCompleted && isLoggedIn) {
        c.complete(true);
        sub.cancel();
      }
    });
    Future.delayed(timeout, () {
      if (!c.isCompleted) {
        c.complete(isLoggedIn);
        sub.cancel();
      }
    });
    return c.future;
  }

  Future<void> signOut() async {
    _user.value = null;
    _storage.write(_userKey, null);
  }

  Future<void> clearSession() async {
    _user.value = null; // Clear user data
    _storage.write(_userKey, null); // Clear the cached user data
    _companyId = null; // Clear the company ID
  }
}
