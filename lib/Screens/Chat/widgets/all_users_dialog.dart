import 'package:AccuChat/Constants/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Constants/colors.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class AllUserScreenDialog extends StatefulWidget {

  const AllUserScreenDialog({super.key});

  @override
  State<AllUserScreenDialog> createState() => _AllUserScreenDialogState();
}

class _AllUserScreenDialogState extends State<AllUserScreenDialog> {

  bool _isSearching = false;
  TextEditingController seacrhCon = TextEditingController();
  String searchQuery='';

  List<dynamic> _filteredList = [];
  List<dynamic> _userList = [];

  void _onSearch(String query) {
    searchQuery = query.toLowerCase();

    _filteredList = _userList.where((item) {
      if (item is ChatUser) {
        return item.name.toLowerCase().contains(searchQuery) ||
            item.email.toLowerCase().contains(searchQuery);
      } else if (item is ChatGroup) {
        return (item.name ?? '').toLowerCase().contains(searchQuery);
      }
      return false;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      margin: EdgeInsets.symmetric(horizontal: 20,vertical: 30),
      decoration:BoxDecoration(borderRadius: BorderRadius.circular(12),color: Colors.white.withOpacity(.9),) ,
      child: Column(
        children: [
          Row(
            children: [
              _isSearching
                  ? Expanded(
                flex: 4,
                    child: TextField(
                                  controller: seacrhCon,
                                  cursorColor: appColorGreen,
                                  decoration: const InputDecoration(
                      border: InputBorder.none, hintText: 'Search User...',
                      contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 10),
                      constraints: BoxConstraints(maxHeight: 45)
                                  ),
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                                  onChanged: (val) {
                    searchQuery = val;
                    _onSearch(val);
                                  },
                                ).marginSymmetric(vertical: 10),
                  )
                  : Expanded(
                flex: 4,
                    child: Text(
                                  'Forwarded to',
                                  style: TextStyle(
                                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                                ).paddingOnly(left: 8, top: 10),
                  ),
      
              Expanded(
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });
                    },
                    icon: Icon(_isSearching
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.search,
                    color: colorGrey,)
                        .paddingOnly(top: 10,right: 10)),
              ),
            ],
          ),

          StreamBuilder(
              stream:APIs.getAllCompanyUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
      
                final docs = snapshot.data!.docs;
      
                final users = docs
                    .map((e) => ChatUser.fromJson(e.data()))
                    .where((user) => user.id != APIs.me.id)
                    .toList();
                _userList = users;
                final listToShow = searchQuery.isEmpty? _userList : _filteredList;
                return Expanded(
                  child: ListView.builder(
                    itemCount: listToShow.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(listToShow[i].image),
                      ),
                      title: Text(listToShow[i].name.toString()=='null'?'':listToShow[i].name,style: themeData.textTheme.bodySmall,),
                      subtitle: Text(listToShow[i].email.toString()=='null'?listToShow[i].phone:listToShow[i].email
                        ,style: themeData.textTheme.bodySmall?.copyWith(color: greyText),),
                      onTap: () {
                       /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(user: listToShow[i]),
                          ),
                        );
*/
                        Navigator.pop(context, listToShow[i]);
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ).paddingAll(15),
    );

  }
}
