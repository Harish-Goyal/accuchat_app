class SharedPayload {
  final String? text;
  final List<String> paths;
  final String? mimeType;

  const SharedPayload({
    this.text,
    this.paths = const [],
    this.mimeType,
  });

  bool get hasText => (text ?? '').trim().isNotEmpty;
  bool get hasFiles => paths.isNotEmpty;
}