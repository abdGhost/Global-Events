import 'package:flutter/material.dart';

/// Breakpoints and scaling for mobile-first responsive layout.
/// Reference width 400 (typical phone); scales down on small devices, up on tablets.
class Responsive {
  Responsive._();

  /// Compact: phone portrait (< 600)
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  /// Medium: large phone / small tablet (600–840)
  static bool isMedium(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 840;
  }

  /// Expanded: tablet / desktop (>= 840)
  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 840;

  static double _width(BuildContext context) => MediaQuery.sizeOf(context).width;

  /// Scale factor from reference width 400. Clamped so text/icons stay readable.
  static double scale(BuildContext context) {
    final w = _width(context);
    // Phones: don't scale up (keeps UI from feeling oversized).
    if (w < 600) {
      final s = w / 400;
      return s.clamp(0.86, 1.0);
    }
    // Tablets+: allow a little scale up.
    final s = w / 700;
    return s.clamp(1.0, 1.25);
  }

  /// Scaled value for spacing, padding, sizes (icons, radii).
  static double value(BuildContext context, double base) =>
      (base * scale(context)).roundToDouble();

  /// Horizontal screen padding: smaller on compact, larger on expanded.
  static double horizontalPadding(BuildContext context) {
    final w = _width(context);
    if (w < 360) return 14;
    if (w < 600) return 16;
    if (w < 840) return 20;
    return 24;
  }

  /// Scaled font size (use for one-off text; theme can use textScaler instead).
  static double fontSize(BuildContext context, double base) =>
      (base * scale(context)).roundToDouble();

  /// Scaled icon size.
  static double iconSize(BuildContext context, double base) =>
      (base * scale(context)).roundToDouble();

  /// Scaled spacing (SizedBox height/width).
  static double spacing(BuildContext context, double base) =>
      (base * scale(context)).roundToDouble();

  /// Carousel large card height (trending).
  static double trendingCarouselHeight(BuildContext context) {
    final w = _width(context);
    if (w < 360) return 200;
    if (w < 600) return 232;
    return 260;
  }

  /// Horizontal list item width for "Near you" small cards.
  static double smallCardWidth(BuildContext context) {
    final w = _width(context);
    if (w < 360) return 160;
    if (w < 600) return 188;
    return 220;
  }

  /// Horizontal list height for "Near you" row.
  static double nearYouListHeight(BuildContext context) {
    final w = _width(context);
    if (w < 360) return 190;
    if (w < 600) return 212;
    return 240;
  }

  /// Shimmer placeholder width for trending (loading).
  static double shimmerTrendingWidth(BuildContext context) {
    final w = _width(context);
    if (w < 360) return 260;
    return 280;
  }

  /// Search bar height in app bar.
  static double searchBarHeight(BuildContext context) {
    if (isCompact(context)) return 44;
    return 46;
  }

  /// App bar avatar radius.
  static double appBarAvatarRadius(BuildContext context) =>
      value(context, 22);

  /// SliverAppBar expanded height (event detail).
  static double detailAppBarExpandedHeight(BuildContext context) {
    final w = _width(context);
    if (w < 360) return 240;
    if (w < 600) return 280;
    return 320;
  }

  /// Button min height (e.g. CTA buttons).
  static double buttonMinHeight(BuildContext context) =>
      value(context, 52);

  /// Text scale for body/UI that respects both device size and accessibility.
  static TextScaler textScaler(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = _width(context);
    if (w <= 0) return mq.textScaler;
    // Only scale text down slightly on very small phones; never scale up on phones.
    // Accessibility scaling is still respected via mq.textScaler.
    final compactFactor = (w / 400).clamp(0.92, 1.0);
    if (w < 600) {
      return TextScaler.linear(mq.textScaler.scale(1.0) * compactFactor);
    }
    return mq.textScaler;
  }
}
