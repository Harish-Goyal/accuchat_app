import '../Screens/Chat/screens/auth/models/get_uesr_Res_model.dart';

extension UserDataAPIEmpty on UserDataAPI {
  static UserDataAPI empty() => UserDataAPI(
    userId: 0,
    userName: '',
    phone: '',
    createdBy: null,
    isAdmin: 0,
    email: '',
    about: '',
    createdOn: null,
    isActive: 1,
    userImage: '',
    userKey: '',
    updatedOn: null,
    allowedCompanies:  0,
    isDeleted: 0,
    userCompany: null,
    lastMessage: null,
    memberCount: 0,
    pendingCount: 0,
    invitedBy: null,
    invitedOn: null,
    joinedOn: null,
    pushToken: '',
  );
}