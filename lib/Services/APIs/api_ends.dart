class ApiEnd {
  // https://app.accutask.com/
  static const String baseUrl = "http://192.168.1.111:3001/api/";
  static const String baseUrlMedia = "http://192.168.1.111:3001";
  // static const String baseUrl = "https://www.api.accuchat.in:3001/api/";
  // static const String baseUrlMedia = "https://www.api.accuchat.in:3001/";


  static const String authKEy = "rEgAnAmTrOppUsHcEtIgId";
  static const String loginEnd = "api/user_login";
  static const String signupEnd = "auth/signup";
  static const String verifyOtpEnd = "auth/verify-otp";
  static const String logoutEnd = "api/logout";
  static const String ticketsDataListEnd = "api/get_tickets_data";
  static const String companyListEnd = "companies";
  static const String sentInviteListEnd = "invites/pending-sent";
  static const String deleteSentInviteEnd = "invites/pending-sent/delete/";
  static const String sendInvitesEnd = "invites/create";
  static const String pendingInvitesEnd = "invites/pending";
  static const String createCompanyEnd = "companies/add-edit";
  static const String acceptInviteEnd = "invites/accept/";
  static const String getUserEnd = "user";
  static const String updateUserEnd = "user/update";
  static const String addRoleEnd = "role/add";
  static const String navigationPermissionEnd = "navigation-items";
  static const String userNAvEnd = "user-company-navigation";
  static const String companyRolesEnd = "role/";
  static const String updateRoleEnd = "role/update/";
  static const String recentUserEnd = "recent?";
  static const String addEditGroupAndBroadcastEnd = "add-edit-group-broadcast";
  static const String uploadMediaEnd = "upload-chat-media";
  static const String groupBrMemEnd = "get-groupbroadcast-members/";
  static const String addMember = "/add-edit-groupbroadcast-member";
  static const String deleteGroupBroadcast = "/delete-group-broadcast";
  static const String taskStatusEnd = "all-task-status";
  static const String uploadTaskMediaEnd = "upload-task-media";
  static const String getTaskEnd = "tasks";
  static const String changePassEnd = "api/change_password";
  static const String getTicketForwardDetails = "api/get_ticket_status_details";
  static const String getTicketStatusEnd = "api/get_ticket_status_by_action";
  static const String getTicketActionEnd = "api/get_ticket_actions";
  static const String getTicketAssignToEnd = "api/checkAssignTo";
  // static const String getTicketStatusEnd = "api/get_ticket_status";
  static const String getTaskGroupEnd = "api/get_task_group";
  static const String getUpdateTicketStatusEnd = "api/update_ticket_status";
  static const String startPauseEnd = "api/start_pause_process";
  static const String addTicketDataEnd = "api/add_ticket_data";
  static const String addTaskSubCatEnd = "api/get_module_obj";
  static const String addTaskActionEnd = "api/get_module_obj_action";
  static const String addTicketEnd = "api/add_ticket";
  static const String dashboardEnd = "api/get_dashboard_detail";
  static const String filterEnd = "api/dashboard_badges_filter";
  static const String getUserChatListEnd = "getUsers";
  static const String getUserChatHistoryEnd = "getUserChat";
  static const String getGroupMemberEnd = "getGroupCollectionMembers";
  static const String getEditGroupEnd = "addEditGroupCollection";
  static const String getaddEditGroupMemberEnd = "addEditGroupCollectionMember";
  static const String getDeleteGroupEnd = "deleteGroupCollection";
  static const String updateProfileEnd = "updateProfile";
  static const String getProfileEnd = "getUserDetail";

}

const String tripOngoing ='ongoing';
const String tripCompleted ='completed';
const String tripCancelled ='cancelled';



