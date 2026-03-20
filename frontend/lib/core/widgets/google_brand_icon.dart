import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Official-style multicolor Google "G" for sign-in buttons (brand colors).
class GoogleBrandIcon extends StatelessWidget {
  const GoogleBrandIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/google_g.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
