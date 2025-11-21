import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';

import '../../../Services/APIs/auth_service/auth_api_services_impl.dart';
import '../../../Services/storage_service.dart';
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
  Rxn<UserDataAPI> get rxUser => _user; // <-- expose Rx for Obx


  // ADD: lifecycle helpers
  // =========================
  final Completer<void> _ready = Completer<void>();              // ADD
  bool _inited = false;                                          // ADD
  int? _companyId;                                               // ADD
  bool get isReady => _ready.isCompleted;                        // ADD
  Future<void> get ready => _ready.future;                       // ADD
  int? get companyId => _companyId;                              // ADD




  Future<Session> init({required int companyId}) async {
    _loadFromCache();
    // ADD: remember company (treat 0 as "none yet")
    _companyId = (companyId == 0) ? null : companyId;            // ADD

    // ADD: if company unknown yet, don't call network now – just mark ready
    if (_companyId == null) {                                    // ADD
      if (!_ready.isCompleted) _ready.complete();                // ADD
      _inited = true;                                            // ADD
      return this;                                               // ADD
    }

    unawaited(refreshUser(companyId: companyId)); // SWR
    if (!_ready.isCompleted) _ready.complete();                  // ADD
    _inited = true;                                              // ADD
    return this;
  }

  Future<Session> initSafe({int? companyId}) async {             // ADD
    return init(companyId: (companyId ?? 0));                    // ADD
  }

  Future<UserDataAPI?> refreshUser({required int companyId}) async {
    try {
      if (companyId == 0) {                                      // ADD
        return _user.value;                                      // ADD
      }                                                          // ADD

      _companyId = companyId;
      final res = await _api.getUserApiCall(companyId: _companyId);
      final fresh = res.data;
      if (fresh != null) {
        await APIs.getFirebaseMessagingToken();
        _saveToCache(fresh);
        _user.value = fresh;
      }
    } catch (_) { /* keep cached */ }
    return _user.value;
  }



  Future<void> reinitWithCompany(int companyId) async {          // ADD
    _companyId = (companyId == 0) ? null : companyId;            // ADD
    if (_companyId != null) {                                    // ADD
      await refreshUser(companyId: _companyId!);                 // ADD
    }                                                            // ADD
    if (!_ready.isCompleted) _ready.complete();                  // ADD
    _inited = true;                                              // ADD
  }                                                              // ADD


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












  /// Adjust these to match your actual model fields.
  bool get isLoggedIn {
    final u = _user.value;
    // Prefer a server token/expiry if you have it:
    final token = StorageService.getToken();
    final hasId = (u?.userId ?? u?.userId) != null;
    return ((token??'').isNotEmpty || hasId);
  }

  /// Resolves once hydration is done (cache loaded, optional SWR kicked off).
  Future<void> whenReady() => ready;

  /// Optional: wait up to [timeout] for user to become available after startup.
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
    // small timeout so web doesn’t hang
    Future.delayed(timeout, () {
      if (!c.isCompleted) {
        c.complete(isLoggedIn);
        sub.cancel();
      }
    });
    return c.future;
  }

  /// Optional sign-out utility
  Future<void> signOut() async {
    _user.value = null;
    _storage.write(_userKey, null);
  }
}
