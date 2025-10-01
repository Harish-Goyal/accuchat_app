// lib/services/client_env.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

class ClientEnv {
  /// Collects environment info for attaching to your login request.
  static Future<Map<String, dynamic>> collect(BuildContext context) async {
    final data = <String, dynamic>{
      'app': {
        'buildMode': kIsWeb ? 'web' : 'mobile',
      },
      'ui': {
        'logicalSize': _logicalSize(context),
        'devicePixelRatio': _dpr(context),
      },
      'time': {
        'timeZoneName': DateTime.now().timeZoneName,
        'timeZoneOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
      },
      // filled below
      'network': {},
      'browser': {},
      'ip': {},
    };

    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      final web = await deviceInfo.webBrowserInfo;
      data['browser'] = {
        'browserName': web.browserName.name, // chrome, firefox, safari, etc.
        'userAgent': web.userAgent,
        'appName': web.appName,
        'appVersion': web.appVersion,
        'platform': web.platform,
        'vendor': web.vendor,
        'hardwareConcurrency': web.hardwareConcurrency,
        'maxTouchPoints': web.maxTouchPoints,
        'languages': web.languages,
        'deviceMemoryGB': web.deviceMemory, // may be null
      };

      // Web-only extras via guarded import
      try {
        // ignore: avoid_web_libraries_in_flutter

        // NOTE: The above import must be at file top-level; if you prefer to
        // keep one file, copy this block to a separate `client_env_web.dart`
        // with conditional imports. For a single-file quick fix, use this shim:
      } catch (_) {/* noop */}
    } else {
      // Optional: basic device flavor on mobile, so the same method works everywhere.
      try {
        final base = await deviceInfo.deviceInfo;
        data['browser'] = {'platform': base.data['systemName'] ?? 'unknown'};
      } catch (_) {}
    }

    // Optional: public IP (works on web if CORS allowed)
    try {
      // ipify has permissive CORS; switch to your backend if you like
      final r = await http
          .get(Uri.parse('https://api64.ipify.org?format=json'))
          .timeout(const Duration(seconds: 4));
      if (r.statusCode == 200) {
        data['ip'] = json.decode(r.body); // { "ip": "x.x.x.x" }
      }
    } catch (_) {}

    // Try to enrich network info on web via JS interop (guarded)
    if (kIsWeb) {

    }

    return data;
  }

  static Map<String, num> _logicalSize(BuildContext context) {
    final mq = MediaQuery.maybeOf(context);
    if (mq == null) return {'w': 0, 'h': 0};
    return {'w': mq.size.width, 'h': mq.size.height};
    // For physical pixels, multiply by devicePixelRatio.
  }

  static num _dpr(BuildContext context) {
    final mq = MediaQuery.maybeOf(context);
    return mq?.devicePixelRatio ?? 1.0;
  }
}
