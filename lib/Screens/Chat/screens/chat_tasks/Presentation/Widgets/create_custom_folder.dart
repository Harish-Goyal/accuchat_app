import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_screen_controller.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../utils/common_textfield.dart';
import '../../../../../../utils/helper.dart';
import '../../../../models/gallery_create.dart';

Future<GalleryFolder?> showSaveToCustomFolderDialog(BuildContext context) async {
  // Create a fresh controller for this dialog lifecycle
  final String tagId = 'gallery-folder-dialog-${UniqueKey()}';
  final ctrl = Get.put(ChatScreenController(), tag: tagId);
  final result = await showDialog<GalleryFolder?>(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return GetBuilder<ChatScreenController>(
        init: ctrl,
        builder: (c) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title:  Text('Save to Custom Folder'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Existing folders list
                    Text('Existing folders', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (c.folders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('No folders yet. Create a new one below.'),
                      )
                    else
                      ...c.folders.map((f) {
                        return RadioListTile<String>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(f.name),
                          subtitle: Text('Created ${friendlyDate(f.createdAt)}'),
                          value: f.id,
                          groupValue: c.selectedFolderId,
                          onChanged: c.showCreateNew ? null : (val) => c.selectFolder(val),
                        );
                      }),

                    const SizedBox(height: 12),
                    const Divider(),

                    // Create New toggle
                    Row(
                      children: [
                        Switch(
                          value: c.showCreateNew,
                          onChanged: (v) => c.toggleCreateNew(v),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('Create a new folder')),
                      ],
                    ),

                    // Create New form
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 180),
                      crossFadeState: c.showCreateNew ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      firstChild: Form(
                        key: c.formKeyDoc,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),

                            // ---- YOUR CustomTextField HERE ----
                            CustomTextField(
                              hintText: "Folder name",
                              labletext: "Folder name",
                              controller: c.newFolderCtrl,
                              focusNode: c.newFolderFocus,
                              onFieldSubmitted: (_) => c.createFolder(),
                              validator: (value) {
                                final v = (value ?? '').trim();

                                // Use your extension for empty check
                                if (v.isEmpty) {
                                  // value?.isEmptyField(messageTitle: "Folder name") would produce "Folder name can't be empty"
                                  // but since v is already trimmed, directly return:
                                  return "Folder name can't be empty";
                                }

                                if (v.length < 2) {
                                  return 'Folder name must be at least 2 characters';
                                }

                                // Check uniqueness against existing dummy list
                                final exists = c.folders.any(
                                      (f) => f.name.toLowerCase() == v.toLowerCase(),
                                );
                                if (exists) {
                                  return 'Folder name already exists';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                final created = c.createFolder();
                                if (created != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Folder created')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.create_new_folder_outlined),
                              label: const Text('Create & Select'),
                            ),
                          ],
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.delete<ChatScreenController>(tag: tagId);
                  Navigator.of(context).pop(null);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: c.selectedFolder == null
                    ? null
                    : () {
                  final chosen = c.selectedFolder!;
                  Get.delete<ChatScreenController>(tag:tagId);
                  Navigator.of(context).pop(chosen);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  return result;
}