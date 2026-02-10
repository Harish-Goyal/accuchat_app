import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../Screens/Chat/models/get_company_res_model.dart';
import '../main.dart';

class HiveBoot {
  static bool _inited = false;
  static Future<void>? _initFuture;

  static final Set<String> _openedBoxes = <String>{};

  /// Call on app start AND it’s safe to call again (idempotent).
  static Future<void> init() {
    if (_inited) return Future.value();
    final ongoing = _initFuture;
    if (ongoing != null) return ongoing;
    final future = _doInit();
    _initFuture = future;
    return future;
  }



  static Future<void> _doInit() async {
    try {
      await Hive.initFlutter();
      _registerAdaptersOnce();
      _inited = true;
    } finally {
      _initFuture = null;
    }
  }

  static void _registerAdaptersOnce() {
    final a1 = UserCompanyRoleAdapter();
    if (!Hive.isAdapterRegistered(a1.typeId)) Hive.registerAdapter(a1);

    final a2 = MembersAdapter();
    if (!Hive.isAdapterRegistered(a2.typeId)) Hive.registerAdapter(a2);

    final a3 = CreatorAdapter();
    if (!Hive.isAdapterRegistered(a3.typeId)) Hive.registerAdapter(a3);

    final a4 = UserCompaniesAdapter();
    if (!Hive.isAdapterRegistered(a4.typeId)) Hive.registerAdapter(a4);

    final a5 = CompanyDataAdapter();
    if (!Hive.isAdapterRegistered(a5.typeId)) Hive.registerAdapter(a5);
  }

  /// Always make sure Hive is inited before opening any box
  static Future<Box<T>> openBoxOnce<T>(String name) async {
    // 🔧 NEW: ensure init
    if (!_inited) {
      await init();
    }
    if (Hive.isBoxOpen(name)) {
      _openedBoxes.add(name);
      return Hive.box<T>(name);
    }
    final box = await Hive.openBox<T>(name);
    _openedBoxes.add(name);
    return box;
  }


  static Future<void> closeAndDeleteAll({bool deleteFromDisk = true}) async {
    for (final name in _openedBoxes.toList()) {
      if (Hive.isBoxOpen(name)) {
        try {
          await Hive.box(name).close();
        } catch (_) {
          customLoader.hide();
        }
      }
    }

    try {
      await Hive.close();
    } catch (_) {}

    // Delete/clear tracked boxes
    for (final name in _openedBoxes.toList()) {
      if (deleteFromDisk) {
        try {
          await Hive.deleteBoxFromDisk(name);
        } catch (_) {
          // Fallback
          try {
            final b = await Hive.openBox(name);
            await b.clear();
            await b.close();
          } catch (_) {}
        }
      } else {
        try {
          final b = await Hive.openBox(name);
          await b.clear();
          await b.close();
        } catch (_) {}
      }
    }

    _openedBoxes.clear();

    // 🔧 NEW: mark de-inited so next time init() re-runs Hive.initFlutter()
    _inited = false;
    _initFuture = null;
  }

  /// 🔧 NEW helper: one-shot wipe + fresh init
  static Future<void> resetForFreshStart({bool deleteFromDisk = true}) async {
    await closeAndDeleteAll(deleteFromDisk: deleteFromDisk);
    await init(); // re-run Hive.initFlutter + adapters
  }
}
