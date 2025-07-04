


import 'dart:convert';

import '../../Screens/Authentication/AuthResponseModel/loginResModel.dart';
import '../../main.dart';


const String isFirstTime = 'isFirstTime';
const String isFirstTimeChatKey = 'isFirstTimeChatKey';
const String isLoggedIn = 'isLoggedIn';
const String userId = 'userId';
const String userName = 'userName';
const String empIdKey = 'empIdKey';
const String userRoleId = 'userRoleId';
const String emailID = 'emailID';
const String domainName = 'domainName';
const String LOCALKEY_token = "LOCALKEY_token";
const String user_key = "user_key";
const String RefreshToken = "RefreshToken";

const String rememberMe = 'rememberMe';
const String emailKey = 'emailKey';
const String passwordKey = 'passwordKey';
const String profileKey = 'profile_img';
const String logoKey = 'company_logo';
const String keyfirstName = 'keyfirstName';
const String keyId = 'keyId';
const String keylastName = 'keylastName';
const String keyemail = 'keyemail';
const String keyphone = 'keyphone';
const String keyaddress = 'keyaddress';
const String keybirthday = 'keybirthday';
const String keyprofileUrl = 'keyprofileUrl';
const String keyGender = 'keyGender';
const String wishListhData = 'wishListhData';
const String wishlistedStatus = 'wishlistedStatus';
const String lastSearchKey = 'wishlistedStatus';
const String privacy ='privacy-policy';
const String legal ='legal';
const String refundPolicy ='refund-policy';
const String termsAndC ='terms-conditions';
const String aboutUs ='about-us';
const String userAgreement ='user-agreement';
const String accomodationtype="5";
const String facilitiesType="6";

RememberMeModal? getRememberMe() {
  String? email = storage.read(emailKey);
  String? password = storage.read(passwordKey);
  if ((email ?? "").isNotEmpty && (password ?? "").isNotEmpty) {
    return RememberMeModal(email: email, password: password);
  }
}


void saveUser(UserData? user) {
  storage.write('user', user?.toJson()); // Save the user as a JSON map
}

SaveUser getUserData() {
  String? firstName = storage.read(keyfirstName);
  String? ids = storage.read(keyId);
  String? lastname = storage.read(keylastName);
  String? email = storage.read(keyemail);
  String? phone = storage.read(keyphone);
  String? address = storage.read(keyaddress);
  String? dob = storage.read(keybirthday);
  String? photo = storage.read(keyprofileUrl);
  String? userGender = storage.read(keyGender);

    return SaveUser(userid: ids, firstName: firstName,lastName: lastname,email:email,
        phone:phone,
        address:address,
        birthday:dob,
        profileUrl:photo,gender: userGender);

}

setUserData({required String id,required String firstName, required String lastname, required String email, required String phone, required String gender, required String address, required String dob, required String photo,}) {
  storage.write(keyId, id);
  storage.write(keyfirstName, firstName);
  storage.write(keylastName, lastname);
  storage.write(keyemail, email);
  storage.write(keyphone, phone);
  storage.write(keyaddress, address);
  storage.write(keybirthday, dob);
  storage.write(keyprofileUrl, photo);
  storage.write(keyGender, gender);
}




removeRememberData() {
  storage.remove(emailKey);
  storage.remove(passwordKey);
}

class RememberMeModal {
  String? email;
  String? password;
  RememberMeModal({this.email, this.password});
}

class SaveUser{
  String? userid;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? address;
  String? birthday;
  String? profileUrl;
  String? gender;
  SaveUser({
    this.firstName,
    this.userid,
    this.lastName,
    this.email,
    this.phone,
    this.address,
    this.birthday,
    this.profileUrl,
    this.gender,
    });
}
