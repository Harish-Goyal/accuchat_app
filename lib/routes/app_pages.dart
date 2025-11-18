import 'package:AccuChat/Screens/Authentication/Binding/binding.dart';
import 'package:AccuChat/Screens/Authentication/Presentation/view/change_password.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Bindings/auths_bindings.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/accept_invite_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/create_company_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/login_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Views/verify_otp_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/add_broadcasts_member_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/add_group_members_screens.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/all_users_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/chat_home_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/chat_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/task_chat_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/task_treads_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_tasks/Presentation/Views/view_profile_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/companies_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/invitations_screens.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/invite_member.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/main_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/update_company_screen.dart';
import 'package:AccuChat/Screens/Settings/Bindings/binding.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/all_settings.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/create_role_screen.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/edit_roles_screen.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../Screens/Chat/screens/auth/Presentation/Views/landing_screen.dart';
import '../Screens/Chat/screens/chat_tasks/Bindings/bindings.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Controllers/chat_home_controller.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Views/chat_groups.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Views/chats_broadcasts.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Views/create_broadcast_dialog_screen.dart';
import '../Screens/Chat/screens/chat_tasks/Presentation/Views/show_groups_members_screen.dart';
import '../Screens/Home/Bindings/home_bindings.dart';
import '../Screens/Home/Presentation/View/invite_user_with_role.dart';
import '../Screens/Home/Presentation/View/profile_screen.dart';
import '../Screens/Home/Presentation/View/show_company_members.dart';
import '../Screens/Settings/Presentation/Views/role_list_screen.dart';
import '../Screens/splash/binding/binding.dart';
import '../Screens/splash/presentation/views/splash_screen.dart';
import '../Services/APIs/local_keys.dart';
import '../main.dart';
import 'app_routes.dart';

class AppPages {
  static String get INITIAL => kIsWeb ? AppRoutes.home : AppRoutes.splash;
  static final routes = [
    if (!kIsWeb)
      GetPage(
        name: AppRoutes.splash,
        page: () => SplashScreen(),
        bindings: [SplashBinding()],
      ),
    GetPage(
      name: AppRoutes.home,
      page: () => AccuChatDashboard(),
      bindings: [DashboardBinding(), InitBinding()],
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: AppRoutes.landing_r,
      page: () => LandingPage(),
      bindings: [LandingBinding()],
    ),
    GetPage(
      name: AppRoutes.accept_invite,
      page: () => AcceptInvitationScreen(),
      bindings: [AcceptInviteBinding()],
    ),
    GetPage(
      name: AppRoutes.create_company,
      page: () => CreateCompanyScreen(),
      bindings: [CreateCompanyBinding()],
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => ChangePasswordScreen(),
      bindings: [ChangePassBinding()],
    ),
    GetPage(
      name: AppRoutes.connected_com,
      page: () => CompaniesScreen(),
      bindings: [ConnectAPPBinding()],
    ),
    GetPage(
      name: AppRoutes.invite_member,
      page: () => InviteMembersScreen(),
      bindings: [InviteMemBinding()],
    ),
    GetPage(
      name: AppRoutes.login_r,
      page: () => LoginScreenG(),
      bindings: [LoginGBinding()],
    ),
    GetPage(
      name: AppRoutes.invitations_r,
      page: () => InvitationsScreen(),
      bindings: [InvitationsBinding()],
    ),
    GetPage(
      name: AppRoutes.company_members,
      page: () => CompanyMembers(),
      bindings: [CompanyMemberBinding()],
    ),
    GetPage(
      name: AppRoutes.invite_user_role,
      page: () => InviteUserRoleScreen(),
      bindings: [InviteUserRoleBinding()],
    ),
    GetPage(
      name: AppRoutes.member_sr,
      page: () => GroupMembersScreen(),
      bindings: [GrBrMemberBinding()],
    ),
    GetPage(
      name: AppRoutes.company_update,
      page: () => UpdateCompanyScreen(),
      bindings: [UpdateCompanyBinding()],
    ),
    GetPage(
      name: AppRoutes.add_broadcasts_member,
      page: () => AddBroadcastsMembersScreen(),
      bindings: [AddBroadcastsMemBinding()],
    ),
    GetPage(
      name: AppRoutes.add_group_member,
      page: () => const AddGroupMembersScreen(),
      bindings: [AddGroupMemBinding()],
    ),
    GetPage(
      name: AppRoutes.all_users,
      page: () => const AllUserScreen(),
      bindings: [AllUserScreenBinding()],
    ),
    GetPage(
      name: AppRoutes.GroupChatRoute,
      page: () => GroupChatScreen(),
      bindings: [GroupChatBinding()],
    ),
    GetPage(
      name: AppRoutes.main_chats_r,
      page: () => ChatsHomeScreen(),
      bindings: [ChatHomeBinding()],
    ),
    GetPage(
      name: AppRoutes.chats_li_r,
      page: () => ChatScreen(),
      bindings: [ChatScreenBinding()],
    ),
    GetPage(
      name: AppRoutes.tasks_li_r,
      page: () => TaskScreen(),
      bindings: [TaskScreenBinding()],
    ),
    GetPage(
      name: AppRoutes.chats_broadcasts,
      page: () => BroadcastChatScreen(),
      bindings: [ChatBroadcastBinding()],
    ),
    GetPage(
      name: AppRoutes.create_broadcast_dialog,
      page: () => BroadcastCreateDialog(),
      bindings: [CreateBroadcastBinding()],
    ),
    GetPage(
      name: AppRoutes.task_threads,
      page: () => TaskThreadScreen(),
      bindings: [TaskThreadBinding()],
    ),
    GetPage(
      name: AppRoutes.view_profile,
      page: () => ViewProfileScreen(),
      bindings: [ViewProfileBinding()],
    ),
    GetPage(
      name: AppRoutes.all_settings,
      page: () => AllSettingsScreen(),
      bindings: [AllSettingsBinding()],
    ),
    GetPage(
      name: AppRoutes.create_role,
      page: () => CreateRoleScreen(),
      bindings: [CreateRoleBinding()],
    ),
    GetPage(
      name: AppRoutes.h_profile,
      page: () => ProfileScreen(),
      bindings: [HProfileBinding()],
    ),
    GetPage(
      name: AppRoutes.roles,
      page: () => RoleListScreen(),
      bindings: [RoleListBinding()],
    ),
    GetPage(
      name: AppRoutes.edit_role,
      page: () => EditRoleScreen(),
      bindings: [EditRoleBinding()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => SettingsScreen(),
      bindings: [SettingsBinding()],
    ),
    GetPage(
      name: AppRoutes.verify_otp,
      page: () => VerifyOtpScreen(),
      bindings: [VerifyOTPBinding()],
    ),
  ];
}
