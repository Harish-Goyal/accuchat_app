import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../Constants/assets.dart';

class NoInternetDialog extends StatefulWidget {
  const NoInternetDialog({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  State<NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<NoInternetDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _scale = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);

    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = math.min(MediaQuery.of(context).size.width * 0.92, 420.0);

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: w),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white,
                      // theme.colorScheme.surface.withOpacity(0.92),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 14),
                      color: Colors.black.withOpacity(0.18),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _WifiPulseIcon(),
                    const SizedBox(height: 14),

                    Text(
                      "You're offline",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      "We can’t reach the internet right now.\nPlease check your connection.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.35,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),
                    const _ReconnectTicker(),
                    const SizedBox(height: 16),

                    /*Row(
                      children: [
                        Expanded(
                          child: _SoftButton(
                            icon: Icons.refresh_rounded,
                            label: "Retry",
                            onTap: widget.onRetry,
                          ),
                        ),
                      ],
                    ),*/
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

class _WifiPulseIcon extends StatefulWidget {
  const _WifiPulseIcon();

  @override
  State<_WifiPulseIcon> createState() => _WifiPulseIconState();
}

class _WifiPulseIconState extends State<_WifiPulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value; // 0..1
        final scale = 1.0 + (t * 0.06);
        final glow = 0.20 + (t * 0.22);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.error.withOpacity(glow),
                  theme.colorScheme.error.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.error.withOpacity(0.10),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.25),
                  ),
                ),
                child: Image.asset(
                  wifiPng,
                  height: 20,
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReconnectTicker extends StatefulWidget {
  const _ReconnectTicker();

  @override
  State<_ReconnectTicker> createState() => _ReconnectTickerState();
}

class _ReconnectTickerState extends State<_ReconnectTicker> {
  int _dots = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 450));
      setState(() => _dots = (_dots + 1) % 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = "Trying to reconnect${"." * _dots}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: theme.colorScheme.primary.withOpacity(0.10),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
