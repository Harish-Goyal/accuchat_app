import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HoverGlassEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double hoverScale;
  final double normalBlur;
  final double hoverBlur;
  final double normalOpacity;
  final double hoverOpacity;
  final Duration duration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final List<BoxShadow>? normalShadow;
  final List<BoxShadow>? hoverShadow;
  final bool enableHoverEffect;
  final MouseCursor cursor;
  final Alignment alignment;
  final Gradient? gradient;
  final Gradient? hoverGradient;

  const HoverGlassEffect({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 16,
    this.hoverScale = 1.02,
    this.normalBlur = 4,
    this.hoverBlur = 12,
    this.normalOpacity = 0.18,
    this.hoverOpacity = 0.28,
    this.duration = const Duration(milliseconds: 220),
    this.padding,
    this.margin,
    this.borderColor,
    this.hoverBorderColor,
    this.normalShadow,
    this.hoverShadow,
    this.enableHoverEffect = true,
    this.cursor = SystemMouseCursors.click,
    this.alignment = Alignment.center,
    this.gradient,
    this.hoverGradient,
  });

  @override
  State<HoverGlassEffect> createState() => _HoverGlassEffectState();
}

class _HoverGlassEffectState extends State<HoverGlassEffect> {
  bool _isHover = false;

  bool get _canHover => kIsWeb && widget.enableHoverEffect;

  void _setHover(bool value) {
    if (!_canHover) return;
    if (_isHover == value) return;
    setState(() => _isHover = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);

    final defaultNormalShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(.04),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ];

    final defaultHoverShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(.06),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];

    final borderClr = _isHover
        ? (widget.hoverBorderColor ?? Colors.white.withOpacity(.35))
        : (widget.borderColor ?? Colors.white.withOpacity(.22));

    final bgColor = Colors.white.withOpacity(
      _isHover ? widget.hoverOpacity : widget.normalOpacity,
    );

    final appliedGradient = _isHover
        ? (widget.hoverGradient ?? widget.gradient)
        : widget.gradient;

    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: AnimatedScale(
        scale: _isHover ? widget.hoverScale : 1,
        duration: widget.duration,
        curve: Curves.easeOut,
        alignment: widget.alignment,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOut,
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            color: appliedGradient == null ? bgColor : null,
            gradient: appliedGradient,
            border: Border.all(color: borderClr),
            boxShadow: _isHover
                ? (widget.hoverShadow ?? defaultHoverShadow)
                : (widget.normalShadow ?? defaultNormalShadow),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _isHover ? widget.hoverBlur : widget.normalBlur,
                sigmaY: _isHover ? widget.hoverBlur : widget.normalBlur,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: radius,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}