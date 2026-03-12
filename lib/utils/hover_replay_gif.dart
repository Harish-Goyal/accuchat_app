import 'package:flutter/material.dart';

class HoverReplayGif extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const HoverReplayGif({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<HoverReplayGif> createState() => _HoverReplayGifState();
}

class _HoverReplayGifState extends State<HoverReplayGif> {
  int _version = 0;

  void _restartGif() {
    if (!mounted) return;
    setState(() {
      _version++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      '${widget.url}${widget.url.contains('?') ? '&' : '?'}hover=$_version',
      key: ValueKey(_version),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: Icon(Icons.broken_image)),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );

    return MouseRegion(
      onEnter: (_) => _restartGif(),
      child: widget.borderRadius != null
          ? ClipRRect(
        borderRadius: widget.borderRadius!,
        child: image,
      )
          : image,
    );
  }
}