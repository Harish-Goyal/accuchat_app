import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../utils/memmory_Doctor.dart';
import '../../../Chat/api/session_alive.dart';
import '../../../Chat/models/get_company_res_model.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class CompanyService extends GetxController {
  CompanyData? selected;
  late Box<CompanyData> _box;

  @override
  onInit(){
    init();
    super.onInit();
  }

  Future<void> init() async {
    _box = await Hive.openBox<CompanyData>(selected_company_box);
    selected = _box.get('current');
    if (selected != null) {
      try {
        final session = Get.find<Session>();
        await session.init(companyId: selected?.companyId??0);
      } catch (e) {
        debugPrint('Session init from CompanyService failed: $e');
      }
    }
  }

  int? get id => selected?.companyId;
  String get name => selected?.companyName ?? '-';

  Future<void> select(CompanyData c) async {
    // if (selected?.companyId == c.companyId) return; // same selection -> no-op
    await _box.put('current', c);// overwrite old
    await _box.flush();
    selected = c;
    update();
    await MemoryDoctor.deflateBeforeNav();
    MemoryDoctor.disposeFeatureControllers();
    try {
      final session = Get.find<Session>();
      await session.refreshUser(companyId: c.companyId??0);
    } catch (e) {
      debugPrint('Session refresh failed: $e');
    }
  }

  Future<void> clear() async {
    await _box.delete('current');
    selected = null;
    update();
  }
}


/*const _companyBox = 'selected_company_box';
const _keyCurrent  = 'current';

class CompanyService extends GetxService {
  final Rxn<CompanyData> _selected = Rxn<CompanyData>();
  Box<CompanyData>? _box;

  CompanyData? get selected => _selected.value;
  int? get id => _selected.value?.companyId;
  String get name => _selected.value?.companyName ?? '-';
  bool get hasCompany => _selected.value != null;

  /// Call via: await Get.putAsync(() async => CompanyService().init(), permanent: true)
  Future<CompanyService> init() async {
    _box ??= await Hive.openBox<CompanyData>(_companyBox);
    _selected.value = _box!.get(_keyCurrent);

    if (_selected.value != null) {
      await _initSessionSafe(_selected.value!.companyId ?? 0);
    }
    return this;
  }

  Future<void> select(CompanyData c, {bool persist = true}) async {
    if (persist) {
      await _box?.put(_keyCurrent, c);
      await _box?.flush();
    }
    _selected.value = c; // Obx listeners update automatically

    // optional hygiene between company switches
    await MemoryDoctor.deflateBeforeNav();
    MemoryDoctor.disposeFeatureControllers();

    await _refreshSessionSafe(c.companyId ?? 0);
  }

  Future<void> clear() async {
    await _box?.delete(_keyCurrent);
    _selected.value = null; // reactive clear
  }

  // ---- session helpers (safe if Session isn't registered yet) ----
  Future<void> _initSessionSafe(int companyId) async {
    try {
      final session = Get.find<Session>();
      await session.init(companyId: companyId);
    } catch (e, s) {
      debugPrint('Session init from CompanyService failed: $e\n$s');
    }
  }

  Future<void> _refreshSessionSafe(int companyId) async {
    try {
      final session = Get.find<Session>();
      await session.refreshUser(companyId: companyId);
    } catch (e, s) {
      debugPrint('Session refresh from CompanyService failed: $e\n$s');
    }
  }

  static CompanyService get to => Get.find<CompanyService>();
}*/

