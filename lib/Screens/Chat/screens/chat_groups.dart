import 'dart:io';
import 'package:AccuChat/Constants/app_theme.dart';
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Chat/widgets/show_groups_members_screen.dart';
import 'package:AccuChat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../Constants/colors.dart' as AppTheme;
import '../../../utils/helper_widget.dart';
import '../../Home/Presentation/Controller/home_controller.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'add_group_members_screens.dart';

class GroupChatScreen extends StatefulWidget {
  final ChatGroup group;

  const GroupChatScreen({super.key, required this.group});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List<Message> _messages = [];
  final _textController = TextEditingController();
  bool _isUploading = false;
  bool _isAdmin = false;
  File? _file;
  Message? _replyToMessage;
 var _replyToSenderName ='';
  Future<void> _checkIfAdmin() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.id)
          .get();
      final data = doc.data();
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      if (data != null && data['admins'] != null && currentUid != null) {
        final List admins = data['admins'];
        setState(() {
          _isAdmin = admins.contains(currentUid);
        });
      }
    } catch (e, s) {
      print('Error checking admin: $e');
      print('Stack: $s');
    }
  }

  @override
  void initState() {
    _checkIfAdmin();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _buildAppBar(),
          ),
          backgroundColor: const Color.fromARGB(255, 234, 248, 255),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getGroupMessages(widget.group.id??''),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final docs = snapshot.data!.docs;
                    _messages =
                        docs.map((e) => Message.fromJson(e.data())).toList();

                    if (_messages.isNotEmpty) {

                          return ListView.builder(
                            reverse: true,
                            itemCount: _messages.length,
                            itemBuilder: (context, index) =>
                                FutureBuilder(
                                    future: APIs.getUserDetailsById(_messages[index].fromId),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return const SizedBox();
                                      final ChatUser sender = snapshot.data!;
                                    return SwipeTo(
                                        onRightSwipe: (detail) {
                                          _replyToMessage =  _messages[index];
                                          _replyToSenderName = sender.name;
                                          setState(() {

                                          });
                                        },
                                      child: MessageCard(
                                        isTask: false,
                                        message: _messages[index],
                                        senderName: (sender.name =='null' ||sender.name==''||sender.name==null)?sender.phone:sender.name,
                                        isGroupMessage: true,
                                        fromId :  _messages[index].fromId
                                      ),
                                    );
                                  }
                                ),
                          );

                    } else {
                      return const Center(
                          child: Text('Say Hii! 👋',
                              style: TextStyle(fontSize: 20)));
                    }
                  },
                ),
              ),
              if (_isUploading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),

              if (_replyToMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 4,left: 8,right: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.2),
                    border: Border.all(color: lightgreyText),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.reply, color: appColorGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Replying to ${_replyToSenderName}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: themeData.textTheme.bodySmall?.copyWith(color: greyText),
                              ),
                              Text("${_replyToMessage?.msg??''}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: themeData.textTheme.bodySmall?.copyWith(color: greyText),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon:  const Icon(Icons.close,color: blueColor,),
                        onPressed: () => setState(() => _replyToMessage = null),
                      )
                    ],
                  ),
                ),

              _chatInput(),
            ],
          ),
        ),
      ),
    );
  }
  DashboardController dashboardController = Get.put(DashboardController());
  Widget _buildAppBar() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: (){
              Get.to(()=>GroupMembersScreen(group: widget.group));
            },
            child: Row(
                children: [IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () {
                Get.back();
                setState(() {
                  isTaskMode=false;
                });
                dashboardController.updateIndex(1);

              },
            ),
            const CircleAvatar(
              backgroundImage: AssetImage(groupIcn),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.group.name??'',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  StreamBuilder(
                    stream: APIs.getGroupMembers(widget.group.id??''),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final members = snapshot.data!.docs
                          .map((e) => e['name'] ?? '')
                          .join(', ');
                      return Text("Members: $members",
                          style: themeData.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                          ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  )
                ],
              ),
            ),]),
          ),
        ),
        _isAdmin
            ? IconButton(
                icon: Icon(Icons.person_add, color: appColorGreen),
                onPressed: () {
                  Get.to(() => AddGroupMembersScreen(group: widget.group));
                },
              )
            : SizedBox()
      ],
    );
  }


  void showUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16,left: 15,right: 15,bottom: 60),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: ()async {
                  Get.back();
                  final ImagePicker picker = ImagePicker();
                  // Pick an image
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 50);
                  if (image != null) {
                    print('Image Path: ${image.path}');
                    setState(() => _isUploading = true);

                    await APIs.sendChatImageGroup(
                        widget.group, File(image.path));
                    setState(() => _isUploading = false);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Gallery"),
                onTap: () async{
                  Get.back();
                  final ImagePicker picker = ImagePicker();

                  // Picking multiple images
                  final List<XFile> images =
                  await picker.pickMultiImage(imageQuality: 50);

                  // uploading & sending image one by one
                  for (var i in images) {
                    print('Image Path: ${i.path}');
                    setState(() => _isUploading = true);
                    await APIs.sendChatImageGroup(
                        widget.group, File(i.path));
                    setState(() => _isUploading = false);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text("Document"),
                onTap: (){
                  Get.back();
                  _pickDocument();
                } ,
              ),
            ],
          ),
        ),
      ),
    );
  }

/*  Future<void> requestStoragePermission() async {
    if (Platform.isAndroid && await Permission.manageExternalStorage.isGranted) {
      _pickDocument();
    } else if (Platform.isAndroid) {
      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        _pickDocument();
      } else if (result.isPermanentlyDenied) {
        await openAppSettings();
      }else if (result.isDenied) {
        result= await Permission.manageExternalStorage.request();
      } else {
        print("❌ Storage permission denied again");
      }
    } else {
      // For iOS or other platforms
      final result = await Permission.storage.request();
      if (result.isGranted) {
        _pickDocument();
      } else {
        print("❌ Storage permission denied again");
      }
    }

  }*/


  Future<void> _pickDocument() async {
    final permission = await requestStoragePermission();
    if (!permission) {
      print("❌ Storage permission denied");
      return;
    }
    setState(() {
      _isUploading = true;
    });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'txt',
        'xls', 'xlsx', 'csv', // Excel formats
        'xml', 'json', // markup/data formats
        // 'exe', 'apk', // executable formats (⚠️ be cautious)
        'ppt', 'pptx', // PowerPoint
        'zip', 'rar', // Archives
      ],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var ext = file.path.split('.').last;
      final fileName = 'DOC_${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final ref = FirebaseStorage.instance.ref().child('media/docs/$fileName');

      await ref.putFile(file,SettableMetadata(contentType: 'media/$ext'));
      final downloadURL = await ref.getDownloadURL();

      await APIs.sendGroupMessage(widget.group, downloadURL, Type.doc);
      setState(() {
        _isUploading = false;
      });
      print("✅ Document Uploaded: $downloadURL");
    }
  }

  bool isVisibleUpload =true;
  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: Get.height * .4, minHeight: 45),
                    child:Container(
                      // color: Colors.red,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: appColorGreen.withOpacity(.2))
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _textController,
                              keyboardType: TextInputType.multiline,
                              cursorColor: AppTheme.appColor,
                              maxLines: null,
                        onChanged: (text){
                          if (text.isNotEmpty) {
                            if(isVisibleUpload){
                              setState(() {
                                isVisibleUpload = false;
                              });
                            }
                          } else {
                            if(!isVisibleUpload){
                              setState(() {
                                isVisibleUpload = true;
                              });
                            }
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Type Something...',
                          hintStyle: themeData.textTheme.bodySmall,
                          contentPadding: const EdgeInsets.all(8),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                          ),

                          Visibility(
                          visible: isVisibleUpload,
                          child: InkWell(
                          onTap: ()=>showUploadOptions(context),
                          child: Icon(Icons.upload_outlined,color: Colors.black54,),
                          ).paddingAll(3)


                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          InkWell(
            onTap: () {
              final text = _textController.text.trim();
              if (text.isNotEmpty) {
                APIs.sendGroupMessage(
                    widget.group, text, Type.text,
                  replyToMsg: _replyToMessage?.msg??'',
                  replyToSenderName: _replyToSenderName,
                  replyToType: _replyToMessage?.type,
                );
                _textController.clear();
              }
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: appColorGreen,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
