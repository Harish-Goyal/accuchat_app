import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Colors you mentioned (use anywhere in your UI as needed)
const kBrandOrange = Color(0xFFffaf2c);
const kBrandGreen  = Color(0xFF08c189);

class ChatHomeShimmer extends StatelessWidget {
  const ChatHomeShimmer({
    super.key,
    this.itemCount = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final int itemCount;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final base = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    return IgnorePointer( // make the skeleton non-interactive
      child: SafeArea(
        bottom: false, // don't interfere with your bottom nav bar
        child: Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          period: const Duration(milliseconds: 1200),
          child: Column(
            children: [
              // Header (avatar + titles + actions)
              Padding(
                padding: padding.copyWith(bottom: 8),
                child: Row(
                  children: [
                    _circle(48), // profile
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bar(width: 140, height: 16, radius: 6), // "Chats"
                          const SizedBox(height: 8),
                          _bar(width: 100, height: 12, radius: 6), // "MUSKAN DE"
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _circle(28), // search
                    const SizedBox(width: 12),
                    _circle(28), // search
                    const SizedBox(width: 12),
                    _circle(28), // menu
                  ],
                ),
              ),

              // Chat list skeleton
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: padding.copyWith(top: 0),
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, __) => _chatTileSkeleton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _chatTileSkeleton() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _circle(44), // user avatar
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bar(width: 120, height: 14, radius: 6), // name
                const SizedBox(height: 8),
                _bar(width: double.infinity, height: 12, radius: 6), // last msg
              ],
            ),
          ),
          const SizedBox(width: 12),
          _bar(width: 40, height: 12, radius: 6), // time
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _bar({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
