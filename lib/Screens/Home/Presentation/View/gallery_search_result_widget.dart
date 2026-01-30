import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../Models/get_folder_res_model.dart';

class GalleryGlobalSearchResults extends StatelessWidget {
  final List<FolderData> items;
  final String Function(String path) buildFileUrl;
  final void Function(String folderName) onOpenFolder;
  final void Function(FolderData media) onOpenMedia;

  const GalleryGlobalSearchResults({
    super.key,
    required this.items,
    required this.buildFileUrl,
    required this.onOpenFolder,
    required this.onOpenMedia,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState();
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        final isGrid = w >= 650; // web/tablet => grid
        final crossAxisCount = _crossAxisForWidth(w);

        if (!isGrid) {
          // ✅ Mobile: List
          return ListView.separated(
            padding: const EdgeInsets.all(5),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => GlobalSearchResultTile(
              item: items[i],
              buildFileUrl: buildFileUrl,
              onOpenFolder: onOpenFolder,
              onOpenMedia: onOpenMedia,
            ),
          );
        }

        // ✅ Web/Tablet: Grid
        return GridView.builder(
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3, // wide cards
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => GlobalSearchResultTile(
            item: items[i],
            buildFileUrl: buildFileUrl,
            onOpenFolder: onOpenFolder,
            onOpenMedia: onOpenMedia,
          ),
        );
      },
    );
  }

  int _crossAxisForWidth(double w) {
    if (w < 650) return 1;
    if (w < 900) return 2;
    if (w < 1200) return 3;
    return 4;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
          boxShadow: const [BoxShadow(blurRadius: 14, color: Color(0x11000000))],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 44),
            SizedBox(height: 10),
            Text("No results found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text("Try a different keyword or check spelling.", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}



class GlobalSearchResultTile extends StatelessWidget {
  final FolderData item;
  final String Function(String path) buildFileUrl;
  final void Function(String folderName) onOpenFolder;
  final void Function(FolderData media) onOpenMedia;

  const GlobalSearchResultTile({
    super.key,
    required this.item,
    required this.buildFileUrl,
    required this.onOpenFolder,
    required this.onOpenMedia,
  });

  @override
  Widget build(BuildContext context) {
    final isFolder = item.isFolder;
    final title = isFolder
        ? (item.folderName ?? "Untitled Folder")
        : (item.title ?? item.filePath?.split('/').last ?? "Untitled");

    final subtitle = isFolder
        ? "Folder"
        : (item.mediaTypeId == 1 ? "Image" : "Document");
    final d = item.createdOn??'';
    final parseDate = DateTime.parse(d);

    final createdText = _formatDate(parseDate);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (isFolder) {
            onOpenFolder(item.folderName ?? "");
          } else {
            onOpenMedia(item);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 6),
                color: Color(0x11000000),
              )
            ],
          ),
          child: Row(
            children: [
              _LeadingPreview(
                item: item,
                buildFileUrl: buildFileUrl,
              ),
              hGap(12),

              // ✅ Title/subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:BalooStyles.baloomediumTextStyle(),
                    ),
                    vGap(4),
                    Row(
                      children: [
                       /* Flexible(child: _Pill(label: subtitle, icon: isFolder ? Icons.folder_rounded : Icons.insert_drive_file_rounded)),
                        const SizedBox(width: 8),*/
                        if ((item.folderName ?? "").isNotEmpty && !isFolder)
                          _Pill(label: item.folderName!, icon: Icons.folder_open_rounded),
                      ],
                    ),
                    if (createdText != null) ...[
                      vGap(6),
                      Text(
                        "Created: $createdText",
                        style:BalooStyles.baloonormalTextStyle(size: 12,color: greyText) ,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              hGap(10),
              // ✅ Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconAction(
                    icon: isFolder ? Icons.folder_open_rounded : Icons.open_in_new_rounded,
                    tooltip: isFolder ? "Open folder" : "Open media",
                    onTap: () {
                      if (isFolder) {
                        onOpenFolder(item.folderName ?? "");
                      } else {
                        onOpenMedia(item);
                      }
                    },

                  ),
                 /* if (!isFolder) ...[
                    const SizedBox(width: 6),
                    _IconAction(
                      icon: Icons.share_rounded,
                      tooltip: "Share",
                      onTap: () {
                        // call your share logic here
                        // e.g. controller.shareMedia(item)
                      },
                    ),
                  ],*/
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String? _formatDate(DateTime? dt) {
    if (dt == null) return null;
    // simple readable; you can use intl if you want
    final d = dt.toLocal();
    return "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
  }
}

class _LeadingPreview extends StatelessWidget {
  final FolderData item;
  final String Function(String path) buildFileUrl;

  const _LeadingPreview({
    required this.item,
    required this.buildFileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isFolder = item.isFolder;
    final size = 40.0;

    Widget child;

    if (isFolder) {
      child =  Icon(Icons.folder_rounded, size: 25,color: appColorGreen,);
    } else {
      final isImage = item.mediaTypeId == 1;
      if (isImage && (item.filePath ?? "").isNotEmpty) {
        final url = buildFileUrl(item.filePath!);
        child = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CustomCacheNetworkImage(
            radiusAll:12,
            width: size,
            height: size,
            borderColor: greyText,
            boxFit: BoxFit.cover,
              url,
          )
        );
      } else {
        child = Icon(
          isImage ? Icons.image_rounded : Icons.description_rounded,
          size: 28,
        );
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Center(child: child),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Pill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black.withOpacity(.7)),
          hGap(4),
          Text(
            label,
            style:BalooStyles.baloonormalTextStyle(size: 12,color: Colors.black.withOpacity(.75))
            ,
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        radius: 22,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black12),
          ),
          child: Icon(icon, size: 18,color: appColorGreen,),
        ),
      ),
    );
  }
}

