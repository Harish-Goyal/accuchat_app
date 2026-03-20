import 'dart:io';
import 'package:AccuChat/Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_handler/share_handler.dart';
import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../../../utils/custom_flashbar.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../Home/Presentation/Controller/company_service.dart';
import '../../../../../Home/Presentation/Controller/socket_controller.dart';
import 'package:dio/dio.dart' as multi;

import '../../../../models/chat_history_response_model.dart';
import '../../../../models/get_company_res_model.dart';

class SharePreviewPage extends StatefulWidget {
  const SharePreviewPage({super.key});

  @override
  State<SharePreviewPage> createState() => _SharePreviewPageState();
}

class _SharePreviewPageState extends State<SharePreviewPage> {
  late SharedMedia media;
  late UserDataAPI chat;
  List<XFile> images = [];
  final List<PlatformFile> webDocs = [];
  late TextEditingController messageController;
  bool isSending = false;
  bool isUploading = false;

  bool _isImageAttachment(SharedAttachment? item) {
    final type = item?.type?.name.toLowerCase() ?? '';
    final path = item?.path?.toLowerCase() ?? '';
    return type.contains('image') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif');
  }

  bool _isVideoAttachment(SharedAttachment? item) {
    final type = item?.type?.name.toLowerCase() ?? '';
    final path = item?.path?.toLowerCase() ?? '';
    return type.contains('video') ||
        path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.mkv') ||
        path.endsWith('.avi') ||
        path.endsWith('.webm');
  }

  bool _isFileAttachment(SharedAttachment? item) {
    final type = item?.type?.name.toLowerCase() ?? '';
    final path = item?.path?.toLowerCase() ?? '';
    return type.contains('file') ||
        type.contains('document') ||
        type.contains('pdf') ||
        path.endsWith('.pdf') ||
        path.endsWith('.doc') ||
        path.endsWith('.docx') ||
        path.endsWith('.xls') ||
        path.endsWith('.xlsx') ||
        path.endsWith('.ppt') ||
        path.endsWith('.pptx') ||
        path.endsWith('.txt') ||
        path.endsWith('.csv') ||
        path.endsWith('.zip') ||
        path.endsWith('.rar');
  }

  bool isDocumentByExt(String path) {
    final e = p.extension(path).toLowerCase();
    return [
      '.pdf',
      '.doc',
      '.docx',
      '.xls',
      '.xlsx',
      '.ppt',
      '.pptx',
      '.txt',
      '.csv',
      '.zip',
      '.rar',
    ].contains(e);
  }

  @override
  void initState() {
    super.initState();
    _getCompany();
    final args = Get.arguments as Map;
    media = args['media'] as SharedMedia;
    chat = args['chat'] as UserDataAPI;

    messageController = TextEditingController(
      text: media.content ?? '',
    );
  }

  CompanyData? myCompany = CompanyData();
  _getCompany() async {
    if (Get.isRegistered<CompanyService>()) {
      final svc = CompanyService.to;
      myCompany = svc.selected;
    } else {}
  }

  bool isImage(String path) {
    final p = path.toLowerCase();
    return p.endsWith('.png') ||
        p.endsWith('.jpg') ||
        p.endsWith('.jpeg') ||
        p.endsWith('.gif') ||
        p.endsWith('.webp');
  }



  Future<void> uploadDocumentsApiCall({
    required List<PlatformFile> files,
    void Function(int sent, int total)? onProgress,
  })
  async {
    if (files.isEmpty) {
      toast('Please select at least one document');
      return;
    }

    try {
      isUploading = true;

      final docParts = <multi.MultipartFile>[];
      for (final f in files) {
        final name = safeName(f.name);
        final extis = ext(name);

        if (kIsWeb) {
          // WEB: bytes are provided when withData: true
          final bytes = f.bytes;
          if (bytes == null) continue;
          docParts.add(
            multi.MultipartFile.fromBytes(
              bytes,
              filename: name,
              contentType: mediaTypeForExt(extis),
            ),
          );
        } else {
          // MOBILE/DESKTOP
          final path = f.path;
          if (path == null) continue;
          docParts.add(
            await multi.MultipartFile.fromFile(
              path,
              filename: name,
              contentType: mediaTypeForExt(extis),
            ),
          );
        }
      }

      if (docParts.isEmpty) {
        isUploading = false;
        toast('No readable documents selected');
        return;
      }
      multi.FormData? formData;
      if (chat?.userCompany?.isGroup == 1) {
        formData = multi.FormData.fromMap({
          'company_id': myCompany?.companyId,
          'media_type_code': ChatMediaType.DOC.name,
          'group_id': chat?.userCompany?.userCompanyId,
          'is_group_chat': chat?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': docParts, // array of docs
        });
      } else if (chat?.userCompany?.isBroadcast == 1) {
        formData = multi.FormData.fromMap({
          'company_id': myCompany?.companyId,
          'media_type_code': ChatMediaType.DOC.name,
          'broadcast_user_id': chat?.userCompany?.userCompanyId,
          'is_group_chat': chat?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': docParts, // array of docs
        });
      } else {
        formData = multi.FormData.fromMap({
          'company_id': myCompany?.companyId,
          'media_type_code': ChatMediaType.DOC.name,
          'to_uc_id': chat?.userCompany?.userCompanyId,
          'is_group_chat': chat?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': docParts, // array of docs
        });
      }

      await Get.find<PostApiServiceImpl>().uploadMediaApiCall(
        dataBody: formData,
      ).then((resp){
        isUploading = false;
        final socketc =Get.find<SocketController>();
        try {
          socketc.sendMessage(
            receiverId: resp.data?.chat?.toUserId ?? 0,
            message: resp.data?.chat?.chatText ?? "",
            isGroup: 0,
            alreadySave: true,
            type: chat?.userCompany?.isGroup == 1
                ? 'group'
                : chat?.userCompany?.isBroadcast == 1
                ? "broadcast"
                : '',
            chatId: resp.data?.chat?.chatId ?? 0,
            groupId: chat?.userCompany?.userCompanyId,
            brID: chat?.userCompany?.userCompanyId,
          );
          // toast(resp.message ?? 'Uploaded');
        } catch (e) {
          print('Socket sendMessage error: $e');
        }
      }).onError((error,stackTrace){
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(
              error, stackTrace, reason: 'apiCall failed');
        }
      });


    } catch (e) {
      isUploading = false;
      errorDialog(e.toString());
    }
  }

  Future<void> uploadMediaApiCall({
    required String type,
    int? replyToId,
    String? replyText,
    void Function(int sent, int total)? onProgress,
  }) async {
    // Hide keyboard
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    if (images.isEmpty) {
      toast('Please select at least one image');
      return;
    }

    try {

      // Build Multipart for each XFile (supports web+mobile)
      final mediaFiles = <multi.MultipartFile>[];
      for (final x in images) {
        multi.MultipartFile mf;

        if (!kIsWeb && x.path.isNotEmpty) {
          final path = x.path;
          final extis = ext(path);
          mf = await multi.MultipartFile.fromFile(
            path,
            filename: safeName(p.basename(path)),
            contentType: mediaTypeForExt(extis),
          );
        } else {
          // WEB: path may be empty; use bytes
          final Uint8List bytes = await x.readAsBytes();
          final nameGuess = x.name.isNotEmpty
              ? x.name
              : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final extis = ext(nameGuess);
          mf = multi.MultipartFile.fromBytes(
            bytes,
            filename: safeName(nameGuess),
            contentType: mediaTypeForExt(extis),
          );
        }

        mediaFiles.add(mf);
      }
      final Map<String, dynamic> fields;
      if (chat?.userCompany?.isGroup == 1) {
        fields = {
          'company_id': myCompany?.companyId,
          'media_type_code': type,
          'group_id': chat?.userCompany?.userCompanyId,
          'is_group_chat': chat?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': mediaFiles, // array of files
        };
      } else if (chat?.userCompany?.isBroadcast == 1) {
        fields = {
          'company_id': myCompany?.companyId,
          'media_type_code': type,
          'broadcast_user_id': chat?.userCompany?.userCompanyId,
          'is_group_chat': chat?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': mediaFiles, // array of files
        };
      } else {
        fields = {
          'company_id': myCompany?.companyId,
          'media_type_code': type,
          'to_uc_id': chat?.userCompany?.userCompanyId,
          'is_group_chat': chat?.userCompany?.isGroup == 1 ? 1 : 0,
          'chat_media': mediaFiles, // array of files
        };
      }

      final formData = multi.FormData.fromMap(fields);

      final svc = Get.find<PostApiServiceImpl>();
      await svc.uploadMediaApiCall(
        dataBody: formData,
      ).then((resp){
        isUploading = false;
        final socketc=  Get.find<SocketController>();
        try {
          socketc.sendMessage(
            receiverId: chat?.userId ?? 0,
            message: resp.data?.chat?.chatText ?? "",
            isGroup: chat?.userCompany?.isGroup == 1 ? 1 : 0,
            alreadySave: true,
            chatId: resp.data?.chat?.chatId ?? 0,
            type: chat?.userCompany?.isGroup == 1
                ? 'group'
                : chat?.userCompany?.isBroadcast == 1
                ? "broadcast"
                : 'direct',
            groupId: chat?.userCompany?.userCompanyId,
            brID: chat?.userCompany?.userCompanyId,
          );
          mediaFiles.clear();
          images.clear();
        } catch (e) {
        }
      }).onError((error,stackTrace){
        if(!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(
              error, stackTrace, reason: 'apiCall failed');
        }
      });


    } catch (e) {
      isUploading = false;
      errorDialog(e.toString());
    }
  }



  _sendMessage() async {
    if (isSending) return;
    setState(() => isSending = true);
    try {
    final socketc =Get.find<SocketController>();
    final text = messageController.text.trim();
    final attachments = media.attachments ?? [];
    final imageFiles = sharedToXFiles(attachments, forImages: true);
    final videoFiles = sharedToXFiles(attachments, forImages: false);
    final docFiles = await sharedToPlatformFiles(attachments);

    if (imageFiles.isNotEmpty) {
      images.clear();
      images.addAll(imageFiles);
      await uploadMediaApiCall(
        type: ChatMediaType.IMAGE.name,
      );
    }

    if (docFiles.isNotEmpty) {
      await uploadDocumentsApiCall(
        files: docFiles,
      );
    }



    if (attachments.isNotEmpty){
      for (final item in attachments) {
        final path = item?.path;
        if (path == null || path.isEmpty) continue;

        print('Upload file: $path');
        print('Send media to chatId ${chat.userId} with caption: $text');

        // yahan:
        // 1. multipart upload
        // 2. socket/api send media message
      }
    }
    if (text.isNotEmpty) {
      if (chat?.userCompany?.isGroup == 1) {
        socketc.sendMessage(
          receiverId: chat?.userId ?? 0,
          message: text,
          groupId: chat?.userCompany?.userCompanyId ?? 0,
          type: "group",
          isGroup: 1,
          companyId: chat?.userCompany?.companyId,
          alreadySave: false,
        );
      } else if (chat?.userCompany?.isBroadcast == 1) {
        socketc.sendMessage(
          receiverId: chat?.userId ?? 0,
          message: text,
          brID: chat?.userCompany?.userCompanyId ?? 0,
          isGroup: 0,
          type: "broadcast",
          companyId: chat?.userCompany?.companyId,
          alreadySave: false,
        );
      } else {
        socketc.sendMessage(
          receiverId: chat?.userId ?? 0,
          message: text,
          isGroup: 0,
          type: "direct",
          companyId: chat?.userCompany?.companyId,
          alreadySave: false,
        );


      }
      messageController.clear();

      // APIs.updateTypingStatus(false);
    }
    Get.until((route) => route.isFirst);
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  List<XFile> sharedToXFiles(
      List<SharedAttachment?> attachments, {
        required bool forImages,
      }) {
    final List<XFile> files = [];

    for (final item in attachments) {
      final path = item?.path;
      if (path == null || path.isEmpty) continue;

      if (forImages && _isImageAttachment(item)) {
        files.add(XFile(path, name: p.basename(path)));
      } else if (!forImages && _isVideoAttachment(item)) {
        files.add(XFile(path, name: p.basename(path)));
      }
    }

    return files;
  }

  Future<List<PlatformFile>> sharedToPlatformFiles(
      List<SharedAttachment?> attachments,
      ) async {
    final List<PlatformFile> files = [];

    for (final item in attachments) {
      final path = item?.path;
      if (path == null || path.isEmpty) continue;

      final isDoc = _isFileAttachment(item) || isDocumentByExt(path);
      if (!isDoc) continue;

      final file = File(path);
      if (!await file.exists()) continue;

      final bytes = await file.readAsBytes();

      files.add(
        PlatformFile(
          name: p.basename(path),
          path: path,
          size: bytes.length,
          bytes: kIsWeb ? bytes : null,
        ),
      );
    }

    return files;
  }

  Future<void> sendSharedData() async {
    if (isSending) return;
    setState(() => isSending = true);

    try {
      final text = messageController.text.trim();
      final attachments = media.attachments ?? [];

      if (attachments.isEmpty && text.isNotEmpty) {
        print('Send text to chatId ${chat.userId}: $text');
        // yahan tumhara normal text message socket/api
      } else {
        for (final item in attachments) {
          final path = item?.path;
          if (path == null || path.isEmpty) continue;

          print('Upload file: $path');
          print('Send media to chatId ${chat.userId} with caption: $text');

          // yahan:
          // 1. multipart upload
          // 2. socket/api send media message
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sent to ${chat.userName}')),
      );

      Get.until((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachments = media.attachments ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Share to AccuChat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(chat.userName ?? ''),
              subtitle: Text(
                  (chat.userCompany?.isGroup == 1) ? 'Group' : 'Direct chat'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  ...attachments.map((item) {
                    final path = item?.path ?? '';
                    if (path.isEmpty) return const SizedBox.shrink();
                    if (isImage(path)) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(path),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(path.split('/').last),
                    );
                  }),
                  TextField(
                    controller: messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Add message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSending ? null :_sendMessage ,
                child: Text(isSending ? 'Sending...' : 'Send'),
              ),
            ).paddingOnly(bottom: 100),
          ],
        ),
      ),
    );
  }
}
