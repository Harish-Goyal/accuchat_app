import 'package:AccuChat/utils/text_style.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:flutter/material.dart';

import '../Constants/themes.dart';

class CustomSearchBarAnimated extends StatelessWidget {
   CustomSearchBarAnimated({super.key,required this.lable,required this.searchController,required this.onChangedVal});

  final TextEditingController searchController;
   dynamic Function(String) onChangedVal;
   String lable='';

  @override
  Widget build(BuildContext context) {
    return AnimatedSearchBar(
      label: lable,
      searchIcon: const Icon(
        Icons.search_rounded,
        color: Colors.black,
      ),
      closeIcon: const Icon(
        Icons.clear,
        color: Colors.black,
      ),
      labelStyle: BalooStyles.balooboldTitleTextStyle(size: 25),
      controller: searchController,
      cursorColor: AppTheme.appColor,
      // height: 40,
      searchDecoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.appColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.appColor)),
        labelStyle: BalooStyles.baloonormalTextStyle(),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      ),
      onChanged:onChangedVal,
    );
  }
}
