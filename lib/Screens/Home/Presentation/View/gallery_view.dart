import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/create_folder_dialog.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/confirmation_dialog.dart';
import '../../../Chat/models/gallery_node.dart';
import '../Controller/gallery_controller.dart';
import 'home_screen.dart';

class GalleryTab extends GetView<GalleryController> {
  GalleryTab({super.key});
  GalleryController galleryController = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton:Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:FloatingActionButton.extended(
            backgroundColor: Colors.white,
            elevation: 1,
            onPressed: () async {
              final name = await showCreateFolderDialog(
                onCreate: (folderName) async {
                  // TODO: your API or local create
                  // await controller.createFolder(folderName);
                },
              );

              if (name != null) {
                // success
                // Get.snackbar("Created", name);
              }
            },
            icon: const Icon(Icons.create_new_folder_outlined),
            label: Text('New Folder', style: BalooStyles.baloosemiBoldTextStyle()),
          ),
        ),
        body: GetBuilder<GalleryController>(
          builder: (c) {
            return WillPopScope(
              onWillPop: () async {
                final consumed = c.goUp();
                return !consumed; // false = handled internally, true = pop route
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  _searchBar(),
                  if (!c.isSearching)
                  _GalleryHeader(
                    isRoot: c.isRoot,
                    breadcrumbs: c.breadcrumbs,
                    onBack: c.goUp,
                    onRootTap: c.goToRoot,
                    onCrumbTap: c.goToCrumb,
                  ),
                  const SizedBox(height: 8),
                  _listView()
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _searchBar(){
    return Row(
      children: [
        controller.isSearchingIcon
            ? Expanded(
          child: TextField(
            controller: controller.searchCtrl,
            cursorColor: appColorGreen,
            decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search User, Group & Collection ...',
                contentPadding:
                EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                constraints: BoxConstraints(maxHeight: 45)),
            autofocus: true,
            style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
            onChanged: (val) {
              controller.query = val;
              controller.onSearchChanged(val);
            },
          ).marginSymmetric(vertical: 10),
        ):
        const Flexible(
          child: SectionHeader(
            title: 'Your Smart Gallery',
            icon: galleryIcon,
          ),
        ),

        IconButton(
            onPressed: () {
              controller.isSearchingIcon = !controller.isSearchingIcon;
              controller.update();
            },
            icon:  controller.isSearchingIcon?  const Icon(
                CupertinoIcons.clear_circled_solid)
                : Image.asset(searchPng,height:25,width:25)
        ).paddingOnly(top: 0, right: 10),
      ],
    ).paddingSymmetric(horizontal: 15,vertical: 10);

  }


  _listView(){
   return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child:controller.isSearching
            ? _SearchResultsList(
          results: controller.searchResults,
          onTap: controller.openSearchResult,
        )
            : _GalleryGrid(
          items: controller.items,
          onFolderTap: controller.openFolder,
          onLeafTap: controller.openLeaf,
        ),
      ),
    );
  }
}


class _SearchResultsList extends StatelessWidget {
  final List<IndexedNode> results;
  final void Function(IndexedNode) onTap;

  const _SearchResultsList({
    required this.results,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (results.isEmpty) {
      return Center(
        child: Text('No results', style: theme.textTheme.bodyMedium),
      );
    }

    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final r = results[i];
        final n = r.node;

        IconData icon;
        if (n.type == NodeType.folder) {
          icon = Icons.folder_rounded;
        } else if (n.type == NodeType.image) {
          icon = Icons.image_rounded;
        } else {
          icon = Icons.description_rounded;
        }

        final pathText = r.path.map((p) => p.name).join(' / ');
        return ListTile(
          onTap: () => onTap(r),
          dense: true,
          leading: Icon(icon),
          title: _HighlightedText(full: n.name??'', query: Get.find<GalleryController>().searchCtrl.text),
          subtitle: pathText.isEmpty ? null : Text(pathText, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }
}

// Highlights occurrences of query in text (case-insensitive)
class _HighlightedText extends StatelessWidget {
  final String full;
  final String query;

  const _HighlightedText({required this.full, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) return Text(full, maxLines: 1, overflow: TextOverflow.ellipsis);

    final lower = full.toLowerCase();
    final q = query.trim().toLowerCase();
    final spans = <TextSpan>[];

    int start = 0;
    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx < 0) {
        spans.add(TextSpan(text: full.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: full.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: full.substring(idx, idx + q.length),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      start = idx + q.length;
    }

    return RichText(
      text: TextSpan(style: DefaultTextStyle.of(context).style, children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  final bool isRoot;
  final List<GalleryNode> breadcrumbs;
  final bool Function() onBack;
  final VoidCallback onRootTap;
  final void Function(int index) onCrumbTap;

  const _GalleryHeader({
    required this.isRoot,
    required this.breadcrumbs,
    required this.onBack,
    required this.onRootTap,
    required this.onCrumbTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.only(left: 0, right: 12, top: 12, bottom: 4),
      child: Row(
        children: [
          if (!isRoot)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18,color: Colors.black,),
              tooltip: 'Back',
            )
          else
            const SizedBox(width: 40),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onRootTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (breadcrumbs.isEmpty
                            ?appColorPerple.withOpacity(0.12)
                            :appColorPerple.withOpacity(0.6)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Root',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: breadcrumbs.isEmpty ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < breadcrumbs.length; i++) ...[
                    const Icon(Icons.chevron_right, size: 18,color: Colors.black,),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onCrumbTap(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (i == breadcrumbs.length - 1
                              ? appColorPerple.withOpacity(0.12)
                              : theme.colorScheme.surfaceVariant.withOpacity(0.6)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          breadcrumbs[i].name??'',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: (i == breadcrumbs.length - 1) ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _GalleryGrid extends StatelessWidget {
  final List<GalleryNode> items;
  final void Function(GalleryNode folder) onFolderTap;
  final void Function(GalleryNode node) onLeafTap;

  const _GalleryGrid({
    required this.items,
    required this.onFolderTap,
    required this.onLeafTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = (constraints.maxWidth ~/ 120).clamp(2, 6);
        return GridView.builder(
          padding: const EdgeInsets.only(bottom: 12, top: 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.86,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final node = items[i];
            return _GalleryTile(
              node: node,
              onTap: () {
                if (node.isFolder) {
                  onFolderTap(node);
                } else {
                  onLeafTap(node);
                }
              },
            );
          },
        );
      },
    );
  }
}
enum FolderMenuAction { rename, share, delete }

class _GalleryTile extends StatelessWidget {
  final GalleryNode node;
  final VoidCallback onTap;

  const _GalleryTile({required this.node, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller  = Get.find<GalleryController>();

    Widget preview;
    if (node.type == NodeType.image && node.thumbnail != null) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(node.thumbnail!, fit: BoxFit.cover),
        ),
      );
    } else if (node.type == NodeType.doc) {
      preview = _IconPreview(icon: Icons.description_rounded, color: theme.colorScheme.tertiary);
    } else {
      preview = _IconPreview(icon: Icons.folder_rounded, color: theme.colorScheme.primary);
    }

    return InkWell(
      onTap: onTap, // open folder / preview
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: theme.colorScheme.outlineVariant, width: .5),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(child: preview),
                  const SizedBox(height: 8),
                  Obx(() {
                    final isRenaming = controller.renamingId.value == node.id; // ✅ node must have unique id
                    if (!isRenaming) {
                      return Text(
                        node.name??'',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      );
                    }

                    final ctrl = controller.textCtrlFor(node.id??'', node.name??'');
                    final focus = controller.focusNodeFor(node.id??'');

                    return Focus(
                      onFocusChange: (hasFocus) {
                        // ✅ when user clicks outside => save
                        if (!hasFocus) {
                          controller.submitRename(
                            id: node.id??'',
                            oldName: node.name??'',
                            onRename: (newName) async {
                              // ✅ your API / update logic
                              await controller.renameFolder(node.id??'', newName);
                            },
                          );
                        }
                      },
                      child: TextField(
                        controller: ctrl,
                        focusNode: focus,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          controller.submitRename(
                            id: node.id??'',
                            oldName: node.name??"",
                            onRename: (newName) async {
                              await controller.renameFolder(node.id??'', newName);
                            },
                          );
                        },
                        decoration: const InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        ),
                      ),
                    );
                  }),
                  if (node.isFolder) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${node.children.length} items',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Top-right menu (only for folder)
            if (node.isFolder)
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  child: PopupMenuButton<FolderMenuAction>(
                    tooltip: "More",
                    padding: EdgeInsets.zero,
                    position: PopupMenuPosition.under,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white
                    ,
                    onSelected: (action) {
                      switch (action) {
                        case FolderMenuAction.rename:
                          controller.startRename(id: node.id??'', currentName: node.name??'');
                          break;
                        case FolderMenuAction.delete:
                          showResponsiveConfirmationDialog(onConfirm:  () async {
                            Get.back();
                          },title: "Delete ${node.name} Folder(Permanently Deleted)");
                          break;
                        case FolderMenuAction.share:
                          // onShare?.call(node);
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: FolderMenuAction.rename,
                        child: Text("Rename"),
                      ),
                      PopupMenuItem(
                        value: FolderMenuAction.share,
                        child: Text("Share"),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: FolderMenuAction.delete,
                        child: Text("Delete"),
                      ),
                    ],
                    child: InkWell(
                      // important: tap on menu should NOT open folder
                      onTap: null,
                      borderRadius: BorderRadius.circular(100),
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: Colors.black87,
                      ).paddingAll(5),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  }
}

class _IconPreview extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconPreview({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(child: Icon(icon, size: 48, color: color));
  }
}
