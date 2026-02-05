import 'package:get/get.dart';
import '../../../../models/chat_user.dart';

class AddBroadcastMemController extends GetxController{
   BroadcastChat? chat;


   List<ChatUser> allUsers = [];
   List<String> selectedUserIds = [];
   bool isLoding = false;

   @override
   void onInit() {
     super.onInit();

     fetchUsers();
   }



   List<String> adminIds = [];
   String? currentUserId;

   Future<void> fetchUsers() async {
     // isLoding = true;
     // try {
     //   final groupDoc = await FirebaseFirestore.instance
     //       .collection('broadcasts')
     //       .doc(chat?.id)
     //       .get();
     //
     //   final groupData = groupDoc.data();
     //   final List<String> memberIds =
     //   List<String>.from(groupData?['members'] ?? []);
     //
     //   final snapshot =
     //   await FirebaseFirestore.instance.collection('users')
     //       .where('selectedCompany.id', isEqualTo: APIs.me.selectedCompany?.id)
     //       .get();
     //   final allUser =
     //   snapshot.docs.map((e) => ChatUser.fromJson(e.data())).toList();
     //
     //   final filteredUsers =
     //   allUser.where((user) => !memberIds.contains(user.id)).toList();
     //
     //   allUsers = filteredUsers;
     //   isLoding = false;
     //   update();
     // } catch (e, s) {
     //   isLoding = false;
     // }
   }


}