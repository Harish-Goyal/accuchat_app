import 'package:AccuChat/Screens/Authentication/Binding/binding.dart';
import 'package:AccuChat/Screens/Authentication/Presentation/view/change_password.dart';
import 'package:AccuChat/Screens/Authentication/Presentation/view/login_screen.dart';
import 'package:AccuChat/Screens/Chat/screens/chat_home_screen.dart';
import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/Screens/Home/Presentation/View/main_screen.dart';
import 'package:AccuChat/Screens/Settings/Bindings/binding.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/settings_screen.dart';
import 'package:AccuChat/Screens/chat_module/presentation/views/add_member_page.dart';
import 'package:get/get.dart';
import '../Screens/Chat/screens/auth/landing_screen.dart';
import '../Screens/Chat/screens/auth/login_screen.dart';
import '../Screens/Chat/screens/chat_screen.dart';
import '../Screens/Home/Bindings/home_bindings.dart';
import '../Screens/chat_module/binding/binding.dart';
import '../Screens/chat_module/presentation/views/chatting_deatail_screen.dart';
import '../Screens/chat_module/presentation/views/group_member_page.dart';
import '../Screens/chat_module/presentation/views/profile_sreen.dart';
import '../Screens/chat_module/presentation/views/user_chat_list_screen.dart';
import '../Screens/splash/binding/binding.dart';
import '../Screens/splash/presentation/views/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.splash;
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashScreen(),
      bindings: [SplashBinding(), InitBinding()],
    ),GetPage(
      name: AppRoutes.home,
      page: () => AccuChatDashboard(),
      bindings: [DashboardBinding(),ChatUserListBinding(),ProfileBinding()],
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreenG(),
      // bindings: [AuthenticationBinding()],
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => ChangePasswordScreen(),
      bindings: [ChangePassBinding()],
    ),
    // GetPage(
    //   name: AppRoutes.chatDetail,
    //   // page: () =>  UserChatDetailScreen(),
    //   page: () =>  ChatScreen(),
    //   // bindings: [ChatBinding()],
    // ),
    GetPage(
      name: AppRoutes.userChatListScreen,
      // page: () => const UserChatListScreen(),
      page: () =>  ChatsHomeScreen(),
      // bindings: [ChatUserListBinding()],
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () =>  SettingsScreen(),
      bindings: [SettingsBinding()],
    ),  GetPage(
      name: AppRoutes.groupMember,
      page: () =>  GroupMembersPage(),
      bindings: [GroupMemberBinding()],
    ),GetPage(
      name: AppRoutes.profile,
      page: () =>  UserProfileScreen(),
      bindings: [ProfileBinding()],
    ),

    GetPage(
      name: AppRoutes.addMemberPage,
      page: () =>  AddMemberPage(),
      bindings: [GroupMemberBinding(),ChatBinding()],
    ),

  ];
}
