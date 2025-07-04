import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/networl_shimmer_image.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Constants/app_theme.dart';
import '../../../Constants/colors.dart';
import '../../../Constants/colors.dart' as AppTheme;
import '../api/apis.dart';
import '../models/chat_user.dart';
import 'chat_screen.dart';

class AllUserScreen extends StatefulWidget {
  const AllUserScreen({super.key});

  @override
  State<AllUserScreen> createState() => _AllUserScreenState();
}

class _AllUserScreenState extends State<AllUserScreen> {
  bool _isSearching = false;
  TextEditingController seacrhCon = TextEditingController();
  String searchQuery = '';

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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,

          title: _isSearching
              ? TextField(
                  controller: seacrhCon,
                  cursorColor: appColorGreen,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search User...',
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      constraints: BoxConstraints(maxHeight: 45)),
                  autofocus: true,
                  style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
                  onChanged: (val) {
                    searchQuery = val;
                    _onSearch(val);
                  },
                ).marginSymmetric(vertical: 10)
              : Text(
                  'Users',
                  style:BalooStyles.balooboldTitleTextStyle(),
                ),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                  color: colorGrey,
                ).paddingOnly(top: 10, right: 10)),
          ],
        ),
        body: StreamBuilder(
          stream: APIs.getAllCompanyUsers(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: const SizedBox());
        
            final docs = snapshot.data!.docs;
        
            final users = docs
                .map((e) => ChatUser.fromJson(e.data()))
                // .where((user) => user.id != APIs.me.id)
                .toList();
            _userList = users;
            final listToShow = searchQuery.isEmpty ? _userList : _filteredList;
        
            return listToShow.isEmpty?SizedBox(
              child: Center(child: Text("No Users Found!"),),
            ): ListView.builder(
              itemCount: listToShow.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemBuilder: (_, i) => ListTile(
                leading: SizedBox(
                  width: 55,
                  child: CustomCacheNetworkImage(
                    listToShow[i].image,
                    // height: 55,
                    radiusAll: 100,
                    borderColor: greyText,
                    boxFit: BoxFit.cover,
                    defaultImage: userIcon,
                  ),
                ),
                title: Text(
                  listToShow[i].id == APIs.me.id
                      ? "Me"
                      : (listToShow[i].name.toString() == 'null'||listToShow[i].name.toString() == ''||listToShow[i].name.toString() == null)
                          ? listToShow[i].phone
                          : listToShow[i].name,
                  style: themeData.textTheme.bodySmall,
                ),
                subtitle: ((listToShow[i].name.toString() == 'null'||listToShow[i].name.toString() == ''||listToShow[i].name.toString() == null) &&
                        listToShow[i].id != APIs.me.id)
                    ? SizedBox()
                    : Text(
                        listToShow[i].email.toString() == 'null'||listToShow[i].email.toString() == ''||listToShow[i].email.toString().isEmpty||listToShow[i].email.toString()==null
                            ? listToShow[i].phone
                            : listToShow[i].email,
                        style: themeData.textTheme.bodySmall
                            ?.copyWith(color: greyText),
                      ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(user: listToShow[i]),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
