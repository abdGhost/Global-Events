import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEventCard extends StatelessWidget {
  const ShimmerEventCard({super.key, this.aspectRatio = 16 / 9});

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: aspectRatio,
              child: Container(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 12),
                  Container(height: 32, width: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
