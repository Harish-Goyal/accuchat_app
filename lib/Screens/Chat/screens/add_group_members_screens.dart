import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Constants/assets.dart';
import '../../../main.dart';
import '../../../utils/networl_shimmer_image.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';

class AddGroupMembersScreen extends StatefulWidget {
  final ChatGroup group;

  const AddGroupMembersScreen({super.key, required this.group});

  @override
  State<AddGroupMembersScreen> createState() => _AddGroupMembersScreenState();
}

class _AddGroupMembersScreenState extends State<AddGroupMembersScreen> {
  List<ChatUser> _allUsers = [];
  List<String> _selectedUserIds = [];
  bool _isLoding = false;

  @override
  void initState() {
    super.initState();

    _fetchUsers();
  }
  List<String> _adminIds = [];
  String? _currentUserId;


  Future<void> _fetchUsers() async {
    _isLoding = true;
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.id)
          .get();

      final groupData = groupDoc.data();
      final List<String> memberIds = List<String>.from(groupData?['members'] ?? []);

      final snapshot = await FirebaseFirestore.instance.collection('users').where('selectedCompany.id', isEqualTo: widget.group.companyId).get();
      final allUsers = snapshot.docs.map((e) => ChatUser.fromJson(e.data())).toList();

      final filteredUsers = allUsers.where((user) => !memberIds.contains(user.id)).toList();

      setState(() => _allUsers = filteredUsers);
      _isLoding = false;
    } catch (e, s) {
      print('❌ Error fetching filtered users: $e');
      print('📍 Stack trace: $s');
      _isLoding = false;
    }
  }



  @override
  Widget build(BuildContext context) {
    ThemeData themeData  = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title:  Text('Add Group Members',style: themeData.textTheme.titleMedium,)),
      body:_isLoding?IndicatorLoading(): _allUsers.isEmpty
          ? const Center(child: Text("No User Found!"))
          : ListView.builder(
        itemCount: _allUsers.length,
        itemBuilder: (context, index) {
          final user = _allUsers[index];
          final isSelected = _selectedUserIds.contains(user.id);
          final isAdmin = _adminIds.contains(user.id);
          final isMe = _currentUserId == user.id;
          return CheckboxListTile(
            value: isSelected,
            checkColor: Colors.white,
            activeColor: appColorGreen,
            onChanged: (selected) {
              setState(() {
                if (selected == true) {
                  _selectedUserIds.add(user.id);
                } else {
                  _selectedUserIds.remove(user.id);
                }
              });
            },
            title: Container(
              width: Get.width*.4,
                child:user.name.isEmpty||user.name==''||user.name==null||user.name=='null'?Text(user.role=='admin'?'Company':"Member",maxLines: 1,overflow: TextOverflow.ellipsis,style: themeData.textTheme.titleMedium,): Text(user.name??'User',maxLines: 1,overflow: TextOverflow.ellipsis,style: themeData.textTheme.titleMedium,)),
            subtitle: Text(user.email.isEmpty||user.email==null||user.email=='null'?user.phone: user.email,style: themeData.textTheme.bodySmall),

            secondary: SizedBox(
              width: mq.height * .055,
              child: CustomCacheNetworkImage(
                radiusAll: 100,
                user.image,
                height: mq.height * .055,
                width: mq.height * .055,
                boxFit: BoxFit.cover,
                defaultImage: ICON_profile,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          _selectedUserIds.isEmpty ? null : APIs.addMembersToGroup(widget.group.id,_selectedUserIds);
        },
        label:  Text('Add Members',style: themeData.textTheme.titleSmall?.copyWith(color: Colors.white),),
        icon: const Icon(Icons.group_add,color: Colors.white,),
        backgroundColor: appColorGreen,
      ),
    );
  }
}
