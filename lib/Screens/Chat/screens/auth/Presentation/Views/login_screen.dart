import 'package:AccuChat/Constants/assets.dart';
import 'package:AccuChat/Constants/colors.dart';
import 'package:AccuChat/Extension/text_field_extenstion.dart';
import 'package:AccuChat/Screens/Chat/screens/auth/Presentation/Controllers/login_controller.dart';
import 'package:AccuChat/utils/text_style.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../../utils/common_textfield.dart';

import 'dart:math' as math;
import 'dart:ui';

import '../../../../../Settings/Presentation/Views/settings_screen.dart';
import '../../../../../Settings/Presentation/Views/static_page.dart';

const Color perplebr = Color(0xFFB397F4);
const Color greenside = Color(0xFF38BBBD);

class LoginScreenG extends StatefulWidget {
  LoginScreenG({super.key});

  @override
  State<LoginScreenG> createState() => _LoginScreenGState();
}

class _LoginScreenGState extends State<LoginScreenG>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _cardController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    _scaleAnim = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: GetBuilder<LoginGController>(
        builder: (controller) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 700;

              return Stack(
                children: [
                  const Positioned.fill(
                    child: _AccuChatAnimatedLightBackground(),
                  ),
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 32 : 18,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 980 : 580,
                          ),
                          child: isWide
                              ? ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 580),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  flex: 6,
                                  child: _LeftBrandPanelOnlyCards(),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  flex: 5,
                                  child: FadeTransition(
                                    opacity: _fadeAnim,
                                    child: SlideTransition(
                                      position: _slideAnim,
                                      child: AnimatedBuilder(
                                        animation: _scaleAnim,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _scaleAnim.value,
                                            child: child,
                                          );
                                        },
                                        child: _LoginFormCard(
                                          formKey: _formKey,
                                          controller: controller,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Column(
                                  children: [
                                    const _TopMobileBrandPanel(),
                                    const SizedBox(height: 18),
                                    FadeTransition(
                                      opacity: _fadeAnim,
                                      child: SlideTransition(
                                        position: _slideAnim,
                                        child: AnimatedBuilder(
                                          animation: _scaleAnim,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _scaleAnim.value,
                                              child: child,
                                            );
                                          },
                                          child: _LoginFormCard(
                                            formKey: _formKey,
                                            controller: controller,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _LeftBrandPanelOnlyCards extends StatefulWidget {
  const _LeftBrandPanelOnlyCards();

  @override
  State<_LeftBrandPanelOnlyCards> createState() =>
      _LeftBrandPanelOnlyCardsState();
}

class _LeftBrandPanelOnlyCardsState extends State<_LeftBrandPanelOnlyCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _floating({
    required Widget child,
    required double phase,
    required double amplitude,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final dy =
            math.sin((_controller.value * 2 * math.pi) + phase) * amplitude;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 25,
            left: 8,
            child: _floating(
              phase: 0.2,
              amplitude: 10,
              child: const _FeatureBubbleCard(
                icon: chatHome,
                title: "Smart Chats",
                subtitle: "Real-time messaging across teams",
                startColor: Color(0xFFEDE7FF),
                endColor: Color(0xFFD7CBFF),
                iconColor: perplebr,
              ),
            ),
          ),

          Positioned(
            top: 140,
            right: 0,
            child: _floating(
              phase: 1.2,
              amplitude: 14,
              child:  _FeatureBubbleCard(
                icon: tasksHomewhite,
                title: "Task Flow",
                subtitle: "Track work, assign and collaborate",
                startColor: appColorYellow.withOpacity(.2),
                endColor:   appColorYellow.withOpacity(.1),
                iconColor: appColorYellow,
              ),
            ),
          ),

      /*    Positioned(
            top: 300,
            left: 170,
            child: _floating(
              phase: 2.0,
              amplitude: 12,
              child: Container(
                width: 130,
                height: 130,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  color: Colors.white.withOpacity(.72),
                  border: Border.all(color: Colors.white.withOpacity(.9)),
                  boxShadow: [
                    BoxShadow(
                      color: perplebr.withOpacity(.10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: greenside.withOpacity(.10),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(appIcon),
              ),
            ),
          ),*/

          Positioned(
            bottom: 160,
            left: 35,
            child: _floating(
              phase: 2.8,
              amplitude: 13,
              child:  _FeatureBubbleCard(
                icon: galleryIconwhite,
                title: "Gallery Space",
                subtitle: "Shared media, files and previews",
                startColor:  greenside.withOpacity(.2),
                endColor:  greenside.withOpacity(.1),
                iconColor: greenside,
              ),
            ),
          ),

          Positioned(
            bottom: 48,
            right: 10,
            child: _floating(
              phase: 3.4,
              amplitude: 16,
              child:  _FeatureBubbleCard(
                icon: connectedAppIcon,
                title: "Multi Company",
                subtitle: "Workspaces for teams and companies",
                startColor: perplebr.withOpacity(.2),
                endColor:  perplebr.withOpacity(.1),
                iconColor: perplebr,
              ),
            ),
          ),

          Positioned(
            right: 20,
            bottom: 170,
            child: _floating(
              phase: 1.7,
              amplitude: 8,
              child: const _MiniTag(title: "Chats", color: perplebr),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 270,
            child: _floating(
              phase: 2.1,
              amplitude: 8,
              child: const _MiniTag(title: "Task Boards", color: greenside),
            ),
          ),
          Positioned(
            right: 330,
            top: -40,
            child: _floating(
              phase: 2.5,
              amplitude: 8,
              child: const _MiniTag(title: "Media Gallery", color: perplebr),
            ),
          ),
          Positioned(
            right:40,
            top: 65,
            child: _floating(
              phase: 2.9,
              amplitude: 8,
              child:  _MiniTag(title: "Team Workspace", color: appColorYellow),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftBrandPanel extends StatefulWidget {
  const _LeftBrandPanel();

  @override
  State<_LeftBrandPanel> createState() => _LeftBrandPanelState();
}

class _LeftBrandPanelState extends State<_LeftBrandPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _floatingCard({
    required Widget child,
    required double phase,
    required double amplitude,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final dy =
            math.sin((_controller.value * 2 * math.pi) + phase) * amplitude;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 700,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// Floating cards full layer
          Positioned.fill(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 80,
                  left: 10,
                  child: _floatingCard(
                    phase: 0.2,
                    amplitude: 10,
                    child: const _FeatureBubbleCard(
                      icon:chatHome,
                      title: "Smart Chats",
                      subtitle: "Real-time messaging across teams",
                      startColor: Color(0xFFEDE7FF),
                      endColor: Color(0xFFD7CBFF),
                      iconColor: perplebr,
                    ),
                  ),
                ),
                Positioned(
                  top: 190,
                  right: 0,
                  child: _floatingCard(
                    phase: 1.1,
                    amplitude: 14,
                    child: const _FeatureBubbleCard(

                      icon: tasksHomewhite,
                      title: "Task Flow",
                      subtitle: "Track work, assign and collaborate",
                      startColor: Color(0xFFE4FBFB),
                      endColor: Color(0xFFD2F3F4),
                      iconColor: greenside,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: 30,
                  child: _floatingCard(
                    phase: 2.0,
                    amplitude: 12,
                    child: const _FeatureBubbleCard(

                      icon: galleryIconwhite,
                      title: "Gallery Space",
                      subtitle: "Shared media, files and previews",
                      startColor: Color(0xFFF7EDFF),
                      endColor: Color(0xFFEBDFFF),
                      iconColor: perplebr,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 20,
                  child: _floatingCard(
                    phase: 3.1,
                    amplitude: 16,
                    child:  _FeatureBubbleCard(

                      icon: connectedAppIcon,
                      title: "Multi Company",
                      subtitle: "Workspaces for teams and companies",
                      startColor: Color(0xFFE8FAFA),
                      endColor: Color(0xFFD3F3F1),
                      iconColor: greenside,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Center content layer
          Align(
            alignment: Alignment.center,
            child: IgnorePointer(
              child: Container(
                width: 520,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   /* Container(
                      width: 104,
                      height: 104,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF1ECFF),
                            Color(0xFFE0F8F8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: perplebr.withOpacity(.18),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                          BoxShadow(
                            color: greenside.withOpacity(.14),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.asset(appIcon),
                    ),*/
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to AccuChat',
                      textAlign: TextAlign.center,
                      style: BalooStyles.balooboldTitleTextStyle(
                        size:kIsWeb? 34:20,
                        color: const Color(0xFF25283A),
                        height: 1.15,
                      )
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Chats, tasks, media sharing and team collaboration for multiple companies — all in one modern workspace.',
                      textAlign: TextAlign.center,
                      style: BalooStyles.baloonormalTextStyle(
                        weight: FontWeight.w500,
                        color: const Color(0xFF6F7487),
                        height: 1.55,
                        size: 15,
                      )
                    ),
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _MiniTag(title: "Chat", color: perplebr),
                        _MiniTag(title: "Task", color: greenside),
                        _MiniTag(title: "Gallery", color: perplebr),
                        _MiniTag(title: "Team Workspace", color: greenside),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopMobileBrandPanel extends StatelessWidget {
  const _TopMobileBrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7F3FF),
            Color(0xFFF3FCFC),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(.9)),
        boxShadow: [
          BoxShadow(
            color: perplebr.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: greenside.withOpacity(.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: const [
          _MiniTag(title: "Chats", color: perplebr),
          _MiniTag(title: "Tasks", color: greenside),
          _MiniTag(title: "Gallery", color: perplebr),
          _MiniTag(title: "Companies", color: greenside),
        ],
      ),
    );
  }
}

class _LoginFormCard extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final LoginGController controller;

  const _LoginFormCard({
    required this.formKey,
    required this.controller,
  });

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _buttonShineController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _buttonShineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _buttonShineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(.72),
            border: Border.all(
              color: Colors.white.withOpacity(.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: perplebr.withOpacity(.10),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: greenside.withOpacity(.10),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width:63,
                      height: 63,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFF1ECFF),
                            Color(0xFFE0F8F8),
                          ],
                        ),
                      ),
                      child: SvgPicture.asset(appIconSvg),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome to AccuChat",
                            style: BalooStyles.balooboldTitleTextStyle(
                              size: 20,
                              color: const Color(0xFF222538),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Chats, tasks, gallery and company workspaces",
                            style: BalooStyles.baloonormalTextStyle(
                              weight: FontWeight.w500,
                              color: const Color(0xFF70768A),
                              size: 13.5,

                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                Text(
                  "Sign in",
                  style: BalooStyles.balooboldTitleTextStyle(
                    size: 30,
                    color: const Color(0xFF222538),
                  )
                ),
                const SizedBox(height: 6),
                Text(
                  "Access your chats, tasks and company workspaces",
                  style: BalooStyles.baloonormalTextStyle(
                    weight: FontWeight.w500,
                    color: const Color(0xFF70768A),
                    size: 14,
                  ),
                ),
                const SizedBox(height: 24),
                _ModernInputField(
                  controller: controller,
                  formKey: widget.formKey,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTap: () {
                    if (widget.formKey.currentState!.validate()) {
                      FocusScope.of(context).unfocus();
                      controller.hitAPIToSendOtp();
                    }
                  },
                  child: AnimatedScale(
                    scale: _pressed ? .98 : 1,
                    duration: const Duration(milliseconds: 110),
                    child: Container(
                      height: 58,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [perplebr, greenside],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: perplebr.withOpacity(.22),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: greenside.withOpacity(.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedBuilder(
                                animation: _buttonShineController,
                                builder: (_, __) {
                                  final x =
                                      (_buttonShineController.value * 2) - 1;
                                  return Transform.translate(
                                    offset: Offset(240 * x, 0),
                                    child: Transform.rotate(
                                      angle: -0.28,
                                      child: Container(
                                        width: 70,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0),
                                              Colors.white.withOpacity(.25),
                                              Colors.white.withOpacity(0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Send OTP",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: .2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        perplebr.withOpacity(.08),
                        greenside.withOpacity(.08),
                      ],
                    ),
                    border: Border.all(
                      color: perplebr.withOpacity(.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: greenside.withOpacity(.14),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: greenside,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Secure OTP access for teams, companies and shared workspaces",
                          style: BalooStyles.baloonormalTextStyle(
                            weight: FontWeight.w500,
                            color: const Color(0xFF60657A),
                            size: 13,
                          )
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _policyText()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _policyText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: const Color(0xFF7A8094).withOpacity(.95),
          fontSize: 12.4,
          height: 1.55,
        ),
        children: [
          const TextSpan(text: "By continuing, you agree to our "),
           TextSpan(
            text: "Terms",
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                Get.to(() => HtmlViewer(
                  htmlContent: tAndCContent,
                ));
              },
            style: TextStyle(
              color: perplebr,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            recognizer: new TapGestureRecognizer()
              ..onTap = () {
                Get.to(() => HtmlViewer(
                  htmlContent: pvcContent,
                ));
              },
            style: const TextStyle(
              color: greenside,
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }
}

class _ModernInputField extends StatelessWidget {
  final LoginGController controller;
  final GlobalKey<FormState> formKey;

  const _ModernInputField({
    required this.controller,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: perplebr.withOpacity(.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: greenside.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomTextField(
        hintText: "Email or Phone".tr,
        controller: controller.phoneController,
        textInputType: TextInputType.emailAddress,
        inputFormatters: controller.showCountryCode
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ]
            : <TextInputFormatter>[],
        validator: (value) {
          return controller.showCountryCode
              ? value?.validateMobile(controller.phoneController.text)
              : value?.isValidEmail();
        },
        onFieldSubmitted: (String? value) {
          if (formKey.currentState!.validate()) {
            FocusScope.of(context).unfocus();
            controller.hitAPIToSendOtp();
          }
        },
        labletext: "Phone or Email",
        prefix: !controller.showCountryCode
            ? const Icon(
                Icons.alternate_email_rounded,
                size: 20,
                color: greenside,
              )
            : CountryCodePicker(
                initialSelection: 'IN',
                showFlagDialog: false,
                showDropDownButton: false,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                boxDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                builder: (code) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (code?.flagUri != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              code!.flagUri!,
                              package: 'country_code_picker',
                              width: 22,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          code?.dialCode ?? '',
                          style: const TextStyle(
                            color: Color(0xFF4B5166),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onChanged: (_) {},
              ),
        onChangee: (v) {
          if (controller.showCountryCode) {
            String cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
            if (cleaned.length > 10) {
              cleaned = cleaned.substring(0, 10);
            }

            if (cleaned != controller.phoneController.text) {
              controller.phoneController.value =
                  controller.phoneController.value.copyWith(
                text: cleaned,
                selection: TextSelection.fromPosition(
                  TextPosition(offset: cleaned.length),
                ),
              );
            }
          }
          controller.onTextChanged(v);
        },
      ),
    );
  }
}

class _FeatureBubbleCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color startColor;
  final Color endColor;
  final Color iconColor;
  final double width;

  const _FeatureBubbleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.startColor,
    required this.endColor,
    required this.iconColor,
    this.width = 230,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width == double.infinity ? null : width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [startColor, endColor],
        ),
        border: Border.all(color: Colors.white.withOpacity(.9)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white.withOpacity(.9),
            ),
            child: SvgPicture.asset(icon, color: iconColor, height: 15,width: 15,),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2B3042),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6D7285),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String title;
  final Color color;

  const _MiniTag({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(.10),
        border: Border.all(color: color.withOpacity(.14)),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _AccuChatAnimatedLightBackground extends StatefulWidget {
  const _AccuChatAnimatedLightBackground();

  @override
  State<_AccuChatAnimatedLightBackground> createState() =>
      _AccuChatAnimatedLightBackgroundState();
}

class _AccuChatAnimatedLightBackgroundState
    extends State<_AccuChatAnimatedLightBackground>
    with TickerProviderStateMixin {
  late AnimationController _blobController;
  late AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _blobController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  Widget _animatedBlob({
    required double size,
    required Alignment alignment,
    required List<Color> colors,
    required double dx,
    required double dy,
  }) {
    return AnimatedBuilder(
      animation: _blobController,
      builder: (_, __) {
        final t = _blobController.value;
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(
              math.sin(t * math.pi * 2 + dx) * 24,
              math.cos(t * math.pi * 2 + dy) * 18,
            ),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(.16),
                    blurRadius: 60,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFDFBFF),
                Color(0xFFF7FBFD),
                Color(0xFFF3F7FC),
              ],
            ),
          ),
        ),
        _animatedBlob(
          size: 240,
          alignment: Alignment.topLeft,
          colors: [
            perplebr.withOpacity(.18),
            perplebr.withOpacity(.05),
          ],
          dx: .5,
          dy: .1,
        ),
        _animatedBlob(
          size: 280,
          alignment: Alignment.topRight,
          colors: [
            appColorYellow.withOpacity(.2),
            appColorYellow.withOpacity(.1),
          ],
          dx: 1.4,
          dy: .8,
        ),
        _animatedBlob(
          size: 260,
          alignment: Alignment.bottomLeft,
          colors: [
            greenside.withOpacity(.10),
            greenside.withOpacity(.03),
          ],
          dx: 2.1,
          dy: 1.6,
        ),
        _animatedBlob(
          size: 220,
          alignment: Alignment.bottomRight,
          colors: [
            perplebr.withOpacity(.12),
            perplebr.withOpacity(.04),
          ],
          dx: 2.8,
          dy: 2.2,
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _orbitController,
            builder: (_, __) {
              return CustomPaint(
                painter: _WorkspaceLinesPainter(
                  progress: _orbitController.value,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkspaceLinesPainter extends CustomPainter {
  final double progress;

  _WorkspaceLinesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = perplebr.withOpacity(.08);

    final linePaint2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = greenside.withOpacity(.08);

    final dotPaint1 = Paint()..color = perplebr.withOpacity(.22);
    final dotPaint2 = Paint()..color = greenside.withOpacity(.22);

    for (double y = 100; y < size.height; y += 120) {
      final path = Path();
      path.moveTo(0, y);
      path.cubicTo(
        size.width * .25,
        y - 20,
        size.width * .55,
        y + 30,
        size.width,
        y - 5,
      );
      canvas.drawPath(path, y % 240 == 100 ? linePaint : linePaint2);
    }

    for (double x = 60; x < size.width; x += 180) {
      final y = 120 + (math.sin((progress * 2 * math.pi) + x / 100) * 50);
      canvas.drawCircle(Offset(x, y), 4, dotPaint1);
    }

    for (double x = 120; x < size.width; x += 220) {
      final y = size.height -
          120 +
          (math.cos((progress * 2 * math.pi) + x / 120) * 40);
      canvas.drawCircle(Offset(x, y), 4, dotPaint2);
    }
  }

  @override
  bool shouldRepaint(covariant _WorkspaceLinesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
/*class LoginScreenG extends GetView<LoginGController> {
   LoginScreenG({super.key});
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: GetBuilder<LoginGController>(
        builder: (controller) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Container(
                width: Get.width,
                height: Get.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage(darkbg),fit: BoxFit.cover,opacity: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 15
                    )
                  ]
                ),

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 500 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            vGap(30),
                            Text('Welcome to AccuChat',style: BalooStyles.balooboldTitleTextStyle(),),
                            vGap(20),
                            Image.asset(
                            // SvgPicture.asset(
                          appIcon,
                          width: isWide ? Get.width * .1 : Get.width * .3,
                          height: isWide ? Get.width * .1 : Get.width * .3,
                        ),
                        Text(
                          "Login with phone or email address!",
                          style: BalooStyles.baloonormalTextStyle(
                              weight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        vGap(30),
                        SizedBox(
                          width: 500,
                          child: CustomTextField(
                            hintText: "Email or Phone".tr,
                            controller: controller.phoneController,
                            textInputType: TextInputType.emailAddress,
                            inputFormatters: controller.showCountryCode
                                ? <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ]
                                : <TextInputFormatter>[],
                            validator: (value) {
                              return controller.showCountryCode
                                  ? value?.validateMobile(
                                      controller.phoneController.text)
                                  : value?.isValidEmail();
                            },
                            onFieldSubmitted: (String? value) {
                              if(_formKey.currentState!.validate()){
                                FocusScope.of(Get.context!).unfocus();
                                controller.hitAPIToSendOtp();
                              }

                            },
                            labletext: "Phone or Email",
                            prefix: !controller.showCountryCode
                                ? Icon(Icons.email_outlined,
                                    size: 18, color: appColorGreen)
                                : CountryCodePicker(
                              initialSelection: 'IN',
                              showFlagDialog: false,
                              showDropDownButton: false,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,            // just in case
                              boxDecoration: const BoxDecoration(
                                color: Colors.transparent,                    // main container transparent
                              ),
                              builder: (code) {
                                return Container(                             // you control the painting
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (code?.flagUri != null)
                                        Image.asset(code!.flagUri!,
                                            package: 'country_code_picker', width: 20),
                                      const SizedBox(width: 6),
                                      Text(code?.dialCode ?? ''),
                                    ],
                                  ),
                                );
                              },
                              onChanged: (_) {

                              },
                            )
                            ,
                            onChangee:(v){
                              if (controller.showCountryCode) {
                                // Remove all non-digits
                                String cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');

                                // Limit to 10 digits
                                if (cleaned.length > 10) {
                                  cleaned = cleaned.substring(0, 10);
                                }

                                // Only update if different to avoid cursor jump
                                if (cleaned != controller.phoneController.text) {
                                  controller.phoneController.value =
                                      controller.phoneController.value.copyWith(
                                        text: cleaned,
                                        selection: TextSelection.fromPosition(
                                          TextPosition(offset: cleaned.length),
                                        ),
                                      );
                                }
                              }
                              controller.onTextChanged(v);
                            } ,
                          ),
                        ),
                        vGap(40),
                        dynamicButton(
                          name: "Send OTP",
                          onTap: () {
                            if(_formKey.currentState!.validate()){
                              FocusScope.of(Get.context!).unfocus();
                              controller.hitAPIToSendOtp();
                            }
                          },
                          isShowText: true,
                          isShowIconText: false,
                          gradient: buttonGradient,
                          leanIcon: 'assets/images/google.png',
                        ),
                        */ /*vGap(35),
                          Row(
                            children: [
                              Expanded(
                                child: dynamicButton(
                                  name: "Login with Google",
                                  onTap: () => controller.handleGoogleBtnClick(),
                                  isShowText: true,
                                  isShowIconText: true,
                                  gradient: buttonGradient,
                                  leanIcon: 'assets/images/google.png',
                                ),
                              ),
                            ],
                          ).marginSymmetric(horizontal: 20),*/ /*
                        vGap(20),
                            SizedBox(
                              width: 500,
                          child: Row(
                            children: [
                              Flexible(child: _policyText()),
                            ],
                          ).marginSymmetric(vertical: 35, horizontal: 20),
                        ),
                                              ],
                                            ).paddingSymmetric(vertical: 5, horizontal: 15),
                      )),
                ),
              );
            },
          );
        },
      ),

      */ /*body: GetBuilder<LoginGController>(
        builder: (controller) {
          return SafeArea(
            child: Stack(children: [
              //app logo
              AnimatedPositioned(
                  top:- mq.height * .01,
                  right: controller.isAnimate ? mq.width * .3 : -mq.width * .5,
                  width: mq.width * .4,
                  duration: const Duration(seconds: 1),
                  child: Image.asset(appIcon,width:200,)),

              //google login button

              Positioned(
                top: mq.height * .2,

                left: mq.width * .05,
                width: mq.width * .9,
                height: mq.height * .6,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              "Login with phone or email address!",
                              style: BalooStyles.baloonormalTextStyle(weight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ).marginSymmetric(horizontal: 20),
                          ),
                        ],
                      ),

                      vGap(30),
                      CustomTextField(
                        hintText: "Email or Phone".tr,
                        controller: controller.phoneController,
                        textInputType:TextInputType.emailAddress,

                        inputFormatters: controller.showCountryCode
                            ? <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ]
                            : <TextInputFormatter>[],
                        onFieldSubmitted: (String? value) {
                          FocusScope.of(Get.context!).unfocus();
                        },
                        labletext: controller.showCountryCode ? 'Phone' : 'Email',

                        prefix: !controller.showCountryCode?Container(
                          child: Icon(Icons.email_outlined,size: 18,color: appColorGreen,),
                        ): Container(
                            margin: const EdgeInsets.all(4),
                            // decoration: BoxDecoration(
                            //   borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30),topLeft: Radius.circular(30)),
                            //   color: Colors.red,
                            //   border: Border.all(color: Colors.grey.shade300, width: 0.5),
                            // ),
                            child: CountryCodePicker(
                                flagWidth: 20.0,
                                initialSelection: 'IN',
                                showCountryOnly: false,
                                padding: EdgeInsets.zero, // No extra padding
                                showFlagDialog: true,
                                backgroundColor: Colors.red,
                                showDropDownButton: false,
                                barrierColor: Colors.black26,
                                enabled: false,
                                boxDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(0)
                                ),

                                onChanged: (value) {
                                  // controller.countryCodeVal = value.dialCode.toString();
                                  // controller.update();
                                })),
                        validator: (value) {
                          if( controller.showCountryCode ){
                            return value?.validateMobile(controller.phoneController.text);
                          } else{
                            return value?.isValidEmail();
                          }

                        },
                        onChangee: controller.onTextChanged,
                      ),
                      vGap(20),
                      dynamicButton(
                          name: "Send OTP",
                          onTap: () {
                            controller.hitAPIToSendOtp();
                          },
                          isShowText: true,
                          isShowIconText: false,
                          gradient: buttonGradient,
                          leanIcon: 'assets/images/google.png'),
                      vGap(35),
                      // Text(
                      //   "or,",
                      //   style: BalooStyles.baloonormalTextStyle(weight: FontWeight.w500),
                      //   textAlign: TextAlign.center,
                      // ),
                      // vGap(35),
                      Row(
                        children: [
                          Expanded(
                            child: dynamicButton(
                                name: "Login with Google",
                                onTap: () {
                                  controller.handleGoogleBtnClick();
                                },
                                isShowText: true,
                                isShowIconText: true,
                                gradient: buttonGradient,
                                leanIcon: 'assets/images/google.png'),
                          ),
                        ],
                      ).marginSymmetric(horizontal: Get.height*.03),

                      vGap(20),

                      Row(
                        children: [
                          Flexible(
                            child: _policyText(),
                          ),
                        ],
                      ).marginSymmetric(vertical:  Get.height*.04,horizontal: Get.height*.03),
                    ],
                  ),
                ),
              ),

            ]),
          );
        }
      ),*/ /*

    );
  }

  _policyText() {
    return Text.rich(
      TextSpan(
          text: "By continuing with Google Sign-In, you agree to our  ".tr,
          style:
              BalooStyles.baloonormalTextStyle(size: 14, color: Colors.black54),
          children: [
            TextSpan(
              text: "Privacy Policy.".tr,
              recognizer: new TapGestureRecognizer()
                ..onTap = () {
                  Get.to(() => HtmlViewer(
                        htmlContent: pvcContent,
                      ));
                },
              style: BalooStyles.baloomediumTextStyle(
                  size: 14, color: appColorGreen),
            ),
          ]),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}*/
