
import 'dart:typed_data';

import 'dart:typed_data';

enum PickedKind { image, document, video, audio }

class PickedFileItem {
  final String name;
  final Uint8List? byte;     // web bytes OR mobile bytes (if withData:true)
  final String? path;        // mobile/local path
  final String? url;         // network (chat media)
  final PickedKind kind;

  PickedFileItem({
    required this.name,
    required this.kind,
    this.byte,
    this.path,
    this.url,
  });

  bool get isImage => kind == PickedKind.image;
  bool get isDocument => kind == PickedKind.document;
}



enum SaveSourceType { local, network }

class SavePreviewItem {
  final SaveSourceType sourceType;

  // display
  final String name;
  final String? extension;

  // local
  final Uint8List? bytes;

  // network
  final String? url;

  // type
  final bool isImage;

  const SavePreviewItem.local({
    required this.name,
    this.extension,
    required this.bytes,
    required this.isImage,
  })  : sourceType = SaveSourceType.local,
        url = null;

  const SavePreviewItem.network({
    required this.name,
    this.extension,
    required this.url,
    required this.isImage,
  })  : sourceType = SaveSourceType.network,
        bytes = null;

  bool get isLocal => sourceType == SaveSourceType.local;
  bool get isNetwork => sourceType == SaveSourceType.network;
}

