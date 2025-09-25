import 'dart:io';

import 'package:AccuChat/Screens/Chat/models/chat_his_res_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../models/chat_user.dart';
import '../../../../models/message.dart';

class ChatGroupController extends GetxController{
  ChatGroup? group;
  List<ChatHisResModel> messages = [];
  final textController = TextEditingController();
  bool isUploading = false;
  bool isAdmin = false;
  File? file;
  Message? replyToMessage;
  var replyToSenderName ='';

  getArguments(){
    if(Get.arguments!=null) {
      group = Get.arguments['group'];
    }
  }

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }
}