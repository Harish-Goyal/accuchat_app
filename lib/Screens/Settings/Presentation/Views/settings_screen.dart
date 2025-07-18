import 'package:AccuChat/Constants/themes.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Controllers/settings_controller.dart';
import 'package:AccuChat/Screens/Settings/Presentation/Views/static_page.dart';
import 'package:AccuChat/utils/backappbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/custom_flashbar.dart';
import '../../../Chat/api/apis.dart';
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
    <p style="font-size: 14px; text-align: center; color: #888; margin-top: 20px;">For questions or concerns, contact us at <a href="mailto:accuchat@gmail.com" style="color: #3182ce; text-decoration: none;">accuchat@gmail.com</a>.</p>
</div>

  ''';
class SettingsScreen extends StatelessWidget {
   SettingsScreen({super.key});



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

  <p style="color: grey;">© 2024 accuchat.in. All rights reserved.</p>
  </body>
  </html>

  ''';

  @override
  Widget build(BuildContext context) {
    return   Column(
      children: [
        Row(

              children: [
                // Menu Options
                Flexible(
                  child: ListTile(
                    title: Text(
                      'Privacy Policy',
                      style: BalooStyles.balooregularTextStyle(color:  Colors.blue),
                    ).paddingOnly(left: 30),
                    onTap: () {
                      Get.to(() => HtmlViewer(
                            htmlContent: pvcContent,
                          ));
                      // Navigate to Privacy Policy Page
                    },
                  ),
                ),


                Flexible(
                  child: ListTile(

                    title: Text('About Us',
                        style: BalooStyles.balooregularTextStyle(color: Colors.blue)).paddingOnly(left: 30),
                    onTap: () {
                      Get.to(() => HtmlViewer(
                            htmlContent: aboutUsContent,
                          ));
                    },
                  ),
                ),

                /*ListTile(
                    leading: Icon(Icons.report, color: AppTheme.appColor),
                    title: Text('Reports',style: BalooStyles.baloosemiBoldTextStyle()),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16.0),
                    onTap: () {
                      Get.to(()=>HtmlViewer(htmlContent: controller.reportContent,));
                      // Navigate to Reports Page
                    },
                  ),
                  divider(),*/
              ],
            ),

        vGap(15),

       !(APIs.me.role=='admin')?  TextButton(child: Text("Delete Account",
          style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),), onPressed: ()async{
         await showDeleteAccountDialog(context,APIs.me.id);
          // await deleteCompany(context, widget.company!);

        }):SizedBox()
      ],
    );
  }





   Future<void> showDeleteAccountDialog(BuildContext context, String userId) async {
     final shouldDelete = await showDialog<bool>(
       context: context,
       builder: (context) => AlertDialog(
         backgroundColor: Colors.white,
         actionsAlignment: MainAxisAlignment.center,
         title:  Text('Delete Account',style:BalooStyles.balooboldTitleTextStyle(color: AppTheme.redErrorColor),),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
              Text(
                 'Are you sure you want to permanently delete your account?',
                style: BalooStyles.balooregularTextStyle(),

             ),
              vGap(15),

              Text(
                     'All your messages, group participation, and data will be deleted and cannot be recovered.'
                 ,style: BalooStyles.baloomediumTextStyle(color: AppTheme.redErrorColor),
             ),
           ],
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context, false),
             child:  Text('Cancel',style:BalooStyles.baloomediumTextStyle(),),
           ),
           ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
             onPressed: () => Navigator.pop(context, true),
             child: const Text('Delete'),
           ),
         ],
       ),
     );

     if (shouldDelete == true) {
       // ✅ Call delete function here
       await APIs.deleteUserAccountChunked(userId);

       // Optional: Navigate or show a success snackbar

       // Optional: Sign out and redirect
       // await FirebaseAuth.instance.signOut();
       // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
     }
   }


}
