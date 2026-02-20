import 'package:get/get.dart';

import '../Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

class ChatPresence {
  static final activeChatId = RxnInt();
}

class TaskPresence {
  static final activeTaskId = RxnInt();
}

int? chatKey(UserDataAPI? u) {
  return (u?.userCompany?.userCompanyId!=0)
      ? u!.userCompany!.userCompanyId
      : 0;
}
