
import 'package:get/get.dart';


class SettingsController extends GetxController {
  String pvcContent = '''
  <!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Privacy Policy - Stack Overlaugh</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 20px;
      background-color: #f8f8f8;
      color: #333;
    }
    h1, h2, h3 {
      color: #222;
    }
    ul {
      margin-left: 20px;
    }
    .section {
      margin-bottom: 30px;
    }
  </style>
</head>
<body>
  <h1>Privacy Policy</h1>
  <p><strong>Effective Date:</strong> [Insert Date]</p>

  <div class="section">
    <h2>1. Introduction</h2>
    <p>Welcome to <strong>AccuChat</strong>! This Privacy Policy explains how we collect, use, and share your data when you use our chat and task management app.</p>
  </div>

  <div class="section">
    <h2>2. Data We Collect</h2>
    <ul>
      <li><strong>Google Sign-In:</strong> Name, email, profile picture</li>
      <li><strong>App Data:</strong> Chat messages, tasks (title, description, time, status), timestamps</li>
      <li><strong>Device Info:</strong> OS version, device model (for debugging)</li>
    </ul>
  </div>

  <div class="section">
    <h2>3. How We Use Your Data</h2>
    <ul>
      <li>Authenticate with Google</li>
      <li>Deliver messaging and task updates</li>
      <li>Store chat and task history securely</li>
      <li>Improve user experience and features</li>
    </ul>
  </div>

  <div class="section">
    <h2>4. Data Security</h2>
    <p>Your data is encrypted and stored securely on Google Firebase. Only you can access your personal chats and tasks.</p>
  </div>

  <div class="section">
    <h2>5. User Rights</h2>
    <ul>
      <li>Log out at any time</li>
      <li>Delete your data or request deletion</li>
      <li>Control your profile information</li>
    </ul>
  </div>

  <div class="section">
    <h2>6. Data Sharing</h2>
    <p>We do not sell or share your data with third parties. We may share data only if required by law.</p>
  </div>

  <div class="section">
    <h2>7. Google Sign-In Compliance</h2>
    <p>We follow <a href="https://developers.google.com/terms/api-services-user-data-policy" target="_blank">Google API Services User Data Policy</a> and <a href="https://support.google.com/cloud/answer/9110914" target="_blank">OAuth Limited Use Policy</a>.</p>
  </div>

  <div class="section">
    <h2>8. Children’s Privacy</h2>
    <p>This app is not intended for children under 13. We do not knowingly collect data from children.</p>
  </div>

  <div class="section">
    <h2>9. Changes to Policy</h2>
    <p>We may update this policy. You’ll be notified of any changes via the app.</p>
  </div>

  <div class="section">
    <h2>10. Contact Us</h2>
    <p>Email: support@stackoverlaugh.com<br />Website: www.stackoverlaugh.com</p>
  </div>
</body>
</html>

  ''';

  String tAndCContent = '''
<div style="font-family: 'Arial', sans-serif; line-height: 1.8; color: #444; max-width: 800px; margin: auto; padding: 20px; background: #f9f9f9; border-radius: 10px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);">
    <h1 style="color: #1c61a6; text-align: center; margin-bottom: 20px;">Terms and Conditions</h1>
    <p style="font-size: 16px;">By using <strong>AccuChatPro</strong>, you agree to the following terms and conditions:</p>
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Eligibility</h2>
    <ul style="list-style-type: disc; margin-left: 0px; font-size: 15px;">
        <li>You must be at least 18 years old to use this app.</li>
        <li>All information provided must be accurate and up to date.</li>
    </ul>
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">App Usage</h2>
    <ul style="list-style-type: disc; margin-left: 0px; font-size: 15px;">
        <li>You agree not to use the app for any unlawful or malicious activities.</li>
        <li>We reserve the right to suspend or terminate accounts for violations.</li>
    </ul>
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Liability</h2>
    <p style="font-size: 15px;">While we strive to provide a seamless experience, <strong>AccuChatPro</strong> is not responsible for any data loss or damages caused by the app.</p>
    <p style="font-size: 14px; text-align: center; color: #888; margin-top: 20px;">For questions or concerns, contact us at <a href="mailto:app.AccuChatpro.com" style="color: #3182ce; text-decoration: none;">app.AccuChatpro.com</a>.</p>
</div>

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
  📧 <a href="mailto:support@AccuChat.app">support@AccuChat.app</a></p>

  <p style="color: grey;">©2025 AccuChat. All rights reserved.</p>
  </body>
  </html>

  ''';

  String reportContent = '''
<div style="font-family: 'Arial', sans-serif; line-height: 1.8; color: #444; max-width: 800px; margin: auto; padding: 20px; background: #f9f9f9; border-radius: 10px; box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);">
    <h1 style="color: #1c61a6; text-align: center; margin-bottom: 20px;">Report</h1>
    <p style="font-size: 16px; text-align: justify;">By accessing the <strong>Reports</strong> section in <strong>AccuChatPro</strong>, you agree to the following terms and conditions. These guidelines ensure the proper use and confidentiality of the data presented in the reports.</p>
    
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Purpose of Reports</h2>
    <ul style="list-style-type: disc; margin-left: 0px; font-size: 15px;">
        <li>Reports are intended to provide insights into task activities, team performance, and project progress.</li>
        <li>Reports must be used solely for personal or organizational productivity improvement.</li>
    </ul>
    
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Access Rights</h2>
    <ul style="list-style-type: disc; margin-left: 0px; font-size: 15px;">
        <li>Only authorized users with valid accounts can access reports.</li>
        <li>Access is limited to the reports generated by your tasks, teams, or projects.</li>
    </ul>
    
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Confidentiality</h2>
    <p style="font-size: 15px;">All report data is confidential and should not be shared or distributed without explicit permission from the respective team or project members.</p>
    
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Restrictions</h2>
    <ul style="list-style-type: disc; margin-left: 0px; font-size: 15px;">
        <li>You must not modify, tamper with, or misrepresent the data in reports.</li>
        <li>Reports must not be used for any unauthorized or illegal purposes.</li>
    </ul>
    
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Liability</h2>
    <p style="font-size: 15px;">While we strive to ensure accuracy, <strong>AccuChatPro</strong> is not responsible for any discrepancies, losses, or misuse of report data.</p>
    
    <h2 style="color: #1c61a6; border-bottom: 2px solid #ddd; padding-bottom: 5px;">Changes to Terms</h2>
    <p style="font-size: 15px;">We reserve the right to update these terms at any time. Continued access to reports signifies acceptance of the revised terms.</p>
    
    <p style="font-size: 15px; text-align: center; color: #888; margin-top: 20px;">For more information or concerns, contact us at <a href="mailto:app.AccuChatpro.com" style="color: #3182ce; text-decoration: none;">app.AccuChatpro.com</a>.</p>
</div>
  ''';

  @override
  void onInit() {
    super.onInit();
  }

  /* //login api
  hitAPIToLogout() async {
    customLoader.show();
    FocusManager.instance.primaryFocus!.unfocus();
    var logoutReq = multi.FormData.fromMap({
      "auth_key": ApiEnd.authKEy,
      "access_token": storage.read(LOCALKEY_token),
      "user_id": storage.read(userId),
    });

    Get.find<AuthApiServiceImpl>()
        .logoutApiCall(dataBody: logoutReq)
        .then((value) async {
      customLoader.hide();
      storage.remove(isLoggedIn);
      storage.remove(LOCALKEY_token);
      storage.remove(isFirstTime);

      Get.offAllNamed(AppRoutes.login);
    }).onError((error, stackTrace) {
      customLoader.hide();
      errorDialog(error.toString());
    });
  }
*/
}
