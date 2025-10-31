enum NodeType { folder, image, doc }

class GalleryNode {
  final String id;
  final String name;
  final NodeType type;
  final String? thumbnail; // for images (or doc/folder icon override)
  final List<GalleryNode> children; // only for folders

  const GalleryNode({
    required this.id,
    required this.name,
    required this.type,
    this.thumbnail,
    this.children = const [],
  });

  bool get isFolder => type == NodeType.folder;
}
