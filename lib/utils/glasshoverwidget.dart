import 'dart:ui';
import 'package:flutter/material.dart';

class GlassHoverWidget extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;

  const GlassHoverWidget({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.onTap,
  });

  @override
  State<GlassHoverWidget> createState() => _GlassHoverWidgetState();
}

class _GlassHoverWidgetState extends State<GlassHoverWidget> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              children: [
                /// Glass blur layer
                if (isHover)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        color: isHover
                            ? Colors.white.withOpacity(.18)
                            : Colors.white.withOpacity(.10),
                      ),
                    ),
                  ),

                /// Animated container for smooth effect
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    border: isHover
                        ? Border.all(color: Colors.white.withOpacity(.25))
                        : null,
                    boxShadow: isHover
                        ? [
                      BoxShadow(
                        color: isHover
                            ? Colors.white.withOpacity(.18)
                            : Colors.white.withOpacity(.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                        : [],
                  ),
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}