import 'package:AccuChat/Services/APIs/api_ends.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ for web checks
import 'dart:math' as math; // ✅ for min/max helpers

import '../../../../../../Constants/colors.dart';
import '../../../../../../utils/helper.dart';
import '../../../../../../utils/networl_shimmer_image.dart';
import '../../../../models/chat_history_response_model.dart';

/// --- Responsive helpers ---
double _bubbleMaxWidth(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  // On web, keep chat bubble narrower for readability; on mobile, allow more width.
  if (kIsWeb) {
    // cap between 520 and 720 px or 60% of width
    return math.min(650, math.max(520, w * 0.60));
  }
  // mobile/tablet
  return w * 0.86;
}

double _gridGapForWidth(double width) {
  if (width >= 1200) return 12;
  if (width >= 900) return 10;
  if (width >= 600) return 8;
  return 6;
}

int _crossAxisForWidthAndCount(double width, int itemCount) {
  // Keep your original intent (2–4 → grid) but scale columns on wider web layouts.
  // For 2–4 items, we let it be 2 on phones, 3 on large web canvases for nicer tiling.
  if (itemCount <= 2) {
    if (width >= 900) return 2; // keep square-ish previews on desktop
    return 2;
  }
  if (itemCount <= 4) {
    if (width >= 1200) return 2;
    // if (width >= 1400) return 3;
    if (width >= 900) return 2;
    return 2;
  }
  // Fallback (not used by your current logic, but safe)
  if (width >= 1200) return 2;
  // if (width >= 1400) return 4;
  if (width >= 900) return 2;
  return 2;
}

double _childAspectForWidth(double width) {
  // Slightly wider tiles on big screens for visual balance
  if (width >= 1200) return .9;
  if (width >= 900) return 1;
  return 1.0;
}

/// Simple wrapper to align and constrain chat media “bubbles” on wide screens
class _BubbleWrapper extends StatelessWidget {
  final Widget child;
  final String fromId;
  final String myId;
  const _BubbleWrapper({required this.child, required this.fromId, required this.myId});

  @override
  Widget build(BuildContext context) {
    final maxW = _bubbleMaxWidth(context);
    final align = fromId == myId ? Alignment.centerRight : Alignment.centerLeft;
    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      ),
    );
  }
}

class _ViewMedia {
  final String url;
  final ChatMediaType type;
  final String fileName;

  _ViewMedia({required this.url, required this.type, required this.fileName});
}

List<_ViewMedia> toViewMediaList({
  required List<MediaList>? media,
  required String baseUrl,
}) {
  if (media == null || media.isEmpty) return const [];
  return media.map((m) {
    final file = m.fileName ?? '';
    final t = MediaTypeAPI.fromCode(m.mediaType?.mediaCode, fileName: file);
    final url = "${ApiEnd.baseUrlMedia}$file";
    return _ViewMedia(url: url, type: t, fileName: m.orgFileName??'');
  }).toList();
}

class ChatMessageMedia extends StatelessWidget {
  final ChatHisList chat;                 // your message row
  final bool isGroupMessage;
  final String myId;                      // APIs.me.id
  final String fromId;                    // message.fromUser?.userId.toString() ...
  final String? senderName;               // chat.fromUser?.userName
  final String baseUrl;                   // ApiEnd.baseUrlMedia
  final String defaultGallery;            // your image placeholder asset

  // Callbacks you already have:
  final void Function(String url)? onOpenDocument;
  final void Function(List<String> urls, int startIndex)? onOpenImageViewer;
  final void Function(String url)? onOpenVideo;  // optional
  final void Function(String url)? onOpenAudio;  // optional

  const ChatMessageMedia({
    super.key,
    required this.chat,
    required this.isGroupMessage,
    required this.myId,
    required this.fromId,
    required this.senderName,
    required this.baseUrl,
    required this.defaultGallery,
    this.onOpenDocument,
    this.onOpenImageViewer,
    this.onOpenVideo,
    this.onOpenAudio,
  });

  @override
  Widget build(BuildContext context) {
    final vm = toViewMediaList(media: chat.media, baseUrl: baseUrl);
    if (vm.isEmpty) return const SizedBox.shrink();

    final images = vm.where((e) => e.type == ChatMediaType.IMAGE).toList();
    final docs   = vm.where((e) => e.type == ChatMediaType.DOC || e.type == ChatMediaType.other).toList();
    final vids   = vm.where((e) => e.type == ChatMediaType.VID).toList();
    final auds   = vm.where((e) => e.type == ChatMediaType.AUD).toList();

    // ✅ Keep your Column, but wrap individual sections with _BubbleWrapper so width is constrained on web.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (images.isNotEmpty)
         /* _BubbleWrapper(
            fromId: fromId,
            myId: myId,
            child:*/ _ImagesGrid(
              items: images,
              isGroupMessage: isGroupMessage,
              fromId: fromId,
              myId: myId,
              senderName: senderName,
              defaultGallery: defaultGallery,
              onTapImage: (index) {
                if (onOpenImageViewer != null) {
                  onOpenImageViewer!(images.map((e) => e.url).toList(), index);
                }
              },
            ),
          // ),

        if (vids.isNotEmpty) ...[
          _BubbleWrapper(
            fromId: fromId,
            myId: myId,
            child: _FileTiles(
              labelColorForSender: fromId == myId ? Colors.green : Colors.purple,
              showHeaderName: isGroupMessage,
              whoText: fromId == myId ? 'You' : (senderName ?? ''),
              items: vids,
              leadingBuilder: (item) => const Icon(Icons.play_circle, size: 40, color: Colors.indigo),
              onTap: (item) => onOpenVideo?.call(item.url),
            ),
          ),
        ],

        if (auds.isNotEmpty) ...[
          _BubbleWrapper(
            fromId: fromId,
            myId: myId,
            child: _FileTiles(
              labelColorForSender: fromId == myId ? Colors.green : Colors.purple,
              showHeaderName: isGroupMessage,
              whoText: fromId == myId ? 'You' : (senderName ?? ''),
              items: auds,
              leadingBuilder: (item) => const Icon(Icons.audiotrack, size: 40, color: Colors.indigo),
              onTap: (item) => onOpenAudio?.call(item.url),
            ),
          ),
        ],

        if (docs.isNotEmpty) ...[
          /*_BubbleWrapper(
            fromId: fromId,
            myId: myId,
            child:*/
          _FileTiles(
              labelColorForSender: fromId == myId ? Colors.green : Colors.purple,
              showHeaderName: isGroupMessage,
              whoText: fromId == myId ? 'You' : (senderName ?? ''),
              items: docs,
              leadingBuilder: (item) => Icon(iconForFile(item.fileName), size: 35, color: Colors.indigo),
              onTap: (item) => onOpenDocument?.call(item.url),
            ),
          // ),
        ],
      ],
    );
  }

}


class _ImagesGrid extends StatelessWidget {
  final List<_ViewMedia> items;
  final bool isGroupMessage;
  final String fromId;
  final String myId;
  final String? senderName;
  final String defaultGallery;
  final void Function(int index) onTapImage;

  const _ImagesGrid({
    required this.items,
    required this.isGroupMessage,
    required this.fromId,
    required this.myId,
    required this.senderName,
    required this.defaultGallery,
    required this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    final count = items.length;

    // 1 image → large preview
    if (count == 1) {
      final item = items.first;
      // ✅ Constrain big images on web and keep nice aspect ratio
      final maxW = _bubbleMaxWidth(context);
      final gap = _gridGapForWidth(MediaQuery.of(context).size.width);
      return
          InkWell(
            onTap: () => onTapImage(0),
            borderRadius:BorderRadius.circular(15),
            child: /*ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // On web, keep preview from being ultra-wide or ultra-tall
                  maxWidth: maxW,
                  maxHeight: kIsWeb ? 480 : 420,
                ),
                child: AspectRatio(
                  aspectRatio: kIsWeb ? 16/10 : 4 / 3,
                  child: CustomCacheNetworkImage(
                    item.url,
                    radiusAll: 0, // radius handled by ClipRRect above
                    boxFit: BoxFit.cover,
                    defaultImage: defaultGallery,
                  ).paddingOnly(bottom: 8,top: 0),
                ),
              ),
            )*/Transform.translate(
              offset: Offset(0, kIsWeb?-13:-10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _bubbleMaxWidth(context),
                  maxHeight: kIsWeb ? 520 : 420,
                ),
                child: CustomCacheNetworkImage(
                  item.url,
                  radiusAll: 15, // radius handled by ClipRRect above
                  // height: Get.height*.6,
                  // width:kIsWeb? Get.height*.45:150,
                  boxFit: BoxFit.cover,
                  defaultImage: defaultGallery,
                  borderColor: greyText,
                  assetPadding: 0,
                ).paddingOnly(bottom: 0,top: 2),
              ),
            ),
          )
      ;
    }

    // 2–4 images → grid
    // ✅ make grid adaptive to screen width
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = _crossAxisForWidthAndCount(width, count);
    final gap = _gridGapForWidth(width);
    final aspect = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // if (isGroupMessage)
        //   Text(
        //     fromId == myId ? "You" : (senderName ?? ''),
        //     style: Theme.of(context)
        //         .textTheme
        //         .bodySmall
        //         ?.copyWith(fontSize: 13, color: fromId == myId ? Colors.green : Colors.purple),
        //   ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            childAspectRatio: aspect,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Transform.translate(
              offset: Offset(0, kIsWeb?-13:-10),
              child: MouseRegion(
                  cursor: SystemMouseCursors.basic, // no hand cursor
                  child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTapImage(index),
                  child: CustomCacheNetworkImage(
                    item.url,
                    radiusAll: 12,
                    boxFit: BoxFit.cover,
                    defaultImage: defaultGallery,
                  ),
                ),
              ),
            );
          },
        ).paddingOnly(bottom: 0,top: 0),
      ],
    );
  }
}

class _FileTiles extends StatelessWidget {
  final List<_ViewMedia> items;
  final bool showHeaderName;
  final String whoText; // "You" or senderName
  final Color labelColorForSender;
  final Widget Function(_ViewMedia item) leadingBuilder;
  final void Function(_ViewMedia item) onTap;

  const _FileTiles({
    required this.items,
    required this.showHeaderName,
    required this.whoText,
    required this.labelColorForSender,
    required this.leadingBuilder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ keep header aligned and width-limited via parent _BubbleWrapper
    final textScale = MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // if (showHeaderName)
        //   Text(
        //     whoText,
        //     style: Theme.of(context)
        //         .textTheme
        //         .bodySmall
        //         ?.copyWith(fontSize: 13, color: labelColorForSender),
        //   ),

        ...items.map((item) {
          final fileName = item.fileName;
          const sizeText = '';

          // ✅ nicer hover + pointer on web
          final tile = Transform.translate(
            offset: Offset(0, kIsWeb?-13:-10),
            child: InkWell(
              onTap: () => onTap(item),
              child: Container(
                // margin: const EdgeInsets.only(bottom:14),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    leadingBuilder(item),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // On web we often want selection; but keeping Text simple as per your code
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          // const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Tap to view", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              if (sizeText.isNotEmpty)
                                Text(" • $sizeText", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14,color: Colors.black45,),
                  ],
                ),
              ),
            ),
          );

          if (!kIsWeb) return tile;

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: tile,
          );
        }),
      ],
    );
  }
}
