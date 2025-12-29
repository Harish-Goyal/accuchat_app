import 'package:flutter/cupertino.dart';

import '../Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../Services/notification_web_mobile.dart';

class NotificationRedirectPage extends StatefulWidget {
  const NotificationRedirectPage({super.key});

  @override
  State<NotificationRedirectPage> createState() => _NotificationRedirectPageState();
}

class _NotificationRedirectPageState extends State<NotificationRedirectPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final qp = Uri.base.queryParameters;

      final type = qp['messageType'];


      // NOTE: best is minimal ids from qp, and then API hit karke user fetch
      final user = UserDataAPI.fromJson(qp.map((k, v) => MapEntry(k, v)));
      final companyId = user.userCompany?.companyId;
      await NotificationServicess.handleTapByType(type, companyId, user: user);

      // optional: redirect page ko stack se hata do
      // Get.offAllNamed(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
