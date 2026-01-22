import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/gallery_controller.dart';

class FolderItemsScreen extends StatelessWidget {
  final String folderName;

  FolderItemsScreen({super.key, required this.folderName});

  final GalleryController c = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.hitApiToGetFolderItems(folderName);
    });

    return Scaffold(
      appBar: AppBar(title: Text(folderName)),
      body: Obx(() {
        final isLoading = c.isLoadingItems.value;
        final items = c.folderItems ?? [];

        if (isLoading) return const Center(child: CircularProgressIndicator());
        if (items.isEmpty) return const Center(child: Text("No items found"));

        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;

            // ✅ Responsive columns
            final crossAxisCount = _crossAxisCountForWidth(w);

            // ✅ Responsive preview height
            final thumbHeight = _thumbHeightForWidth(w);

            return GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: w >= 900 ? 20 : 12,
                vertical: 12,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                // more stable for different widths
                childAspectRatio: w >= 900 ? 1.15 : 0.86,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];

                final fileName = (it.fileName ?? "").trim();
                final title = (it.title ?? fileName).trim();
                final kw = (it.keyWords ?? "").trim();
                final thumbUrl = "${ApiEnd.baseUrlMedia}${it.filePath}";

                final isImage = _isImage(it.mediaTypeId ?? 0, fileName);

                return _MediaCard(
                  thumbHeight: thumbHeight,
                  title: title.isEmpty ? fileName : title,
                  keywords: kw,
                  thumbUrl: thumbUrl,
                  isImage: isImage,
                  fileName: fileName,
                  createdOnText: _prettyDate(it.createdOn),
                  docIcon: _fileIcon(fileName),
                  onTap: () {
                    // c.openMedia(it);
                  },
                  onRename: () => _openRenameDialog(context, it),
                  onDelete: () => _openDeleteConfirm(context, it),
                  onShare: () {
                    // c.shareMedia(it);
                  },
                );
              },
            );
          },
        );
      }),
    );
  }

  // ---------- Responsive helpers ----------
  int _crossAxisCountForWidth(double w) {
    if (w < 520) return 2;      // mobile
    if (w < 760) return 3;      // large phone / small tablet
    if (w < 1024) return 4;     // tablet / small web
    if (w < 1400) return 5;     // web
    return 6;                   // big web
  }

  double _thumbHeightForWidth(double w) {
    if (w < 520) return 120;
    if (w < 760) return 130;
    if (w < 1024) return 140;
    return 150;
  }

  // ---------- Dialogs ----------
  void _openRenameDialog(BuildContext context, dynamic it) {
    final ctrl = TextEditingController(text: (it.title ?? "").toString().trim());

    Get.dialog(
      AlertDialog(
        title: const Text("Rename media"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            hintText: "Enter media name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isEmpty) return;

              // ✅ API call
              // c.renameMedia(it.userGalleryId, newName);

              it.title = newName; // optimistic UI
              // c.folderItems?.refresh();

              Get.back();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _openDeleteConfirm(BuildContext context, dynamic it) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete media?"),
        content: const Text("This will remove the file from the folder."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // ✅ API call
              // c.deleteMedia(it.userGalleryId);

              c.folderItems?.remove(it);
              // c.folderItems?.refresh();

              Get.back();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // ---------- File helpers ----------
  static bool _isImage(int mediaTypeId, String fileName) {
    final lower = fileName.toLowerCase();
    return mediaTypeId == 1 ||
        lower.endsWith(".png") ||
        lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".webp");
  }

  static String _prettyDate(dynamic createdOn) {
    try {
      final dt = createdOn is DateTime
          ? createdOn
          : DateTime.tryParse(createdOn?.toString() ?? "");
      if (dt == null) return "";
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return "";
    }
  }

  static IconData _fileIcon(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith(".pdf")) return Icons.picture_as_pdf;
    if (lower.endsWith(".doc") || lower.endsWith(".docx")) return Icons.description;
    if (lower.endsWith(".xls") || lower.endsWith(".xlsx") || lower.endsWith(".csv")) return Icons.grid_on;
    if (lower.endsWith(".ppt") || lower.endsWith(".pptx")) return Icons.slideshow;
    if (lower.endsWith(".zip") || lower.endsWith(".rar") || lower.endsWith(".7z")) return Icons.folder_zip;
    if (lower.endsWith(".mp4") || lower.endsWith(".mov") || lower.endsWith(".mkv")) return Icons.movie;
    if (lower.endsWith(".mp3") || lower.endsWith(".wav") || lower.endsWith(".aac")) return Icons.audiotrack;
    return Icons.insert_drive_file;
  }
}

/// ✅ Responsive Media Card (works for web + mobile)
class _MediaCard extends StatelessWidget {
  final double thumbHeight;
  final String title;
  final String keywords;
  final String thumbUrl;
  final bool isImage;
  final String fileName;
  final String createdOnText;
  final IconData docIcon;

  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const _MediaCard({
    required this.thumbHeight,
    required this.title,
    required this.keywords,
    required this.thumbUrl,
    required this.isImage,
    required this.fileName,
    required this.createdOnText,
    required this.docIcon,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1.2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: thumbHeight,
                width: double.infinity,
                color: Colors.black12,
                child: isImage
                    ? Image.network(
                  thumbUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _docPreview(),
                  loadingBuilder: (_, child, p) {
                    if (p == null) return child;
                    return const Center(
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                )
                    : _docPreview(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: "Actions",
                    onSelected: (v) {
                      if (v == "rename") onRename();
                      if (v == "share") onShare();
                      if (v == "delete") onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "rename", child: Text("Rename")),
                      PopupMenuItem(value: "share", child: Text("Share")),
                      PopupMenuItem(value: "delete", child: Text("Delete")),
                    ],
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.more_vert, size: 18),
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Text(
                keywords.isEmpty ? fileName : keywords,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.black45),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      createdOnText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: Colors.black45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _docPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(docIcon, size: 46, color: Colors.black54),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
