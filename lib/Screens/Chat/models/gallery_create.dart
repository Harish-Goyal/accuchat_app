class GalleryFolder {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? parentId;

  GalleryFolder({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.parentId,
  });
}