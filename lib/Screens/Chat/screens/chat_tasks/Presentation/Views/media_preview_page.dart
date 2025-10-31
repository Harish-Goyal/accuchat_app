import 'package:AccuChat/Screens/Chat/models/all_media_res_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../../../utils/text_style.dart';
import '../Controllers/view_profile_controller.dart';

class MediaPreviewPage extends StatelessWidget {
  final Items item;
  final String baseUrl;

  const MediaPreviewPage({super.key, required this.item, required this.baseUrl});

  bool get _isImage {
    final code = (item.mediaType?.code ?? '').toUpperCase();
    if (code == 'IMG' || code == 'IMAGE' || code == 'PHOTO') return true;
    final ext = (item.fileName ?? '').toLowerCase();
    return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.gif') || ext.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ViewProfileController>();
    final fullUrl = '$baseUrl${item.fileName ?? ''}';
    final fileName = (item.fileName ?? '').split('/').last;
    final typeCode = (item.mediaType?.code ?? '').toUpperCase();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(fileName, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            // onPressed: () => c.shareMedia(item, baseUrl),
            onPressed: (){},
          ),
        ],
      ),
      body: _isImage
          ? Center(
        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 4.0,
          child: CustomCacheNetworkImage(
            fullUrl,
            height: double.infinity,
            width: double.infinity,
            boxFit: BoxFit.contain,
            radiusAll: 0,
          ),
        ),
      )
          : _docPreview(context, c, fullUrl, fileName, typeCode),
    );
  }

  Widget _docPreview(BuildContext context, ViewProfileController c, String url, String fileName, String typeCode) {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.insert_drive_file_outlined, size: 24, color: Colors.black87),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(fileName, maxLines: 2, overflow: TextOverflow.ellipsis, style: BalooStyles.baloosemiBoldTextStyle()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // open externally if you use url_launcher (optional)
                      // launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    // onPressed: () => c.shareMedia(item, baseUrl),
                    onPressed: (){},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
