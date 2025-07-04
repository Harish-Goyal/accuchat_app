import 'dart:io';

import 'package:AccuChat/utils/data_not_found.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../Constants/app_theme.dart';
import '../../../Constants/colors.dart' as AppTheme;
import '../../../Constants/colors.dart';
import '../../../main.dart';
import '../../../utils/helper_widget.dart';
import '../models/message.dart';
import '../models/chat_user.dart';
import '../widgets/message_card.dart';
import '../api/apis.dart';

class TaskThreadScreen extends StatefulWidget {
  final Message taskMessage;
  final ChatUser currentUser;

  const TaskThreadScreen({
    super.key,
    required this.taskMessage,
    required this.currentUser,
  });

  @override
  State<TaskThreadScreen> createState() => _TaskThreadScreenState();
}

class _TaskThreadScreenState extends State<TaskThreadScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final conversationId = APIs.getConversationID(widget.taskMessage.fromId);
    final threadId = widget.taskMessage.sent;

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.currentUser.name==''|| widget.currentUser.name=='null'|| widget.currentUser.name==null?widget.currentUser.phone:widget.currentUser.name,
                style: BalooStyles.balooboldTitleTextStyle(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            hGap(15),
            Text(
              "(Threads)",
              style: BalooStyles.baloomediumTextStyle(color: appColorGreen),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width,
              padding: EdgeInsets.all(mq.width * .04),
              margin: EdgeInsets.symmetric(
                  horizontal: mq.width * .05, vertical: mq.height * .01),
              decoration: BoxDecoration(
                  color: getTaskStatusColor(
                          widget.taskMessage.taskDetails?.taskStatus)
                      .withOpacity(.1),
                  border: Border.all(
                      color: getTaskStatusColor(
                          widget.taskMessage.taskDetails?.taskStatus)),
                  //making borders curved
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📝 ${widget.taskMessage.taskDetails?.title}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(widget.taskMessage.taskDetails?.description ?? '',
                      style: themeData.textTheme.bodySmall),
                  if ((widget.taskMessage.taskDetails?.estimatedTime ?? '')
                      .isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                        "⏱️ Est. Time: ${formatTaskTime(widget.taskMessage.taskDetails?.estimatedTime ?? '0', widget.taskMessage.createdAt)}",
                        style: TextStyle(fontSize: 14, color: Colors.red)),
                  ],
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                // stream: APIs.getTaskThreads(widget.taskMessage.fromId,widget.taskMessage.sent),
                stream: APIs.getTaskThreads(
                    widget.currentUser.id, widget.taskMessage.sent),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: SizedBox());
                  }
                  final data = snapshot.data!.docs;
                  final threadMessages =
                      data.map((e) => Message.fromJson(e.data())).toList();
                  return threadMessages.isNotEmpty
                      ? ListView.builder(
                          reverse: true,
                          itemCount: threadMessages.length,
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: threadMessages[index],
                              senderName: widget.currentUser.name,
                              isGroupMessage: false,
                              fromId: widget.currentUser.id,
                              isTask: false,
                              isForward: true,
                            );
                          },
                        )
                      : SizedBox(height: 33, child: DataNotFoundText());
                },
              ),
            ),

            if (_isUploading)
              const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2))),
            _chatInput(),
          ],
        ),
      ),
    );
  }
  bool isVisibleUpload = true;
  Widget _chatInput() {
    ThemeData themeData = Theme.of(context);
    return Container(
      // height: Get.height*.4,
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //input field & buttons
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: Get.height * .4, minHeight: 45),
                      child: Container(
                        // color: Colors.red,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color:appColorGreen .withOpacity(.2))
                        ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _msgController,
                              keyboardType: TextInputType.multiline,
                              cursorColor: AppTheme.appColor,
                              maxLines: null,
                              onChanged: (text) {},
                              onTap: () {
                                // if (_showEmoji)
                                //   setState(() => _showEmoji = !_showEmoji);
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
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          hGap(6),
          InkWell(
            onTap: () {
              _sendThreadMessage();
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
                    await APIs.sendChatImageThread(widget.currentUser,File(image.path),widget.taskMessage.sent);
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

                    await APIs.sendChatImageThread(widget.currentUser,File(i.path),widget.taskMessage.sent);

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
      final result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        _pickDocument();
      } else if (result.isPermanentlyDenied) {
        await openAppSettings();
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

  bool _isUploading = false;
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


      APIs.sendThreadMessage(
        conversationId: widget.currentUser.id,
        taskMessageId: widget.taskMessage.sent,
        chatUser: widget.currentUser,
        msg: downloadURL,
        type: Type.doc,);
      setState(() {
        _isUploading = false;
      });
      print("✅ Document Uploaded: $downloadURL");
    }
  }

  void _sendThreadMessage() async {
    final text = _msgController.text;
    if (text.isEmpty) return;
    APIs.sendThreadMessage(
        conversationId: widget.currentUser.id,
        taskMessageId: widget.taskMessage.sent,
        chatUser: widget.currentUser,
        msg: text,
        type: Type.text,);

    _msgController.clear();
  }
}
