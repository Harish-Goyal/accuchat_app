import 'package:AccuChat/Screens/Home/Presentation/Controller/home_controller.dart';
import 'package:AccuChat/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../Services/APIs/local_keys.dart';
import '../../../../Services/APIs/post/post_api_service_impl.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/api/apis.dart';
import '../../../Chat/models/get_company_res_model.dart';
import '../../../Chat/screens/auth/models/get_uesr_Res_model.dart';
import '../../../Home/Presentation/Controller/company_service.dart';
import '../../Model/get_company_roles_res_moel.dart';
import '../../Model/get_nav_permission_res_model.dart';
import '../Views/static_page.dart';

class AllSettingsController extends GetxController {
  String pvcContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Privacy Policy - AccuChat App</title>
</head>
<body>
    <h1>Privacy Policy for AccuChat App</h1>

    <p>AccuChat ("we", "our", or "us") respects your privacy and is committed to protecting it. This Privacy Policy outlines the types of personal information we collect and how we use, share, and protect that information.</p>

    <h2>1. Information We Collect</h2>
    <p>We collect information from you when you use the AccuChat app, register an account, create or join a company, send messages, or upload media. The information we collect includes:</p>
    <ul>
        <li><strong>Personal Identification Information:</strong> Name, Email address, Phone number, Profile information</li>
        <li><strong>Device and Usage Information:</strong> Device information (model, OS version, etc.), Location information, Log data (IP address, browser type, etc.), Usage data (activity within the app)</li>
        <li><strong>Company Data:</strong> Company name, Company logo, Company members, Invitations (sent/received)</li>
        <li><strong>Messages and Media:</strong> Messages (text, images, documents), Media files uploaded (images, PDFs, docs, etc.), Media file URLs (stored in Firebase storage)</li>
    </ul>

    <h2>2. How We Use Your Information</h2>
    <p>We use your personal information to:</p>
    <ul>
        <li>Provide, personalize, and improve the AccuChat app and its services.</li>
        <li>Communicate with you about your account and related services.</li>
        <li>Notify you about invitations to join companies, new messages, and updates.</li>
        <li>Facilitate messaging and task management functionalities within the app.</li>
        <li>Process and store the media files you upload.</li>
    </ul>

    <h2>3. How We Protect Your Information</h2>
    <p>We implement appropriate technical and organizational measures to protect the information you provide from unauthorized access, alteration, disclosure, or destruction. This includes encryption, firewalls, and secure storage in Firebase.</p>
    <p>However, no data transmission or storage method is 100% secure, and we cannot guarantee the absolute security of your personal data.</p>

    <h2>4. Data Sharing and Disclosure</h2>
    <p>We do not sell, rent, or share your personal information with third parties for their marketing purposes without your consent. However, we may share your data in the following situations:</p>
    <ul>
        <li><strong>With Service Providers:</strong> We may share your data with third-party service providers to assist us in providing the app’s services (e.g., Firebase, Cloud Storage, and Firebase Messaging).</li>
        <li><strong>Legal Compliance:</strong> We may disclose your information if required to do so by law, or in response to valid requests by public authorities (e.g., a court or government agency).</li>
    </ul>

    <h2>5. Retention of Your Information</h2>
    <p>We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required by law. You can request the deletion of your data at any time by contacting us at [Insert Contact Email].</p>

    <h2>6. Your Data Protection Rights</h2>
    <p>You have the right to:</p>
    <ul>
        <li><strong>Access</strong> your personal data.</li>
        <li><strong>Rectify</strong> any incorrect or incomplete data.</li>
        <li><strong>Request deletion</strong> of your personal data.</li>
        <li><strong>Object</strong> to the processing of your data for legitimate reasons.</li>
        <li><strong>Withdraw consent</strong> if you previously consented to the processing of your personal data.</li>
    </ul>
    <p>To exercise any of these rights, please contact us at [Insert Contact Email].</p>

    <h2>7. Third-Party Links</h2>
    <p>AccuChat may contain links to third-party websites or services. We are not responsible for the privacy practices or the content of these third parties. We encourage you to read their privacy policies before providing any personal information.</p>

    <h2>8. Cookies</h2>
    <p>We do not use cookies or similar tracking technologies in the AccuChat app. However, third-party services (such as Firebase and Firebase Analytics) may use cookies for analytics purposes.</p>

    <h2>9. Children's Privacy</h2>
    <p>AccuChat is not intended for use by children under the age of 13. We do not knowingly collect personal information from children. If we discover that we have collected personal information from a child under 13, we will delete that information as quickly as possible. If you believe we have inadvertently collected information from a child, please contact us immediately.</p>

    <h2>10. Changes to This Privacy Policy</h2>
    <p>We may update this Privacy Policy from time to time. Any changes will be posted on this page with an updated effective date. Please review this Privacy Policy periodically to stay informed about how we are protecting your information.</p>

    <h2>11. Contact Us</h2>
    <p>If you have any questions or concerns about this Privacy Policy, please contact us at:</p>
    <p><strong>Email:</strong>accuchat@gmail.com</p>
</body>
</html>

  ''';

  String aboutUsContent = '''
      <!DOCTYPE html>
  <html>
  <head>
  <title>About Us</title>
  </head>
  <body style="font-family: sans-serif;">
  <h1>About Us</h1>

  <p><strong>App Name:</strong> AccuChat</p>

  <p><strong>Version:</strong> 1.0.0</p>

  <p><strong>What is AccuChat?</strong><br>
  AccuChat is a smart productivity and messaging app built to streamline team communication and task management. It combines chat, task tracking, and collaboration — all in one place.</p>

  <ul>
  <li>💬 Real-time Chat with individuals, groups, and even yourself</li>
  <li>📝 Task Messaging with time estimates and automatic reminders, and even yourself you can assign task and forward than to anybody you want</li>
  <li>⏰ Timely alerts when deadlines are missed</li>
  <li>🧵 Threaded replies for deep task discussions</li>
  <li>📊 Dashboard views for filtering tasks by status and date</li>
  </ul>

  <p><strong>Our Mission:</strong><br>
  To make communication actionable. With AccuChat, chats become tasks, and tasks become achievements.</p>

  <p><strong>Contact Us:</strong><br>
  📧 <a href="mailto:accuchat@gmail.com">accuchat@gmail.com</a></p>

  <p style="color: grey;">©2025 accuchat.in. All rights reserved.</p>
  </body>
  </html>

  ''';


  Future<void> openAppSettingsPage() async {
    final opened = await openAppSettings();
    if (!opened) {
      // Could not open settings; you might show an error dialog here.
      print('Error: Unable to open app settings');
    }
  }



  CompanyData? myCompany = CompanyData();

  _getCompany()async {
    final svc = CompanyService.to;
    myCompany =  svc.selected;
    Get.find<DashboardController>().getCompany();

    // hitAPIToGetNavPermissions();
    // Future.delayed(Duration(milliseconds: 500),(){
    //   getUserNavigation();
    // });
/*

   hitAPIToGetAllRolesAPI();
    Future.delayed(Duration(milliseconds: 800), () {

      if(myCompany?.userCompanies?.userCompanyRoleId!=null || myCompany?.userCompanies?.userCompanyRole!=null){
      final selectedRoleId = myCompany?.userCompanies?.userCompanyRoleId;
      final selectedCompanyId = myCompany?.companyId;



// 3. Find the matching RoleData
      final matchingRole = rolesList.firstWhere(
            (r) =>
        r.userCompanyRoleId == selectedRoleId &&
            r.companyId == selectedCompanyId,
        orElse: () => RolesData(),
      );


// 4. Finally, extract its navigation items (or empty list if none)
      final navigationItems = matchingRole.navigationItems ??
          <NavigationItem>[];

      saveNavigation(navigationItems);

      getUserNavigation();
      }
      else{

        hitAPIToGetNavPermissions();
        Future.delayed(Duration(milliseconds: 500),(){
          getUserNavigation();
        });
      }
    });
*/


    // hitAPIToGetNavPermissions();

  }

  bool isLoadingPer = true;

  hitAPIToGetNavPermissions() async {
    Get.find<PostApiServiceImpl>()
        .getNavPerUSerApiCall(comId: myCompany?.companyId??0,userComId: APIs.me.userCompany?.userCompanyRoleId??0)
        .then((value) async {
      isLoadingPer=false;
      userNav = value.data??[];
      getUserNavigation();
      update();
    }).onError((error, stackTrace) {
      isLoadingPer=false;
      update();
    });
  }

  IconData iconForSetting(NavigationItem nav) {
    switch (nav.navigationItem) {
      case 'Profile':
        return Icons.person;
      case 'Privacy Policy':
        return Icons.privacy_tip_outlined;
      case 'About Us':
        return Icons.info_outline;
      case 'Manage Roles':
        return Icons.people_outline;
      case 'Support':
        return Icons.support_agent;
      case 'App Settings':
        return Icons.settings;
      default:
        return Icons.chevron_right;
    }
  }

  VoidCallback onTapForSetting(NavigationItem nav, AllSettingsController ctl) {
    switch (nav.navigationItem) {
      case 'Profile':
        return () => Get.toNamed(AppRoutes.h_profile);
      case 'Privacy Policy':
        return () => Get.to(() => HtmlViewer(htmlContent: ctl.pvcContent));
      case 'About Us':
        return () => Get.to(() => HtmlViewer(htmlContent: ctl.aboutUsContent));
      case 'Manage Roles':
        return () => Get.toNamed(AppRoutes.roles);
      case 'Support':
        return () { toast('Under Development!'); };
      case 'App Settings':
        return () => ctl.openAppSettingsPage();
      default:
        return () {};
    }
  }



  UserDataAPI? me = UserDataAPI();
  _getMe()async{
    me = getUser();
    update();
  }




  List<RolesData> rolesList=[];
  Future<void> hitAPIToGetAllRolesAPI() async {
    Get.find<PostApiServiceImpl>()
        .getCompanyRolesApiCall(myCompany?.companyId)
        .then((value) async {
      rolesList = value.data??[];
      update();
    }).onError((error, stackTrace) {
      update();
    });
  }
  List<NavigationItem> settingsItems=[];
  List<NavigationItem>? userNav=[];

  bool isLoading = false;
  getUserNavigation(){
    isLoading = true;
    update();
    userNav = (userNav??[])
    .where((nav) => nav.navigationPlace == settings_key)
    .toList();
    settingsItems =(userNav??[])
        .where((nav) => nav.navigationPlace == settings_key && nav.isActive == 1)
        .toList()
    // sort by your configured order
      ..sort((a, b) => (a.sortingOrder??0).compareTo(b.sortingOrder??0));
    isLoading = false;
    update();
  }



  @override
  void onInit() {
    _getCompany();

    _getMe();
    super.onInit();
  }


}