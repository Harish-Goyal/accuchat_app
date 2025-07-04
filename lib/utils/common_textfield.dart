import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'text_style.dart';

/*class EntryField extends StatelessWidget {
  EntryField(
      {Key? key,
      this.hintText,
      this.isPassword = false,
      this.obscureText = false,
      this.isShowPrefix = false,
      this.isEnable = true,
      this.readOnly = false,
      this.onTap,
      this.isCapitalize = false,
      this.prefixIcon,
      required this.title,
      required this.validator,
      this.textDirection,
      this.textInputAction,
      this.focusNode,
      required this.errortext, // Initially password is obscure
      required this.controller,
      this.textInputType,
      this.maxLines = 1,
      this.onChange,
      this.maxLength,
      this.widget,
      this.onShowHide})
      : super(key: key);
  String? hintText;
  bool isPassword;
  bool obscureText;
  Widget? widget;
  int? maxLength;
  bool isShowPrefix;
  TextEditingController controller;
  TextInputType? textInputType;
  String errortext;
  Function(String)? onChange;
  TextDirection? textDirection;
  TextInputAction? textInputAction;
  FocusNode? focusNode;
  String title;
  Function()? onShowHide;
  Function()? onTap;
  bool isEnable = true;
  bool isCapitalize = false;
  String? prefixIcon;
  int maxLines = 1;
  bool readOnly = false;

  String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: Get.width*.2),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        keyboardType: textInputType ?? TextInputType.text,
        textDirection: textDirection ?? TextDirection.ltr,
        textInputAction: textInputAction ?? TextInputAction.next,
        focusNode: focusNode ?? FocusNode(),
        enabled: isEnable,
        maxLines: maxLines,
        onTap: onTap ?? () {},
        cursorColor: Colors.black,
        style: LatoStyles.latonormalTextStyle(color: Colors.black),
        onChanged: onChange,
        obscureText: obscureText,
        // cursorHeight: 20,
        maxLength: maxLength,
        validator: validator,
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.start,
        textCapitalization: isCapitalize
            ? TextCapitalization.characters
            : TextCapitalization.sentences,
        decoration: InputDecoration(
            errorStyle: LatoStyles.latonormalTextStyle(color: Colors.black),
            fillColor: Colors.grey.shade100,
            counterText: "",
            filled: true,
            border: const OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(100))),
            contentPadding: EdgeInsets.symmetric(
                vertical: 20, horizontal: !isShowPrefix ? 15 : 0),
            // contentPadding: const EdgeInsets.all(0),
            hintText: title,
            hintStyle: LatoStyles.latonormalTextStyle(color: Colors.black),
            prefixIcon: isShowPrefix
                ? Container(
                    width: 50,
                    padding: const EdgeInsets.only(left: 20, bottom: 5),
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      prefixIcon ?? '',
                      height: 18,
                      width: 18,
                    ),
                  )
                : null,
            suffixIcon: widget ?? null),
      ),
    );
  }
}*/

class CustomTextField extends StatelessWidget {
  TextEditingController? controller;
  FocusNode? focusNode;
  String? hintText;

  int? maxLines = 1;
  int? minLines = 1;
  bool? obsecureText = false;

  String? Function(String?)? validator;
  TextInputAction? textInputAction = TextInputAction.next;
  TextInputType? textInputType = TextInputType.text;
  Widget? prefix;
  Widget? suffix;
  Widget? suffix2;
  List<TextInputFormatter>? inputFormatters;
  ValueChanged<String>? onFieldSubmitted;
  bool? readOnly;
  GestureTapCallback? onTap;
  Color? borderColor;
  int? maxLength;
  String? labletext;
  Color? textColor;
  ValueChanged<String>? onChangee;

  var corRadious;

  CustomTextField(
      {Key? key,
      this.controller,
      this.focusNode,
      this.textColor,
      this.hintText,
      this.maxLines,
      this.obsecureText,
        this.minLines,
      this.validator,
      this.onChangee,
      this.readOnly,
      this.labletext,
      this.suffix2,
      this.onTap,
      this.borderColor,
      this.prefix,
      this.suffix,
      this.textInputAction,
      this.inputFormatters,
      this.textInputType,
      this.onFieldSubmitted,
      this.maxLength,
        this.corRadious,
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labletext==""?SizedBox(): Text(
          labletext ?? '',
          style:  BalooStyles.balooregularTextStyle(),
        ).paddingOnly(left: 2, bottom: 5),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(corRadious??15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 15
              )
            ]
          ),
          child: TextFormField(
            clipBehavior: Clip.none,
            controller: controller,
            cursorColor: AppTheme.appColor,

            focusNode: focusNode,
            onTap: onTap,
            readOnly: readOnly ?? false,
            validator: validator,
            textInputAction: textInputAction,
            onFieldSubmitted: onFieldSubmitted,
            keyboardType: textInputType,
            maxLines: maxLines ?? 1,
            minLines: minLines??1,
            obscureText: obsecureText ?? false,
            // obscuringCharacter: "*",
            maxLength: maxLength,
            onChanged: onChangee,
            inputFormatters: inputFormatters,
            textAlignVertical: TextAlignVertical.center,
            autovalidateMode: AutovalidateMode.disabled,
            style:BalooStyles.balooregularTextStyle(),
            decoration: InputDecoration(
              alignLabelWithHint: true,
                isDense: true,

                hintText: hintText,
                // contentPadding: EdgeInsets.only(top: 10),
                // constraints: BoxConstraints(maxHeight: 50),
                hintStyle:TextStyle(color: Theme.of(context).disabledColor),
                helperStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                errorMaxLines: 3,
                labelStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                fillColor: Colors.grey.shade100,
                prefixIcon: prefix,
                suffixIcon: suffix,
                filled: true,
                focusedBorder:
                    outlineBorder(width: 2, color: borderColor ?? AppTheme.appColor ,radi: corRadious),
                errorBorder: outlineBorder(color: borderColor ?? AppTheme.redErrorColor,radi: corRadious),
                enabledBorder:
                    outlineBorder(color: borderColor ?? Colors.transparent,radi: corRadious),
                border: outlineBorder(color: borderColor ?? appColor),
                focusedErrorBorder:
                    outlineBorder(color: borderColor ?? AppTheme.redErrorColor,width: 2,radi: corRadious)),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder outlineBorder({double? width, Color? color,radi}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radi??15),
      borderSide:
          BorderSide(color: color ?? Colors.grey.shade300, width: width ?? 1.0),
    );
  }
}
