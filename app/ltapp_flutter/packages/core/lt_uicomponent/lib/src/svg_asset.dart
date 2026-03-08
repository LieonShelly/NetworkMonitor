import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class SvgAsset extends StatelessWidget {
  final IconName iconName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  const SvgAsset(
    this.iconName, {
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = iconName.fileName;
    return SvgPicture.asset(
      'assets/icons/$fileName',
      width: width,
      height: height,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
      fit: fit,
    );
  }
}
