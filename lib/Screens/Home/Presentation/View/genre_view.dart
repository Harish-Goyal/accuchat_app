import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common_textfield.dart';
import '../Controller/genere_controller.dart';

class GenreInputGetX extends GetView<GenreController> {
  GenreInputGetX({super.key});

  final GenreController c = Get.put(GenreController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        vGap(10),
        CustomTextField(
          hintText: "Type genre and press Enter",
          labletext: "Folder name",
          controller: c.textController,
          focusNode: c.focusNode,
          onFieldSubmitted: (_) => c.addGenre(),
          textInputAction: TextInputAction.done,
          suffix: Obx(() => Text("${c.genres.length}/5")),
        ),


       vGap(12),

        Obx(() {
          final maxReached = c.genres.length >= 5;

          return c.genres.isEmpty
              ?SizedBox()
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12),
                ),
                child:  Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: c.genres.map((g) {
                    return Chip(
                      backgroundColor: appColorGreen.withOpacity(.1),
                      label: Text(g),
                      onDeleted: () => c.removeGenre(g),
                    );
                  }).toList(),
                ),
              ),

              if (maxReached) ...[
                const SizedBox(height: 8),
                const Text(
                  "Max 5 genres allowed",
                  style: TextStyle(color: Colors.red),
                ),
              ],

            ],
          );
        }),
      ],
    );
  }
}
