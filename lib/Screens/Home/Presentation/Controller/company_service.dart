import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../utils/memmory_Doctor.dart';
import '../../../Chat/api/session_alive.dart';
import '../../../Chat/models/get_company_res_model.dart';

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
