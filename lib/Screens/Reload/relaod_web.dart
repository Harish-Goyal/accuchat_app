import 'dart:html' as html;

import 'package:AccuChat/Screens/Reload/reload_abstact.dart';

class ReloadControllerImpl  extends ReloadController {
  @override
  void refreshApp() {
    html.window.location.href = '${html.window.location.origin}/';
  }
}


