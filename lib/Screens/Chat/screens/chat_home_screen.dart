import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../Constants/app_theme.dart';
import '../../../main.dart';
import '../../../utils/common_textfield.dart';
import '../../../utils/custom_dialogue.dart';
import '../../../utils/custom_flashbar.dart';
import '../../../utils/gradient_button.dart';
import '../../../utils/helper_widget.dart';
import '../../../utils/text_style.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import '../widgets/broad_cast_card.dart';
import '../widgets/chat_group_card.dart';
import '../widgets/chat_user_card.dart';
import 'all_users_screen.dart';
import 'create_broadcast_dialog_screen.dart';

class ChatsHomeScreen extends StatefulWidget {
  ChatsHomeScreen({super.key, isTask});

  bool isTask = false;

  @override
  State<ChatsHomeScreen> createState() => _ChatsHomeScreenState();
}

class _ChatsHomeScreenState extends State<ChatsHomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];
  List<ChatGroup> _grouplist = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;
  TextEditingController seacrhCon = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      // log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  TextEditingController groupController = TextEditingController();
  List<dynamic> mergedList = [];
  List<dynamic> _filteredList = [];
  Future<List<dynamic>> getMergedSortedChats2({
    required List<DocumentSnapshot> groupDocs,
    required List<DocumentSnapshot> userDocs,
    required List<DocumentSnapshot> broadcastDoc,
  }) async {
    final List<dynamic> merged = [];

    final groupFutures = groupDocs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final group = ChatGroup.fromJson(data);

      // fallback to createdAt if no lastMessageTime
      group.lastMessageTime = group.lastMessageTime ?? group.createdAt ?? '0';

      if ((group.members ?? []).contains(APIs.me.id)) {
        merged.add(group);
      }
    });

    final userFutures = userDocs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final user = ChatUser.fromJson(data);

      // fallback to 0 if no lastActive
      user.lastActive = user.lastActive ?? '0';

      merged.add(user);
    });

    await Future.wait([...groupFutures, ...userFutures]);

    merged.sort((a, b) {
      final aTime = int.tryParse(a.lastMessageTime ?? a.lastActive ?? '0') ?? 0;
      final bTime = int.tryParse(b.lastMessageTime ?? b.lastActive ?? '0') ?? 0;
      return bTime.compareTo(aTime);
    });

    return merged;
  }

  Future<List<dynamic>> getMergedSortedChats({
    required List<DocumentSnapshot> groupDocs,
    required List<DocumentSnapshot> userDocs,
    required List<DocumentSnapshot> broadcastDocs,
  }) async {
    final List<dynamic> merged = [];

    // Add groups
    final groupFutures = groupDocs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final group = ChatGroup.fromJson(data);
      group.lastMessageTime = group.lastMessageTime ?? group.createdAt ?? '0';

      if ((group.members ?? []).contains(APIs.me.id)) {
        merged.add(group);
      }
    });

    // Add 1-1 users
    final userFutures = userDocs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final user = ChatUser.fromJson(data);
      user.lastActive = user.lastActive ?? '0';
      merged.add(user);
    });

    // Add broadcasts
    final broadcastFutures = broadcastDocs.map((doc) async {
      final data = doc.data() as Map<String, dynamic>;
      final broadcast = BroadcastChat.fromJson(data);
      broadcast.lastMessageTime =
          broadcast.lastMessageTime ?? broadcast.createdAt ?? '0';
      if (broadcast.createdBy == APIs.me.id) {
        merged.add(broadcast);
      }
    });

    await Future.wait([...groupFutures, ...userFutures, ...broadcastFutures]);

    /*   // Sort
    merged.sort((a, b) {
      final aTime = int.tryParse(a.lastMessageTime ?? a.lastActive ?? '0') ?? 0;
      final bTime = int.tryParse(b.lastMessageTime ?? b.lastActive ?? '0') ?? 0;
      return bTime.compareTo(aTime);
    });*/

    merged.sort((a, b) {
      int getTime(dynamic item) {
        if (item is ChatUser)
          return item.lastActive is int
              ? item.lastActive
              : int.tryParse(item.lastActive.toString()) ?? 0;
        if (item is ChatGroup || item is BroadcastChat) {
          return item.lastMessageTime is int
              ? item.lastMessageTime
              : int.tryParse(item.lastMessageTime.toString()) ?? 0;
        }
        return 0;
      }

      return getTime(b).compareTo(getTime(a));
    });
    return merged;
  }

  DashboardController dashboardController = Get.put(DashboardController());

  void _onSearch(String query) {
    searchQuery = query.toLowerCase();

    _filteredList = mergedList.where((item) {
      if (item is ChatUser) {
        return item.name.toLowerCase().contains(searchQuery) ||
            item.email.toLowerCase().contains(searchQuery);
      } else if (item is ChatGroup) {
        return (item.name ?? '').toLowerCase().contains(searchQuery);
      } else if (item is BroadcastChat) {
        return (item.name ?? '').toLowerCase().contains(searchQuery);
      }
      return false;
    }).toList();

    setState(() {}); // ❗️Ensure UI updates
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        onWillPop: () {
          // if (_isSearching) {
          //   setState(() {
          //     _isSearching = !_isSearching;
          //   });
          //   return Future.value(false);
          // } else {
          //   return Future.value(true);
          // }
          return Future.value(true);
        },
        child: Scaffold(
          //app bar
          // backgroundColor: isTaskMode?appColorYellow.withOpacity(.05):Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _isSearching
                ? TextField(
                    controller: seacrhCon,
                    cursorColor: appColorGreen,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search User, Group & Collection ...',
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
                : Column(
              mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       isTaskMode?"Tasks": 'Chats',
                        style: BalooStyles.balooboldTitleTextStyle(
                            color: isTaskMode?appColorYellow: AppTheme.appColor,size: 18),
                      ).paddingOnly(left: 8, top: 8),
                      Row(

                        children: [
                          Image.asset(connectedAppIcon,height: 15,color: AppTheme.redErrorColor,),
                          hGap(8),
                          Text(
                           APIs.me.selectedCompany?.name??'',
                            style: BalooStyles.balooregularTextStyle(
                              color: AppTheme.redErrorColor,),
                          ),
                        ],
                      ).paddingOnly(left: 8, top: 5),


                     /* Transform.scale(
                        scale: .7,
                        child: CupertinoSwitch(
                          value: isTaskMode,
                          activeColor: appColorGreen,
                          onChanged: (val) {
                            setState(() {
                              isTaskMode = val;
                            });
                            if (isTaskMode) {
                              dashboardController.updateIndex(2);
                            } else {
                              dashboardController.updateIndex(1);
                            }
                          },
                        ),
                      ),*/
                    ],
                  ),
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                          ? CupertinoIcons.clear_circled_solid
                          : Icons.search)
                      .paddingOnly(top: 10, right: 10)),

              isTaskMode?SizedBox():   PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                menuPadding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'new_group') {
                    showDialog(
                        context: Get.context!,
                        builder: (_) => _groupDialogWidget());
                  } else if (value == 'new_broadcast') {
                    showDialog(
                        context: Get.context!,
                        builder: (_) => BroadcastCreateDialog());
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'new_group',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.group,
                          size: 17,
                          color: appColorGreen,
                        ),
                        hGap(5),
                        Text(
                          'Create Group',
                          style: themeData.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'new_broadcast',
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Image.asset(
                        broadcastIcon,
                        height: 15,
                        color: appColorYellow,
                      ),
                      hGap(5),
                      Text(
                        'Create Broadcast',
                        style: themeData.textTheme.bodySmall,
                      )
                    ]),
                  ),
                ],
                color: Colors.white,
                icon: const Icon(Icons.more_vert),
              ),
              //more features button
              /*IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: const Icon(Icons.person))*/
            ],
          ),

          //floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
                onPressed: () {
                  // _addChatUserDialog();
                  Get.to(() => const AllUserScreen());
                },
                backgroundColor:isTaskMode?appColorYellow: appColorGreen,
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                )),
          ),

          //body
          /*  body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            //get id of only known users
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());

                //if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),

                    //get only those user, who's ids are provided
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        // return const Center(
                        //     child: CircularProgressIndicator());

                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty&&_list!=[]) {
                            return ListView.builder(
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                padding: EdgeInsets.only(top: mq.height * .02),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return const Center(
                              child: Text('No Data Found!',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),*/

          body: /*StreamBuilder(
            stream: APIs.getGroups(), // ✅ Group stream added
            builder: (context, groupSnapshot) {
              if (groupSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final groupDocs = groupSnapshot.data?.docs ?? [];
              _grouplist = groupDocs
                  .map((e) => ChatGroup.fromJson(e.data()))
                  .toList();
              return StreamBuilder(
                stream: APIs.getMyUsersId(),
                builder: (context, idSnapshot) {
                  switch (idSnapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                        stream: APIs.getAllUsers(
                            idSnapshot.data?.docs.map((e) => e.id).toList() ??
                                []),
                        builder: (context, userSnapshot) {
                          switch (userSnapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final userDocs = userSnapshot.data?.docs ?? [];
                              _list = userDocs
                                  .map((e) => ChatUser.fromJson(e.data()))
                                  .toList();

                              return ListView(
                                // padding: EdgeInsets.only(top: mq.height * .02),
                                physics: const BouncingScrollPhysics(),

                                children: [

                                  ...groupDocs.map((doc) {
                                    final group =
                                        ChatGroup.fromJson(doc.data());
                                    return
                                      (group.members??[]).isNotEmpty ||(group.members??[]).contains(APIs.me.id)?

                                      ChatGroupCard(user: group,):SizedBox();
                                  }),

                                  // 🔹 User Tiles
                                  ...List.generate(
                                    _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    (index) => ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index],
                                    ),
                                  ),

                                  // 🔹 If nothing found
                                  if (_list.isEmpty && groupDocs.isEmpty)
                                    const Center(
                                      child: Text('No Data Found!',
                                          style: TextStyle(fontSize: 20)),
                                    ),
                                ],
                              );
                          }
                        },
                      );
                  }
                },
              );
            },
          ),*/
              /* StreamBuilder(
            stream: APIs.getGroups(),
            builder: (context, groupSnapshot) {
              if (!groupSnapshot.hasData) {
                return SizedBox();
              }

              final groupDocs = groupSnapshot.data!.docs;

              return StreamBuilder(
                stream: APIs.getMyUsersId(),
                builder: (context, idSnapshot) {
                  final userIds =
                      idSnapshot.data?.docs.map((e) => e.id).toList() ?? [];

                  return StreamBuilder(
                    stream: APIs.getAllUsers(userIds),
                    builder: (context, userSnapshot) {
                      final userDocs = userSnapshot.data?.docs ?? [];

                      return FutureBuilder(
                        future: getMergedSortedChats(
                          groupDocs: groupDocs,
                          userDocs: userDocs,
                        ),
                        builder: (context, snapshot) {
                          // if (snapshot.connectionState == ConnectionState.waiting) {
                          //   return SizedBox();
                          // }

                          // if (snapshot.hasError) {
                          //   // return Center(child: Text('Error: ${snapshot.error}'));
                          //   return SizedBox();
                          // }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return SizedBox();
                            // return const Center(child: Text('No chats found'));
                          }

                          mergedList = snapshot.data!;

                          print("🟢 Rendering merged list of ${mergedList.length}");
                          final listToShow = searchQuery.isEmpty? mergedList : _filteredList;
                          return ListView.builder(
                            itemCount: listToShow.length,
                            itemBuilder: (context, index) {
                              final item = listToShow[index];

                              if (item is ChatGroup) {
                                return ChatGroupCard(user: item);
                              } else if (item is ChatUser) {
                                return ChatUserCard(user: item);
                              } else {
                                print("⚠️ Unknown type at index $index");
                                return const SizedBox();
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ).paddingSymmetric(vertical: 10)*/
              StreamBuilder(
            stream: APIs.getGroups(),
            builder: (context, groupSnapshot) {
              final groupDocs = groupSnapshot.data?.docs ?? [];

              return StreamBuilder(
                stream: APIs.getBroadcast(),
                builder: (context, broadcastSnapshot) {
                  final broadcastDocs = broadcastSnapshot.data?.docs ?? [];

                  return StreamBuilder(
                    stream: APIs.getMyUsersId(),
                    builder: (context, idSnapshot) {
                      final userIds =
                          idSnapshot.data?.docs.map((e) => e.id).toList() ?? [];

                      return StreamBuilder(
                        // stream: APIs.getAllUsers(userIds),
                        stream: APIs.getCompanyUsers(userIds),
                        builder: (context, userSnapshot) {
                          final userDocs = userSnapshot.data?.docs ?? [];

                          return FutureBuilder(
                            future: getMergedSortedChats(
                              groupDocs: groupDocs,
                              userDocs: userDocs,
                              broadcastDocs: broadcastDocs,
                            ),
                            builder: (context, snapshot) {
                              // if (snapshot.connectionState == ConnectionState.waiting) {
                              //   return SizedBox();
                              // }
                              //
                              // if (snapshot.hasError) {
                              //   return Center(child: Text('Error: ${snapshot.error}'));
                              //   // return SizedBox();
                              // }

                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text("No chats found"));
                              }

                              mergedList = snapshot.data!;
                              final listToShow = searchQuery.isEmpty
                                  ? mergedList
                                  : _filteredList;

                              return ListView.builder(
                                itemCount: listToShow.length,
                                itemBuilder: (context, index) {
                                  final item = listToShow[index];
                                  if (item is ChatGroup){
                                    return isTaskMode?SizedBox():ChatGroupCard(user: item);}
                                  if (item is ChatUser) {
                                    return SwipeTo(
                                        iconOnLeftSwipe: Icons.delete_outline,
                                        iconColor: Colors.red,
                                        onLeftSwipe: (detail)async {


                                          final confirm = await showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              backgroundColor: Colors.white,
                                              title: Text(
                                                  "Remove ${item.email == 'null' || item.email == null || item.email == '' ? item.phone : item.email}"),
                                              content: const Text(
                                                  "Are you sure you want to remove this member from recants?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, false),
                                                    child: const Text("Cancel")),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context, true),
                                                    child: Text(
                                                      "Remove",
                                                      style: BalooStyles
                                                          .baloosemiBoldTextStyle(
                                                          color: Colors.red),
                                                    )),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            customLoader.show();

                                            await APIs.deleteRecantUserAndChat(item.id);
                                            customLoader.hide();
                                            setState(() {

                                            });

                                          }
                                        },
                                        child: ChatUserCard(user: item));
                                  }
                                  if (item is BroadcastChat) {
                                    return isTaskMode?SizedBox():BroadcastCard(
                                        chat: item); // 🔥 create this
                                  }
                                  return const SizedBox();
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ).paddingSymmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }




  _groupDialogWidget() {
    return CustomDialogue(
      title: "Create Group",
      isShowAppIcon: false,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Enter group name to create Group",
            style: BalooStyles.baloonormalTextStyle(),
            textAlign: TextAlign.center,
          ),
          /*    vGap(20),
            Container(
              width: Get.width,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Type',
                  hintText: 'Select Type',
                  hintStyle:
                  BalooStyles.baloonormalTextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400)),
                  labelStyle: BalooStyles.baloonormalTextStyle(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedGroupType,
                    hint: Text(
                      "Select Type",
                      style: BalooStyles.baloomediumTextStyle(),
                    ),
                    items: ["Group", "Collection"]
                        .map((String type) => DropdownMenuItem<String>(
                      value: type,
                      child: SizedBox(
                          width: Get.width * .52,
                          child: Text(
                            type,
                            style: BalooStyles.baloomediumTextStyle(),
                          )),
                    ))
                        .toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedGroupType = newValue;
                        controller.update();
                      }
                    },
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
            ),*/
          vGap(20),
          CustomTextField(
            hintText: "Group Name",
            controller: groupController,
            focusNode: FocusNode(),
            onFieldSubmitted: (String? value) {
              FocusScope.of(Get.context!).unfocus();
            },
            labletext: "Group Name",
          ),
          vGap(30),
          GradientButton(
            name: "Submit",
            btnColor: AppTheme.appColor,
            vPadding: 8,
            onTap: () {
              if (groupController.text.isNotEmpty) {
                APIs.createGroup(
                    name: groupController.text.toString(),
                    createdById: APIs.me.id,
                  companyId: APIs.me.selectedCompany?.id??''
                );
              } else {
                errorDialog("Please enter group name");
              }
            },
          )
        ],
      ),
      onOkTap: () {},
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
