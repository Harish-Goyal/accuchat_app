import 'package:get/get_utils/src/get_utils/get_utils.dart';

extension TextFieldValidator on String {
  String? isValidEmail() {
    if (isEmpty) {
      return "Enter Email";
    } else if (isNotEmpty && !GetUtils.isEmail(this)) {
      return "Enter Valid Email";
    }
    return null;
  }

  String? isEmptyField({String? messageTitle}) {
    if (isEmpty) {
      return "$messageTitle can't be empty";
    }
    return null;
  }

  String? validatePassword() {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$';
    RegExp regExp = RegExp(pattern);
    if (isEmpty) {
      return "Enter Password";
    } else if (!regExp.hasMatch(this)) {
      return 'Password must include 6-12 Characters , least 1 capital letter,1 number and 1 special character';
    }
    return null;
  }

  String? validateConfirmPassword({required String password,required String newpassword,}) {
    if (isEmpty) {
      return "Enter Confirm Password";
    } else if (password != newpassword) {
      return 'New password and confirm password should be same';
    }
    return null;
  }

  String? validateMobile(String value) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Invalid mobile number';
    }
    return null;
  }
}
