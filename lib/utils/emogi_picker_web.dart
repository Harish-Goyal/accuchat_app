import 'package:AccuChat/Constants/colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';


void openWhatsAppEmojiPicker({
  required BuildContext context,
  required TextEditingController textController,
  VoidCallback? onSend,
  bool isMobile = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.40,
        maxChildSize: 0.85,
        builder: (ctx, scrollController) {
          void appendEmoji(String emoji) {
            final text = textController.text;
            textController.text = "$text$emoji";
            textController.selection = TextSelection.fromPosition(
              TextPosition(offset: textController.text.length),
            );
          }

          void backspace() {
            final chars = textController.text.characters;
            if (chars.isEmpty) return;
            textController.text = chars.skipLast(1).toString();
            textController.selection = TextSelection.fromPosition(
              TextPosition(offset: textController.text.length),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: textController,
                            builder: (_, value, __) {
                              final t = value.text;
                              return Text(
                                t.isEmpty ? "Select emojis..." : t,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: "Backspace",
                        onPressed: backspace,
                        icon:  Icon(Icons.backspace_outlined,color: appColorGreen),
                      ),
                      if (onSend != null)
                        IconButton(
                          tooltip: "Send",
                          onPressed: () {
                            if (!isMobile) Navigator.pop(context);
                            onSend();
                          },
                          icon:  Icon(Icons.send,color: appColorGreen,),
                        ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(
                  child: EmojiPicker(
                    key: const ValueKey('emoji_picker'),
                    onEmojiSelected: (category, emoji) => appendEmoji(emoji.emoji),
                    onBackspacePressed: backspace,
                    config:  Config(
                      height: 260,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28),
                      skinToneConfig: SkinToneConfig(),
                      categoryViewConfig: CategoryViewConfig(
                        iconColor: Colors.grey.shade500,
                        iconColorSelected: appColorGreen,
                        indicatorColor:appColorGreen,
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(enabled: false),
                      searchViewConfig: SearchViewConfig(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}





/*

void openWhatsAppEmojiPicker({
  required BuildContext context,
  required TextEditingController textController,
  VoidCallback? onSend, // optional
  bool isMobile =false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.40,
        maxChildSize: 0.85,
        builder: (ctx, scrollController) {
          return StatefulBuilder(
            builder: (ctx, setState) {
              void appendEmoji(String emoji) {
                final text = textController.text;
                textController.text = "$text$emoji";
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length),
                );
                setState(() {});
              }

              void backspace() {
                final chars = textController.text.characters;
                if (chars.isEmpty) return;
                textController.text = chars.skipLast(1).toString();
                textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: textController.text.length),
                );
                setState(() {});
              }

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  children: [
                    // Top bar (preview + backspace + send)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: Text(
                                textController.text.isEmpty ? "Select emojis..." : textController.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: "Backspace",
                            onPressed: backspace,
                            icon: const Icon(Icons.backspace_outlined),
                          ),
                          if (onSend != null)
                            IconButton(
                              tooltip: "Send",
                              onPressed: () {
                                if(!isMobile){
                                  Navigator.pop(context);
                                }

                                onSend();
                              },
                              icon: const Icon(Icons.send),
                            ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Emoji picker (multi-select: no close on select)
                    Expanded(
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          appendEmoji(emoji.emoji); // ✅ keep sheet open
                        },
                        onBackspacePressed: backspace, // supports built-in backspace too

                        config: const Config(
                          height: 260,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(emojiSizeMax: 28),
                          skinToneConfig: SkinToneConfig(),
                          categoryViewConfig: CategoryViewConfig(
                            iconColor: Colors.grey,
                            iconColorSelected: Colors.blue,
                            indicatorColor: Colors.blue,
                          ),
                          bottomActionBarConfig: BottomActionBarConfig(enabled: false),
                          searchViewConfig: SearchViewConfig(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}*/
