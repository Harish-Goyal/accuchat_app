// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../Chat/screens/chat_tasks/Presentation/Controllers/save_in_accuchat_gallery_controller.dart';
//
// class SaveToGallerySheet extends StatelessWidget {
//   final String tag;
//   const SaveToGallerySheet({super.key, required this.tag});
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final c = Get.find<SaveToGalleryController>(tag: tag); // ✅
//
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // top bar
//             Row(
//               children: [
//                 const Expanded(
//                   child: Text(
//                     'Save in Smart Gallery',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Get.back(),
//                   icon: const Icon(Icons.close),
//                 )
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             // media name
//             TextField(
//               controller: c.nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Media name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             // breadcrumb
//             Obx(() {
//               final bc = c.breadcrumb;
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     InkWell(
//                       onTap: c.goRoot,
//                       child: const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//                         child: Text('Root', style: TextStyle(fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                     for (int i = 0; i < bc.length; i++) ...[
//                       const Text(' / '),
//                       InkWell(
//                         onTap: () => c.goToBreadcrumb(i),
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//                           child: Text(bc[i].name, style: const TextStyle(fontWeight: FontWeight.w600)),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               );
//             }),
//
//             const SizedBox(height: 10),
//
//             // search
//             TextField(
//               controller: c.searchController,
//               decoration: const InputDecoration(
//                 prefixIcon: Icon(Icons.search),
//                 hintText: 'Search folders',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             // folder list
//             ConstrainedBox(
//               constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
//               child: Obx(() {
//                 if (c.isLoading.value) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//
//                 if (c.folders.isEmpty) {
//                   return const Center(child: Text('No folders found'));
//                 }
//
//                 return ListView.separated(
//                   itemCount: c.folders.length,
//                   separatorBuilder: (_, __) => const Divider(height: 1),
//                   itemBuilder: (context, index) {
//                     final f = c.folders[index];
//                     return ListTile(
//                       leading: const Icon(Icons.folder),
//                       title: Text(f.name),
//                       trailing: const Icon(Icons.chevron_right),
//                       onTap: () => c.openFolder(f),
//                     );
//                   },
//                 );
//               }),
//             ),
//
//             const SizedBox(height: 12),
//
//             // actions
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () async {
//                       final name = await _askFolderName(context);
//                       if (name != null) c.createFolder(name);
//                     },
//                     icon: const Icon(Icons.create_new_folder_outlined),
//                     label: const Text('New folder'),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Obx(() {
//                     return ElevatedButton(
//                       onPressed: c.isSaving.value ? null : c.saveHere,
//                       child: c.isSaving.value
//                           ? const SizedBox(
//                         height: 18,
//                         width: 18,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                           : const Text('Save here'),
//                     );
//                   }),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<String?> _askFolderName(BuildContext context) async {
//     final tc = TextEditingController();
//     String? result;
//
//     await showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: const Text('Create folder'),
//           content: TextField(
//             controller: tc,
//             autofocus: true,
//             decoration: const InputDecoration(
//               hintText: 'Folder name',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
//             ElevatedButton(
//               onPressed: () {
//                 result = tc.text.trim();
//                 Navigator.pop(context);
//               },
//               child: const Text('Create'),
//             ),
//           ],
//         );
//       },
//     );
//
//     tc.dispose();
//     if (result == null || result!.isEmpty) return null;
//     return result;
//   }
// }
