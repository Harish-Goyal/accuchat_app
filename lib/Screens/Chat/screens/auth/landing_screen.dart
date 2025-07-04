import 'package:AccuChat/Screens/Home/Presentation/View/main_screen.dart';
import 'package:AccuChat/utils/custom_flashbar.dart';
import 'package:AccuChat/utils/helper_widget.dart';
import 'package:AccuChat/utils/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../Constants/assets.dart';

import '../../../../Constants/colors.dart';
import '../../../../Constants/themes.dart';
import '../../../../Services/APIs/local_keys.dart';
import '../../../../main.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/custom_dialogue.dart';
import '../../../../utils/gradient_button.dart';
import '../../../../utils/networl_shimmer_image.dart';
import '../../../../utils/text_style.dart';
import '../../../Home/Presentation/View/home_screen.dart';
import '../../../Settings/Presentation/Views/settings_screen.dart';
import '../../../Settings/Presentation/Views/static_page.dart';
import '../../api/apis.dart';
import '../../models/chat_user.dart';
import '../../models/company_model.dart';
import 'create_company_screen.dart';
import 'join_company_screen.dart';
import 'login_screen.dart';

class LandingPage extends StatefulWidget {
  LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    //for auto triggering animation
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() => _isAnimate = true);
    });
  }


  Future<void> signOutUser() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'is_online': false, 'last_active': DateTime.now().millisecondsSinceEpoch});
          APIs.me = ChatUser(
              id: '',
              name: "",
              email:"",
              about:"",
              image:"",
              createdAt: '',

              phone: '',
              isOnline: false,
              lastActive:  "",
              isTyping: false,
              lastMessageTime: '',
              pushToken: '', xStikers: '', role: null, company: [],selectedCompany: null);

        } catch (e) {
          debugPrint('Firestore update failed: $e');
        }
      }
      // Sign out from Google
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }


      // Then sign out from Firebase
      await FirebaseAuth.instance.signOut();

      storage.write(isLoggedIn, false);
      storage.write(isFirstTime, true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreenG()),
      );
      print("User successfully signed out.");
    } catch (e) {
      print("Sign out error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
              onTap: ()async {
                showDialog(
                    context: Get.context!,
                    builder: (_) => CustomDialogue(
                      title: "Logout",
                      isShowAppIcon: false,
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          vGap(20),
                          Text(
                            "Do you really want to Logout?",
                            style: BalooStyles.baloonormalTextStyle(),
                            textAlign: TextAlign.center,
                          ),

                          vGap(30),

                          Row(
                            children: [
                              Expanded(
                                child: GradientButton(
                                  name: "Yes",
                                  btnColor: AppTheme.redErrorColor,

                                  gradient: LinearGradient(colors: [AppTheme.redErrorColor,AppTheme.redErrorColor]),
                                  vPadding: 6,
                                  onTap: () async{
                                    await signOutUser();
                                  },
                                ),
                              ),
                              hGap(15),
                              Expanded(
                                child: GradientButton(
                                  name: "Cancel",
                                  btnColor: Colors.black,
                                  color: Colors.black,
                                  gradient: LinearGradient(colors: [AppTheme.whiteColor,AppTheme.whiteColor]),
                                  vPadding: 6,
                                  onTap: () {
                                    Get.back();
                                  },
                                ),
                              ),
                            ],
                          )
                          // Text(STRING_logoutHeading,style: BalooStyles.baloomediumTextStyle(),),
                        ],
                      ),
                      onOkTap: () {},
                    ));


              },
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.logout)))
        ],
      ),
        //body
        body:Column(
          children: [
            vGap(15),
            Text('Welcome to AccuChat',style: BalooStyles.balooboldTextStyle(size: 16),),
            Image.asset(
              appIcon,
              width: 100,
            ),
            
            Expanded(
              child: Container(
                height: Get.height*.5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FutureBuilder<List<CompanyModel>>(
                        future: APIs.fetchJoinedCompanies(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return SizedBox();
                          final companies = snapshot.data!;
                          return companies.isNotEmpty? Column(
                            children: [
                              Column(
                                children: [
                                  ...companies.map((company) =>
                                      InkWell(
                                        onTap: () async{
                                          print('tapper');
                                          customLoader.show();

                                          final userDoc = FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .doc(APIs.me.id);
                                          await userDoc.update({
                                            // 'company': FieldValue.arrayUnion([company.toJson()]),
                                            'selectedCompany':
                                            company.toJson(),
                                          });


                                          APIs.me.selectedCompany =
                                              company;

                                          if(APIs.me.selectedCompany?.adminUserId==APIs.me.id){
                                            await userDoc.update({
                                              'role': 'admin',
                                            });
                                          }else{
                                            await userDoc.update({
                                              'role': 'member',
                                            });
                                          }
                                          customLoader.hide();
                                          setState(() {});
                                          await APIs.getSelfInfo();
                                          Get.offAllNamed(AppRoutes.home);
                                          /* Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => AccuChatDashboard()));*/
                                        },
                                        child: ChatCard(
                                          iconWidget: SizedBox(
                                            width: 50,
                                            child: CustomCacheNetworkImage(
                                                radiusAll: 100,
                                                company.logoUrl ?? ''),
                                          ),
                                          title: company.name??'',
                                          subtitle:
                                          'Tap to enter this company',
                                          onTap: () async{
                                            print('tapper');
                                            customLoader.show();

                                            final userDoc = FirebaseFirestore
                                                .instance
                                                .collection('users')
                                                .doc(APIs.me.id);
                                            await userDoc.update({
                                              // 'company': FieldValue.arrayUnion([company.toJson()]),
                                              'selectedCompany':
                                              company.toJson(),
                                            });


                                            APIs.me.selectedCompany =
                                                company;

                                            if(APIs.me.selectedCompany?.adminUserId==APIs.me.id){
                                              await userDoc.update({
                                                'role': 'admin',
                                              });
                                            }else{
                                              await userDoc.update({
                                                'role': 'member',
                                              });
                                            }
                                            customLoader.hide();
                                            setState(() {});
                                            await APIs.getSelfInfo();
                                            Get.offAllNamed(AppRoutes.home);
                                            /* Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => AccuChatDashboard()));*/
                                          },),
                                      )
                                  ),
              
                                  vGap(10),
              
                                ],
                              ),
                            ],
                          ):Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              vGap(10),
              
                              Center(child: SizedBox(
                                  width: Get.width*.7,
                                  child:  Text("You are not connected to any company! You can create or join company",textAlign: TextAlign.center,
                                    style: BalooStyles.balooregularTextStyle(),))),
                            ],
                          );
                        },
                      )
                    ],
                  ).marginSymmetric(horizontal: 15),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: dynamicButton(
                          name: "Create Company",
                          onTap: () {
                            if(APIs.me.selectedCompany?.allowedCompany==0)
                            {
                              toast("You are not allowed to create company more than 1! Contact Organization!");
                            }
                            else{
                              Get.to(() =>  CreateCompanyScreen(isHome: false,));
                            }
                          },
                          isShowText: true,
                          isShowIconText: false,
                          gradient: buttonGradient,
                          leanIcon: 'assets/images/google.png'),
                    ),
                  ],
                ).marginSymmetric(horizontal: Get.height * .03),
                vGap(20),
                Row(
                  children: [
                    Expanded(
                      child: dynamicButton(
                          name: "Join Company",
                          onTap: () async{
                            // Get.to(() => JoinCompanyScreen(
                            //   type: 'join',

                            // ));
                            await APIs.handleJoinCompany(context:context, emailOrPhone:APIs.me.phone=='null'?APIs.me.email:APIs.me.phone);

                          },
                          isShowText: true,
                          isShowIconText: false,
                          gradient: buttonGradient,
                          leanIcon: 'assets/images/google.png'),
                    ),
                  ],
                ).marginSymmetric(horizontal: Get.height * .03),




              ],
            ).marginSymmetric(horizontal: 15),
          ],
        )),
        
        
        /*Stack(
            children: [
          //app logo
          AnimatedPositioned(
              top: mq.height * .00,
              right: _isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              duration: const Duration(seconds: 1),
              child: Column(
                children: [
                  vGap(15),
                  Text('Welcome to AccuChat',style: BalooStyles.balooboldTextStyle(size: 16),),

                  Image.asset(
                    appIcon,
                    width: 100,
                  ),

                ],
              )),

          //google login button

          Positioned(
            bottom: mq.height * .01,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .6,
            child: Column(
              children: [
                FutureBuilder<List<CompanyModel>>(
                  future: APIs.fetchJoinedCompanies(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return SizedBox();
                    final companies = snapshot.data!;
                    return companies.isNotEmpty? Column(
                      children: [
                        Column(
                          children: [
                            ...companies.map((company) =>
                            ChatCard(
                                iconWidget: SizedBox(
                                  width: 50,
                                  child: CustomCacheNetworkImage(
                                      radiusAll: 100,
                                      company.logoUrl ?? ''),
                                ),
                                title: company.name??'',
                                subtitle:
                                'Tap to enter this company',
                                onTap: () async{
                                  print('tapper');
                                  customLoader.show();

                                  final userDoc = FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(APIs.me.id);
                                  await userDoc.update({
                                    // 'company': FieldValue.arrayUnion([company.toJson()]),
                                    'selectedCompany':
                                    company.toJson(),
                                  });


                                  APIs.me.selectedCompany =
                                      company;

                                  if(APIs.me.selectedCompany?.adminUserId==APIs.me.id){
                                    await userDoc.update({
                                      'role': 'admin',
                                    });
                                  }else{
                                    await userDoc.update({
                                      'role': 'member',
                                    });
                                  }
                                  customLoader.hide();
                                  setState(() {});
                                  await APIs.getSelfInfo();
                                  Get.offAllNamed(AppRoutes.home);
                                  */
      /* Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => AccuChatDashboard()));*//*
                                },)
                            ),

                            vGap(10),

                          ],
                        ),
                      ],
                    ):Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        vGap(10),

                        Center(child: SizedBox(
                            width: Get.width*.7,
                            child:  Text("You are not connected to any company! You can create or join company",textAlign: TextAlign.center,
                            style: BalooStyles.balooregularTextStyle(),))),
                      ],
                    );
                  },
                )
              ],
            ),
          ),

          Positioned(
            bottom: mq.height * .01,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .13,
            child:
                Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: dynamicButton(
                                  name: "Create Company",
                                  onTap: () {
                                      if(APIs.me.selectedCompany?.allowedCompany==0)
                                      {
                                        toast("You are not allowed to create company more than 1! Contact Organization!");
                                      }
                                    else{
                                      Get.to(() =>  CreateCompanyScreen(isHome: false,));
                                    }
                                  },
                                  isShowText: true,
                                  isShowIconText: false,
                                  gradient: buttonGradient,
                                  leanIcon: 'assets/images/google.png'),
                            ),
                          ],
                        ).marginSymmetric(horizontal: Get.height * .03),
                        vGap(20),
                        Row(
                          children: [
                            Expanded(
                              child: dynamicButton(
                                  name: "Join Company",
                                  onTap: () async{
                                    // Get.to(() => JoinCompanyScreen(
                                    //   type: 'join',

                                    // ));
                                    await APIs.handleJoinCompany(context:context, emailOrPhone:APIs.me.phone=='null'?APIs.me.email:APIs.me.phone);

                                  },
                                  isShowText: true,
                                  isShowIconText: false,
                                  gradient: buttonGradient,
                                  leanIcon: 'assets/images/google.png'),
                            ),
                          ],
                        ).marginSymmetric(horizontal: Get.height * .03),




              ],
            ),
          ),
        ]),*/
        /* body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/company_illustration.png',
                height: 200,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/createCompany'),
                child: const Text('Create a Company'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/joinCompany'),
                child: const Text('Join a Company'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),*/
    );
  }
}
