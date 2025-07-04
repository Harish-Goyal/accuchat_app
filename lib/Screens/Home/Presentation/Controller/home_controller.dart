import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../Chat/api/apis.dart';
import '../../../Chat/models/chat_user.dart';
import '../../../Chat/models/message.dart';
class DashboardController extends GetxController {
  var chats = <String>["Hello", "Hi"].obs;
  var connectedApps = <String>["AccutechERP"].obs;
  var currentIndex = 0.obs;
  User? user;
  void addChat(String chat) {
    chats.add(chat);
  }

  void connectApp(String appCode) {
    connectedApps.add(appCode);
  }

  void updateIndex(int index) {
    currentIndex.value = index;

  }

  @override
  void onInit() async{
    getData();
    refreshChats();
    getTopSixRecentChats();
    futureChats = getTopSixRecentChats();
    super.onInit();
  }

  getData()async{
    user= FirebaseAuth.instance.currentUser;
    await APIs.getSelfInfo();
    update();
  }

  int length =0;



  late Future<List<Map<String,dynamic>>> futureChats;

  var initData;
  Future<void> refreshChats() async {
    getData();
      futureChats = getTopSixRecentChats();
      initData = await futureChats;
      update();

  }


  Future<List<Map<String, dynamic>>> getTopSixRecentChats() async {
    List<Map<String, dynamic>> merged = [];

    // 🔹 Fetch users
    final userSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(APIs.me.id)
        .collection('my_users')
        .get();

    for (var doc in userSnap.docs) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(doc.id).get();
      if (userDoc.exists) {
        final user = ChatUser.fromJson(userDoc.data()!);

        final convID = APIs.getConversationID(user.id);
        final lastMsgSnap = await FirebaseFirestore.instance
            .collection('chats/$convID/messages')
            .where('companyId', isEqualTo: APIs.me.selectedCompany?.id)
            .orderBy('sent', descending: true)
            .limit(1)
            .get();

        final lastMessage = lastMsgSnap.docs.isNotEmpty
            ? Message.fromJson(lastMsgSnap.docs.first.data())
            : null;

        if (lastMessage != null) {
          merged.add({'type': 'user', 'user': user, 'lastMessage': lastMessage});
        }
      }
    }

    // 🔹 Fetch groups
    final groupSnap = await FirebaseFirestore.instance.collection('groups').get();
    for (var doc in groupSnap.docs) {
      final data = doc.data();
      final group = ChatGroup.fromJson(data);

      if ((group.members ?? []).contains(APIs.me.id)) {
        final lastMsgSnap = await FirebaseFirestore.instance
            .collection('groups/${group.id}/messages')
            .where('companyId', isEqualTo: APIs.me.selectedCompany?.id)
            .orderBy('sent', descending: true)
            .limit(1)
            .get();

        final lastMessage = lastMsgSnap.docs.isNotEmpty
            ? Message.fromJson(lastMsgSnap.docs.first.data())
            : null;

        if (lastMessage != null) {
          merged.add({'type': 'group', 'group': group, 'lastMessage': lastMessage});
        }
      }
    }

    // 🔻 Sort
    merged.sort((a, b) {
      final aTime = int.tryParse(a['lastMessage'].sent) ?? 0;
      final bTime = int.tryParse(b['lastMessage'].sent) ?? 0;
      return bTime.compareTo(aTime);
    });

    return merged.take(6).toList();
  }


}
