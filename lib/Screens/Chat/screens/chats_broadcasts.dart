import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Constants/app_theme.dart';
import '../../../Constants/colors.dart' as AppTheme;
import '../../../main.dart';
import '../../../utils/helper_widget.dart';
import '../../Home/Presentation/Controller/home_controller.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/Show_broadcasts_member_screen.dart';
import '../widgets/message_card.dart';
import '../widgets/show_groups_members_screen.dart';
import 'add_broadcasts_member_screen.dart';
import 'add_group_members_screens.dart';

class BroadcastChatScreen extends StatefulWidget {
  final BroadcastChat chat;

  const BroadcastChatScreen({super.key, required this.chat});

  @override
  State<BroadcastChatScreen> createState() => _BroadcastChatScreenState();
}

class _BroadcastChatScreenState extends State<BroadcastChatScreen> {
  List<Message> _messages = [];
  final _textController = TextEditingController();
  bool _isUploading = false;

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
          body: Container(
            decoration: BoxDecoration(
              color: appColorPerple.withOpacity(.01),
              image: DecorationImage(
                  image: AssetImage(broadcastIcon),
                opacity: .02,
                fit: BoxFit.cover,
              )
            ),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getBroadcastMessages(widget.chat.id??''),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final docs = snapshot.data!.docs;
                      _messages =docs.map((e) => Message.fromJson(e.data())).toList();
                      if (_messages.isNotEmpty) {
                        return ListView.builder(
                          reverse: true,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => FutureBuilder(
                            future: APIs.getUserDetailsById(
                                _messages[index].fromId),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox();
                              final ChatUser sender = snapshot.data!;
                              return MessageCard(
                                message: _messages[index],
                                isTask: false,
                                senderName: sender.name,
                                isGroupMessage: true,
                                fromId: _messages[index].fromId,
                              );
                            },
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text('Say Hii! 👋',
                              style: TextStyle(fontSize: 20)),
                        );
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),

                _chatInput(),
              ],
            ),
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
              Get.to(()=>BroadcastsMembersScreen(chat: widget.chat));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                   Container(
                     height: 50,
                    width: 40,
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade50
                    ),
                    child: Image.asset(broadcastIcon,height: 15,fit: BoxFit.contain,),
                  ).paddingAll(8),
                  const SizedBox(width: 0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.chat.name??'',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        StreamBuilder(
                          stream: APIs.getBroadcastsMembers(widget.chat.id??''),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();
                            final members = snapshot.data!.docs
                                .map((e) => e['name'] ?? '')
                                .join(', ');
                            return Text("Members: $members",
                                style: const TextStyle(fontSize: 13),maxLines: 1,overflow: TextOverflow.ellipsis,);
                          },
                        )
                      ],
                    ),
                  ),]),
          ),
        ),
         IconButton(
          icon: Icon(Icons.person_add, color: appColorGreen),
          onPressed: () {
            Get.to(() => AddBroadcastsMembersScreen(chat: widget.chat));
          },
        )

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

                    await APIs.sendChatImageBroadcast(
                        widget.chat, File(image.path));
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
                    await APIs.sendChatImageBroadcast(
                        widget.chat, File(i.path));
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
/*
  Future<void> requestStoragePermission() async {
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

      await APIs.sendBroadcastMessage(widget.chat, downloadURL, Type.doc);
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
                APIs.sendBroadcastMessage(widget.chat, text, Type.text);
                _textController.clear();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
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
