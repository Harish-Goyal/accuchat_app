import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Constants/app_theme.dart';
import '../../../Constants/assets.dart';
import '../../../utils/custom_dialogue.dart';
import '../../../utils/networl_shimmer_image.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';


class BroadcastCreateDialog extends StatefulWidget {
  const BroadcastCreateDialog({super.key});

  @override
  State<BroadcastCreateDialog> createState() => _BroadcastCreateDialogState();
}

class _BroadcastCreateDialogState extends State<BroadcastCreateDialog> {
  final TextEditingController _nameController = TextEditingController();
  List<ChatUser> _allUsers = [];
  final Set<String> _selectedUserIds = {};
  final String _currentUid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users')
        .where('selectedCompany.id', isEqualTo: APIs.me.selectedCompany?.id)
        .get();
    final all = snapshot.docs.map((e) => ChatUser.fromJson(e.data())).toList();
    all.removeWhere((user) => user.id == _currentUid);
    setState(() => _allUsers = all);
  }

  Future<void> _createBroadcast() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedUserIds.isEmpty) {
      toast("Name and at least one member required");
      return;
    }

    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final docRef = FirebaseFirestore.instance.collection('broadcasts').doc();

    final broadCast = BroadcastChat(
      id: docRef.id,
      name: name,
      image: '',
      companyId: APIs.me.selectedCompany?.id??'',
      createdBy: _currentUid,
      createdAt: time,
      lastMessage: '',
      lastMessageTime: time,
      members: _selectedUserIds.toList(),
    );

    await docRef.set(broadCast.toJson());

    toast("Broadcast created successfully");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text('New Broadcast',style:themeData.textTheme.titleSmall),
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      content: SizedBox(
        width: double.maxFinite,
        height: Get.height*.55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Broadcast Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _allUsers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final user = _allUsers[index];
                  final isSelected = _selectedUserIds.contains(user.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SizedBox(
                      width: 55,
                      child: CustomCacheNetworkImage(user.image,radiusAll: 100,height: 75,defaultImage: userIcon,
                        borderColor: greyColor,),
                    ),
                    title: Text(user.name=='null'||user.name==''||user.name==null?
                      user.phone:user.name,
                      style:themeData.textTheme.bodyMedium,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    subtitle: Text((user.email=='null'||user.email==''||user.email==null && (user.name!='null'||user.name==''||user.name))?
                    user.phone:user.email,style:themeData.textTheme.bodySmall,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.radio_button_unchecked),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedUserIds.remove(user.id);
                        } else {
                          _selectedUserIds.add(user.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:  Text('Cancel',style:themeData.textTheme.bodySmall?.copyWith(color: Colors.white)),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(appColorYellow),
            padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 3,horizontal: 15))
          ),
        ),

        dynamicButton(
            name: "Create",
            onTap: _createBroadcast,
            btnColor: appColorYellow,
            isShowText: true,
            isShowIconText: true,
            gradient: LinearGradient(colors:[appColorYellow,appColorYellow]),
            iconColor: Colors.white,
            leanIcon: broadcastIcon)

      ],
    );
  }
}
