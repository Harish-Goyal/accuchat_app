import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../../../utils/helper_widget.dart';
import '../../../../api/apis.dart';
import '../../../../models/chat_user.dart';
import '../../../../models/message.dart';


class ChatsBroadcastsController extends GetxController{
   BroadcastChat? chat;

  List<Message> messages = [];
  TextEditingController textController = TextEditingController();
  bool isUploading = false;

  bool isVisibleUpload = true;

  @override
  void onInit() {
    getArguments();
    super.onInit();
  }

  getArguments(){
    if(Get.arguments!=null) {
      chat = Get.arguments['chat'];
    }
  }
}