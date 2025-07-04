import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/main.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/common_textfield.dart';
import '../../api/apis.dart';

class JoinCompanyScreen extends StatefulWidget {
  String type;
   JoinCompanyScreen({
    Key? key,
    required this.type,

  }) : super(key: key);

  @override
  State<JoinCompanyScreen> createState() => _JoinCompanyScreenState();
}

class _JoinCompanyScreenState extends State<JoinCompanyScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController companyCodeController = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode companyCodeFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  void joinCompany() async{

    if (_formKey.currentState?.validate() ?? false) {
    customLoader.show();
    await APIs.handleJoinCompany(context:context, emailOrPhone:emailController.text.trim().endsWith(".com")?emailController.text.trim():"+91${emailController.text.trim()}");
      customLoader.hide();
      // Simulate joining company logic, ideally you'd call an API or Firebase function
      // Future.delayed(const Duration(seconds: 2), () {
      //   setState(() => isLoading = false);
      //   Get.snackbar("Success", "Request sent to join the company!",
      //       snackPosition: SnackPosition.TOP
      //       ,colorText: Colors.black);
      // });
    }
  }


  String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email or phone number';
    }

    final trimmed = value.trim();

    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    final phoneRegex = RegExp(r'^\d{10}$');

    if (!emailRegex.hasMatch(trimmed) && !phoneRegex.hasMatch(trimmed)) {
      return 'Enter a valid email or 10-digit phone number';
    }

    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(widget.type=='add'?"Add Member":"Join Company"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              vGap(10),
              CustomTextField(
                hintText: "Enter Your Email or Phone",
                labletext: "Email or Phone",
                controller: emailController,
                prefix: const Icon(Icons.join_inner),
                focusNode: emailFocusNode,
                validator: validateEmailOrPhone,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(companyCodeFocusNode);
                },
              ),
             /* const SizedBox(height: 20),
              CustomTextField(
                hintText: "Enter Company Code",
                labletext: "Company Code",
                controller: companyCodeController,
                prefix: const Icon(Icons.business),
                focusNode: companyCodeFocusNode,
                validator: (value) {
                  return value?.isEmptyField(messageTitle: "Company Code");
                },
              ),*/
              vGap(100),
              ElevatedButton(
                onPressed: ()=> joinCompany(),
                child: Text(widget.type=='add'?"Add Member":"Join Company"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
