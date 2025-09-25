import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_group_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class GroupChatScreen extends GetView<ChatGroupController> {


   GroupChatScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return /*GetBuilder<ChatGroupController>(
      builder: (controller) {
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
                      stream: APIs.getGroupMessages(controller.group?.id??''),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();

                        final docs = snapshot.data!.docs;
                        // controller.messages =
                        //     docs.map((e) => Message.fromJson(e.data())).toList();

                        if (controller.messages.isNotEmpty) {
                          return Container();

                          *//*return ListView.builder(
                            reverse: true,
                            itemCount: controller.messages.length,
                            itemBuilder: (context, index) =>
                                FutureBuilder(
                                    future: APIs.getUserDetailsById(controller.messages[index].fromId),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return const SizedBox();
                                      final ChatUser sender = snapshot.data!;
                                      return SwipeTo(
                                        onRightSwipe: (detail) {
                                          // controller.replyToMessage =  controller.messages[index];
                                          controller.replyToSenderName = sender.name;
                                          controller.update();
                                        },
                                        child: MessageCard(
                                            isTask: false,
                                            message: controller.messages[index],
                                            senderName: (sender.name =='null' ||sender.name==''||sender.name==null)?sender.phone:sender.name,
                                            isGroupMessage: true,
                                            fromId : controller.messages[index].fromId??0
                                        ),
                                      );
                                    }
                                ),
                          );*//*

                        } else {
                          return const Center(
                              child: Text('Say Hii! 👋',
                                  style: TextStyle(fontSize: 20)));
                        }
                      },
                    ),
                  ),
                  if (controller.isUploading)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),

                  if (controller.replyToMessage != null)
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
                                  Text("Replying to ${controller.replyToSenderName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: themeData.textTheme.bodySmall?.copyWith(color: greyText),
                                  ),
                                  Text("${controller.replyToMessage?.msg??''}",
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
                            onPressed: () { controller.replyToMessage = null;
                            controller.update();}),

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
    );*/
     Container();
  }


  /*DashboardController dashboardController = Get.put(DashboardController());
  Widget _buildAppBar() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: (){

            },
            child: Row(
                children: [IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: () {
                    Get.back();

                      isTaskMode=false;
                    controller.update();
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
                        Text(controller.group?.name??'',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        StreamBuilder(
                          stream: APIs.getGroupMembers(controller.group?.id??''),
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
        controller.isAdmin
            ? IconButton(
          icon: Icon(Icons.person_add, color: appColorGreen),
          onPressed: () {
            Get.toNamed(AppRoutes.addGroupMemberRoute,
                arguments: {
                  'groupChat': controller.group
                });
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
                    controller.isUploading = true;
                    controller.update();

                    await APIs.sendChatImageGroup(
                        controller.group!, File(image.path));
                    controller.isUploading = false;
                    controller.update();
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
                    controller.isUploading = true;
                    controller.update();
                    await APIs.sendChatImageGroup(
                        controller.group!, File(i.path));
                    controller.isUploading = false;
                    controller.update();
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


  Future<void> _pickDocument() async {
    final permission = await requestStoragePermission();
    if (!permission) {
      print("❌ Storage permission denied");
      return;
    }

      controller.isUploading = true;
      controller.update();
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

      await APIs.sendGroupMessage(controller.group!, downloadURL, Type.doc);

      controller.isUploading = false;
      controller.update();
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
                              controller: controller.textController,
                              keyboardType: TextInputType.multiline,
                              cursorColor: AppTheme.appColor,
                              maxLines: null,
                              onChanged: (text){
                                if (text.isNotEmpty) {
                                  if(isVisibleUpload){

                                      isVisibleUpload = false;
                                      controller.update();
                                  }
                                } else {
                                  if(!isVisibleUpload){

                                      isVisibleUpload = true;
                                      controller.update();
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
                                onTap: ()=>showUploadOptions(Get.context!),
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
              final text = controller.textController.text.trim();
              if (text.isNotEmpty) {
                APIs.sendGroupMessage(
                  controller.group!, text, Type.text,
                  replyToMsg:  controller.replyToMessage?.msg??'',
                  replyToSenderName:  controller.replyToSenderName,
                  replyToType:  controller.replyToMessage?.type,
                );
                controller.textController.clear();
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
  }*/

}
