import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../Chat/models/gallery_node.dart';


class IndexedNode {
  final GalleryNode node;
  final List<GalleryNode> path; // ancestors from root to parent
  IndexedNode({required this.node, required this.path});
}
class GalleryController extends GetxController {
  // Dummy tree
  final List<GalleryNode> root = const [
    GalleryNode(
      id: 'fld_01',
      name: 'Design Assets',
      type: NodeType.folder,
      children: [
        GalleryNode(
          id: 'img_101',
          name: 'logo_v1.png',
          type: NodeType.image,
          thumbnail: 'https://picsum.photos/seed/logo_v1/300/300',
        ),
        GalleryNode(id: 'doc_201', name: 'brand_guidelines.pdf', type: NodeType.doc),
        GalleryNode(
          id: 'fld_011',
          name: 'Mockups',
          type: NodeType.folder,
          children: [
            GalleryNode(
              id: 'img_102',
              name: 'pack_front.png',
              type: NodeType.image,
              thumbnail: 'https://picsum.photos/seed/pack_front/300/300',
            ),
            GalleryNode(
              id: 'img_103',
              name: 'pack_back.png',
              type: NodeType.image,
              thumbnail: 'https://picsum.photos/seed/pack_back/300/300',
            ),
          ],
        ),
      ],
    ),
    GalleryNode(
      id: 'fld_02',
      name: 'Client Docs',
      type: NodeType.folder,
      children: [
        GalleryNode(id: 'doc_202', name: 'invoice_0925.pdf', type: NodeType.doc),
        GalleryNode(id: 'doc_203', name: 'proposal_v3.docx', type: NodeType.doc),
      ],
    ),
    GalleryNode(
      id: 'img_104',
      name: 'bdaygirl.png',
      type: NodeType.image,
      thumbnail: 'https://picsum.photos/seed/hero_banner/300/300',
    ),
  ];

  // Stack of opened folders (root == empty)
  final List<GalleryNode> _stack = [];

  List<GalleryNode> get items => _stack.isEmpty ? root : _stack.last.children;
  bool get isRoot => _stack.isEmpty;
  List<GalleryNode> get breadcrumbs => List.unmodifiable(_stack);

  void openFolder(GalleryNode folder) {
    if (!folder.isFolder) return;
    _stack.add(folder);
    update();
  }

  bool goUp() {
    if (_stack.isNotEmpty) {
      _stack.removeLast();
      update();
      return true;
    }

    return false;
  }

  void goToRoot() {
    if (_stack.isNotEmpty) {
      _stack.clear();
      update();
    }
  }

  void goToCrumb(int index) {
    // index inclusive within stack (0..last)
    if (index < 0 || index >= _stack.length) return;
    _stack.removeRange(index + 1, _stack.length);
    update();
  }

  // Replace with your preview/viewer
  void openLeaf(GalleryNode node) {
    Get.snackbar('Open', node.name, snackPosition: SnackPosition.BOTTOM,duration: Duration(seconds: 6));
  }

  final TextEditingController searchCtrl = TextEditingController();
  String query = '';
  final List<IndexedNode> index = [];

  // Build a flat index for global search
  void _buildIndex() {
    index.clear();
    void walk(List<GalleryNode> nodes, List<GalleryNode> path) {
      for (final n in nodes) {
        index.add(IndexedNode(node: n, path: List.unmodifiable(path)));
        if (n.isFolder) {
          walk(n.children, [...path, n]);
        }
      }
    }
    walk(root, const []);
  }

  List<IndexedNode> get searchResults {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    // name contains, any type
    return index.where((e) => e.node.name.toLowerCase().contains(q)).toList();
  }

  bool get isSearching => query.trim().isNotEmpty;
  bool isSearchingIcon = false;
  void onSearchChanged(String v) {
    query = v;
    update();
  }

  // Navigate to a found node's location
  void openSearchResult(IndexedNode hit) {
    // Move to the folder that contains the node (if any)
    _stack
      ..clear()
      ..addAll(hit.path.where((p) => p.isFolder));
    update();
    final node = hit.node;
    if (node.isFolder) {
      // If result is a folder, open into it
      openFolder(node);
    } else {
      // If result is a file, keep current folder (its parent) and open the leaf
      openLeaf(node);
    }
  }

  // Override lifecycle to wire search + build index
  @override
  void onInit() {
    super.onInit();
    _buildIndex();
    searchCtrl.addListener(() => onSearchChanged(searchCtrl.text));
  }

  @override
  void onClose() {
    searchCtrl.dispose();
    super.onClose();
  }

}
