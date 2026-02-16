import 'package:get/get.dart';

class ChatPresence {
  static final activeChatId = RxnInt(); // null = no chat open
}

class TaskPresence {
  static final activeTaskId = RxnInt(); // null = no chat open
}