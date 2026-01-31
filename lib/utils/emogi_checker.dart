import 'package:characters/characters.dart';

bool isEmojiOnlyMessage(String text) {
  final t = text.trim();
  if (t.isEmpty) return false;

  final chars = t.characters;

  // WhatsApp-like rule:
  // Only emojis AND max 3 emojis
  if (chars.length > 3) return false;

  return chars.every(_isEmojiChar);
}

bool _isEmojiChar(String char) {
  final code = char.runes.first;
  return
    (code >= 0x1F300 && code <= 0x1FAFF) || // emojis
        (code >= 0x2600 && code <= 0x27BF) ||   // symbols
        (code >= 0x1F1E6 && code <= 0x1F1FF) || // flags
        (code == 0x200D);                      // ZWJ
}
