import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Constants/assets.dart';
import '../../../utils/networl_shimmer_image.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';

class AddBroadcastsMembersScreen extends StatefulWidget {
  final BroadcastChat chat;

  const AddBroadcastsMembersScreen({super.key, required this.chat});

  @override
  State<AddBroadcastsMembersScreen> createState() =>
      _AddBroadcastsMembersScreenState();
}

class _AddBroadcastsMembersScreenState
    extends State<AddBroadcastsMembersScreen> {
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
          .collection('broadcasts')
          .doc(widget.chat.id)
          .get();

      final groupData = groupDoc.data();
      final List<String> memberIds =
          List<String>.from(groupData?['members'] ?? []);

      final snapshot =
          await FirebaseFirestore.instance.collection('users')
              .where('selectedCompany.id', isEqualTo: APIs.me.selectedCompany?.id)
              .get();
      final allUsers =
          snapshot.docs.map((e) => ChatUser.fromJson(e.data())).toList();

      final filteredUsers =
          allUsers.where((user) => !memberIds.contains(user.id)).toList();

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
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title:  Text('Add Broadcasts Members',style: themeData.textTheme.titleMedium,)),
      body: _isLoding
          ? IndicatorLoading()
          : _allUsers.isEmpty
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
                      activeColor: appColorPerple,
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
                          width: Get.width * .4,
                          child: Text(
                            user.name=='null'||user.name==''||user.name==null?
                            user.phone:user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: themeData.textTheme.titleMedium,
                          )),
                      subtitle: Text((user.email=='null'||user.email==''||user.email==null && (user.name!='null'||user.name==''||user.name))?
                      user.phone:user.email,style: themeData.textTheme.bodySmall,),
                      secondary: SizedBox(
                        width: 55,
                        child: CustomCacheNetworkImage(user.image,radiusAll: 100,height: 75,defaultImage: userIcon,
                          borderColor: greyColor,),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _selectedUserIds.isEmpty
              ? null
              : APIs.addMemberToBroadcast(widget.chat.id, _selectedUserIds);
        },
        label: Text(
          'Add Members',
          style: themeData.textTheme.titleSmall?.copyWith(color: Colors.white),
        ),
        icon: const Icon(
          Icons.group_add,
          color: Colors.white,
        ),
        backgroundColor: appColorPerple,
      ),
    );
  }
}
