import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/chats_broadcasts_controller.dart';

class BroadcastChatScreen extends GetView<ChatsBroadcastsController> {


   BroadcastChatScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return /*GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: GetBuilder<ChatsBroadcastsController>(
          builder: (controller) {
            return Scaffold(
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
                        stream: APIs.getBroadcastMessages(controller.chat?.id??''),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final docs = snapshot.data!.docs;
                          controller.messages =docs.map((e) => Message.fromJson(e.data())).toList();
                          if (controller.messages.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: controller.messages.length,
                              itemBuilder: (context, index) => FutureBuilder(
                                future: APIs.getUserDetailsById(
                                    controller.messages[index].fromId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const SizedBox();
                                  final ChatUser sender = snapshot.data!;
                                  return MessageCard(
                                    message: controller.messages[index],
                                    isTask: false,
                                    senderName: sender.name,
                                    isGroupMessage: true,
                                    fromId: controller.messages[index].fromId,
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
                    if (controller.isUploading)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),

                    _chatInput(),
                  ],
                ),
              ),
            );
          }
        ),
      ),
    )*/Container();
  }
/*  DashboardController dashboardController = Get.put(DashboardController());
  Widget _buildAppBar() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: (){
              Get.to(()=>BroadcastsMembersScreen(chat: controller.chat!));
            },
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                  onPressed: () {
                    Get.back();

                      isTaskMode=false;
                    controller.update();
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
                        Text(controller.chat?.name??'',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        StreamBuilder(
                          stream: APIs.getBroadcastsMembers(controller.chat?.id??''),
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
            Get.toNamed(AppRoutes.addBroadcastsMemberRoute,
                arguments: {
                  'broadcastChat': controller.chat
                });
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

                    controller.isUploading = true;
                    controller.update();
                    await APIs.sendChatImageBroadcast(
                        controller.chat!, File(image.path));
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
                    controller.isUploading = true;
                    controller.update();
                    await APIs.sendChatImageBroadcast(
                        controller.chat!, File(i.path));
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

                  controller.pickDocument();
                } ,
              ),
            ],
          ),
        ),
      ),
    );
  }


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
                                  if(controller.isVisibleUpload){

                                    controller.isVisibleUpload = false;
                                      controller.update();
                                  }
                                } else {
                                  if(!controller.isVisibleUpload){
                                    controller.isVisibleUpload = true;
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
                              visible: controller.isVisibleUpload,
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
                APIs.sendBroadcastMessage(controller.chat!, text, Type.text);
                controller.textController.clear();
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
  }*/

}
