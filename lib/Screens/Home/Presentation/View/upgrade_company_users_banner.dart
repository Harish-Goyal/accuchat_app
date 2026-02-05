import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../Constants/colors.dart';
import '../../../../utils/text_style.dart';
import '../../../../utils/helper_widget.dart';
import 'buy_users_dialog.dart';

class UpgradeUsersBanner extends StatefulWidget {
  final int currentUsers;
  final int includedUsers;
  final int softLimit;
  final VoidCallback? onTap;

  const UpgradeUsersBanner({
    super.key,
    required this.currentUsers,
    this.includedUsers = 20,
    this.softLimit = 20,
    this.onTap,
  });

  @override
  State<UpgradeUsersBanner> createState() => _UpgradeUsersBannerState();
}

class _UpgradeUsersBannerState extends State<UpgradeUsersBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  double get _progress {
    final base = widget.includedUsers;
    if (base <= 0) return 1;
    return (widget.currentUsers / base).clamp(0, 2).toDouble();
  }

  Future<void> _openDialog() async {
    if (widget.onTap != null) return widget.onTap!.call();

    await showDialog(
      context: context,
      builder: (_) => const BuyCompanyPackDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOverLimit = widget.currentUsers > widget.includedUsers;
    final int extra = math.max(0, widget.currentUsers - widget.includedUsers);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _openDialog,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: _hover ? 1.01 : 1.0,
          child: _AnimatedGradientCard(
            controller: _ac,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top row: title + mini badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Upgrade users pack',
                            style: BalooStyles.balooboldTitleTextStyle(size: 18,color: Colors.white),
                          ),
                        ),
                        // _BadgeChip(
                        //   text: 'Per company 20 users free',
                        //   bg: Colors.white.withOpacity(0.18),
                        // ),
                      ],
                    ),
                    vGap(10),
                    // Middle: usage line and progress
                    Row(
                      children: [
                        Icon(
                          isOverLimit
                              ? CupertinoIcons.person_3_fill
                              : CupertinoIcons.person_2,
                          color: Colors.white,
                          size: 20,
                        ),
                        hGap(8),
                        Expanded(
                          child: Text(
                            'You’re using ${widget.currentUsers} users'
                                ' • Free ${widget.includedUsers}',
                            style: BalooStyles.baloonormalTextStyle()
                                .copyWith(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    vGap(10),
                    _AnimatedProgressBar(
                      controller: _ac,
                      value: _progress.clamp(0, 1),
                      over: _progress > 1.0,
                    ),
                    vGap(8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            /*isOverLimit
                                ? 'You’re over the free limit by $extra users.'
                                : */'Buy more users : ',
                            style: BalooStyles.baloomediumTextStyle()
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        _PillButton(
                          onTap: _openDialog,
                          label: 'Upgrade',
                          icon: CupertinoIcons.arrow_up_circle_fill,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientCard extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  const _AnimatedGradientCard({
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final shift = (t * 600) % 600;

        return CustomPaint(
          painter: _SparklePainter(t),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment(-1 + t, -1),
                end: Alignment(1 - t, 1),
                colors: [
                  appColorPerple.withOpacity(0.85),
                  appColorYellow.withOpacity(0.7),
                  appColorPerple.withOpacity(0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
                transform: GradientRotation(shift / 600 * math.pi * 2),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  _SparklePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint()..color = Colors.white.withOpacity(0.20);

    for (int i = 0; i < 10; i++) {
      final baseX = size.width * (rnd.nextDouble());
      final baseY = size.height * (rnd.nextDouble());
      final dx = baseX + math.sin((t * 2 * math.pi) + i) * 20;
      final dy = baseY + math.cos((t * 2 * math.pi) + i) * 8;
      final r = 1.5 + (i % 3) * 0.6;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}

class _AnimatedProgressBar extends StatelessWidget {
  final AnimationController controller;
  final double value; // 0..1
  final bool over;
  const _AnimatedProgressBar({
    required this.controller,
    required this.value,
    this.over = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.white.withOpacity(0.18)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: over
                        ? [Colors.deepOrangeAccent.withOpacity(0.05), Colors.deepOrangeAccent.withOpacity(0.1)]
                        : [Colors.white, Colors.white.withOpacity(0.75)],
                  ),
                ),
              ),
            ),
            // Shimmer highlight
            AnimatedBuilder(
              animation: controller,
              builder: (_, __) {
                final x = (controller.value * 1.2) - 0.1;
                return Align(
                  alignment: Alignment(x * 2 - 1, 0),
                  child: Container(
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.deepOrangeAccent.withOpacity(0.0),
                          Colors.white.withOpacity(0.45),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String text;
  final Color bg;
  const _BadgeChip({required this.text, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: BalooStyles.baloonormalTextStyle(size: 12),
      ),
    );
  }
}

class _PillButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  const _PillButton({
    required this.onTap,
    required this.label,
    required this.icon,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _ac,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: appColorGreen),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: BalooStyles.baloosemiBoldTextStyle()
                    .copyWith(color: appColorGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
