import 'package:AccuChat/Screens/Home/Models/get_folder_res_model.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Controllers/save_in_accuchat_gallery_controller.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/dialogs/save_in_gallery_dialog.dart';
import '../Screens/Home/Models/pickes_file_item.dart';

void showUploadOptions(BuildContext context, {FolderData? folder}) {
  if (kIsWeb) {
    showUploadOptionsWeb(context,folder);
    return;
  }
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    backgroundColor: Colors.white,
    builder: (_) => SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.only(top: 16, left: 15, right: 15, bottom: 60),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                size: 20,
              ),
              title: Text(
                "Camera",
                style: BalooStyles.baloomediumTextStyle(),
              ),
              onTap: () async {
                Get.back();
                final saveC = Get.isRegistered<SaveToGalleryController>()
                    ? Get.find<SaveToGalleryController>()
                    : Get.put(SaveToGalleryController());
                final ImagePicker picker = ImagePicker();
                // Pick an image
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 40,
                );
                if (image != null) {
                  final picked = [
                    PickedFileItem(
                      name: image.name,
                      // byte: image.bytes,         // web always, mobile if withData true
                      path: image.path, // mobile path
                      kind: PickedKind.image,
                      url: '',
                    )
                  ];

                  folder!=null? null:await saveC.hitApiToGetFolder(reset: true);
                  saveC.docNameController.text = image.name;

                  Navigator.of(context).pop();
                  showDialog(
                      context: Get.context!,
                      builder: (_) => SaveToCustomFolderDialog(
                        user: UserDataAPI(),
                        filesImages: picked,
                        multi:false,
                        isImage: true,
                        isFromChat: false, isDirect: folder!=null?false:true, folderData: folder,
                      ));
                  // see helper you’ll paste into your controller below
                  // await controller.receivePickedDocuments(docs);
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                size: 20,
              ),
              title: Text(
                "Gallery",
                style: BalooStyles.baloomediumTextStyle(),
              ),
              onTap: () async {
                Get.back();
                final ImagePicker picker = ImagePicker();

                // Picking multiple images
                final List<XFile> images =
                await picker.pickMultiImage(imageQuality: 40, limit: 10);

                final galle = images.map((f) {
                  return PickedFileItem(
                    name: f.name,
                    // byte: f.bytes,         // web always, mobile if withData true
                    path: f.path, // mobile path
                    kind: PickedKind.image,
                    url: '',
                  );
                }).toList();

                final saveC = Get.isRegistered<SaveToGalleryController>()
                    ? Get.find<SaveToGalleryController>()
                    : Get.put(SaveToGalleryController());
                folder!=null? null:await saveC.hitApiToGetFolder(reset: true);
                if (galle.isNotEmpty) {
                  Navigator.of(context).pop();
                  showDialog(
                      context: Get.context!,
                      builder: (_) => SaveToCustomFolderDialog(
                        user: UserDataAPI(),
                        filesImages: galle,
                        isImage: true,
                        isFromChat: false,
                        multi:true,
                        isDirect: folder!=null?false:true, folderData: folder,
                      ));
                  // see helper you’ll paste into your controller below
                  // await controller.receivePickedDocuments(docs);
                }
                // uploading & sending image one by one
                // controller.images.addAll(images);
                // controller.update();
                // controller.uploadMediaApiCall(type: ChatMediaType.IMAGE.name);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.picture_as_pdf_outlined,
                size: 20,
              ),
              title: Text(
                "Document",
                style: BalooStyles.baloomediumTextStyle(),
              ),
              onTap: () {
                Get.back();
                final galle = Get.find<GalleryController>();
                galle.pickDocument(folder: folder);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

void showUploadOptionsWeb(BuildContext context,FolderData? folderdata) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Upload files'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'On web, use your computer’s picker to select images or documents.\n'
                'You can choose max 10 images at once.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            //IMAGES (multiple)
            final galle = Get.find<GalleryController>();
            final images = await galle.pickWebImages(maxFiles: 10);
            if (images.isNotEmpty) {
              final saveC = Get.isRegistered<SaveToGalleryController>()
                  ? Get.find<SaveToGalleryController>()
                  : Get.put(SaveToGalleryController());

              await saveC.hitApiToGetFolder();
              Navigator.of(ctx).pop();
              galle.images.addAll(images);
              final picked = await Future.wait(
                images.map((f) async {
                  final bytes = await f.readAsBytes();
                  return PickedFileItem(
                    name: f.name,
                    byte: bytes,
                    kind: PickedKind.image,
                    url: '',
                  );
                }),
              );
              showDialog(
                  context: Get.context!,
                  builder: (_) => SaveToCustomFolderDialog(
                    user: UserDataAPI(),
                    filesImages: picked,
                    isImage: true,
                    multi:true,
                    isFromChat: false, isDirect: folderdata!=null?false:true, folderData: folderdata,
                  ));
              // controller.images.addAll(images);
              // controller.uploadMediaApiCall(type: ChatMediaType.IMAGE.name);
            }
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo),
              SizedBox(width: 8),
              Text('Select Images')
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            // DOCUMENTS (pdf/office/etc.)
            final galle = Get.find<GalleryController>();
            final docs = await galle.pickWebDocs();

            final picked = docs
                .map((f) => PickedFileItem(
              name: f.name,
              byte: f.bytes!,
              kind: PickedKind.document,
              url: '',
            ))
                .toList();
            final saveC = Get.isRegistered<SaveToGalleryController>()
                ? Get.find<SaveToGalleryController>()
                : Get.put(SaveToGalleryController());
            await saveC.hitApiToGetFolder();
            if (docs.isNotEmpty) {
              Navigator.of(ctx).pop();
              showDialog(
                  context: Get.context!,
                  builder: (_) => SaveToCustomFolderDialog(
                    user: UserDataAPI(),
                    filesImages: picked,
                    isImage: false,
                    isFromChat: false,
                    multi:true,
                    isDirect: folderdata!=null?false:true, folderData: folderdata,
                  ));
              // see helper you’ll paste into your controller below
              // await controller.receivePickedDocuments(docs);
            }
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf),
              SizedBox(width: 8),
              Text('Select Documents')
            ],
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}