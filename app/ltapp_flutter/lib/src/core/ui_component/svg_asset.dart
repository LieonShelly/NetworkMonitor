import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAsset extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;

  const SvgAsset(
    this.assetPath, {
    this.width,
    this.height,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$assetPath',
      width: width,
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
