enum NodeType { folder, image, doc }

class GalleryNode {
   String? id;
   String? name;
   NodeType? type;
   String? thumbnail; // for images (or doc/folder icon override)
   List<GalleryNode> children; // only for folders

   GalleryNode({
    required this.id,
    required this.name,
    required this.type,
    this.thumbnail,
    this.children = const [],
  });

  bool get isFolder => type == NodeType.folder;
}
