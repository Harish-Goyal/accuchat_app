import 'dart:math' as math;
import 'package:AccuChat/utils/text_style.dart';
import 'package:flutter/material.dart';

class PendingInvitesCard extends StatefulWidget {
  final int invitesCount;
  final List<String> companyNames;
  final VoidCallback? onTap;

  /// Optional: override brand colors if needed
  final Color primary; // 0xFFffaf2c
  final Color accent;  // 0xFF08c189

  const PendingInvitesCard({
    super.key,
    required this.invitesCount,
    required this.companyNames,
    this.onTap,
    this.primary = const Color(0xFFffaf2c),
    this.accent = const Color(0xFF08c189),
  });

  @override
  State<PendingInvitesCard> createState() => _PendingInvitesCardState();
}

class _PendingInvitesCardState extends State<PendingInvitesCard>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;     // for breathing shadow + sheen
  late final AnimationController _rotateCtrl;   // for subtle rotating highlight
  late final AnimationController _badgeCtrl;    // for pulsing count badge

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _rotateCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  String _companiesPreview() {
    if (widget.companyNames.isEmpty) return "from your network";
    if (widget.companyNames.length == 1) return "from ${widget.companyNames.first}";
    if (widget.companyNames.length == 2) {
      return "from ${widget.companyNames[0]} & ${widget.companyNames[1]}";
    }
    final remaining = widget.companyNames.length - 1;
    return "from ${widget.companyNames.first} +$remaining more";
    // Alternative using total invites:
    // return "from ${widget.companyNames.first} and others";
  }

  @override
  Widget build(BuildContext context) {
    final c1 = widget.primary;
    final c2 = widget.accent;
    final cardRadius = 20.0;

    // breathing shadow value (0..1)
    final glow = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowCtrl, _rotateCtrl]),
        builder: (context, _) {
          final shadowBlur = 18 + (glow.value * 12); // 18..30
          final shadowSpread = 1 + (glow.value * 1.5); // 1..2.5

          return Container(
            height:100,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cardRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  c1.withOpacity(0.95),
                  Color.lerp(c1, c2, 0.5)!.withOpacity(0.92),
                  c2.withOpacity(0.95),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: c1.withOpacity(0.30),
                  blurRadius: shadowBlur,
                  spreadRadius: shadowSpread,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: c2.withOpacity(0.18),
                  blurRadius: shadowBlur * 0.6,
                  spreadRadius: shadowSpread * 0.4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Subtle animated sheen sweeping diagonally
                Transform.rotate(
                  angle: _rotateCtrl.value * 2 * math.pi,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.14),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Moving diagonal light streak
                /*Positioned.fill(
                  child: FractionallySizedBox(
                    alignment: Alignment(-1.0 + (_glowCtrl.value * 2), 0.0),
                    widthFactor: 0.28,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.01),
                            Colors.white.withOpacity(0.12),
                            Colors.white.withOpacity(0.01),
                          ],
                          stops: const [0.2, 2.8, 2.0],
                        ),
                      ),
                    ),
                  ),
                ),*/

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      // Leading icon with subtle pulse ring
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ScaleTransition(
                            scale: _badgeCtrl,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.mark_email_unread_rounded,
                                size: 26,
                                color: c1.withOpacity(0.95),
                              ),
                            ),
                          ),
                          // Count badge
                          Positioned(
                            right: -4,
                            top: -4,
                            child: ScaleTransition(
                              scale: _badgeCtrl,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: Text(
                                  '${widget.invitesCount}',
                                  style: TextStyle(
                                    color: c2.withOpacity(0.95),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // Texts
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.invitesCount > 1
                                        ? "You have ${widget.invitesCount} pending invites"
                                        : "You have 1 pending invite",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: BalooStyles.baloonormalTextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _companiesPreview(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: BalooStyles.baloosemiBoldTextStyle(color: Colors.white.withOpacity(0.92)),
                            ),

                            const SizedBox(height: 10),

                            // CTA chip
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:  [
                                  Text(
                                    "View invites",
                                    style:  BalooStyles.baloosemiBoldTextStyle(color: Colors.white,size: 13),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ink ripple feel on tap (optional)
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: widget.onTap,
                      splashColor: Colors.white.withOpacity(0.08),
                      highlightColor: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
