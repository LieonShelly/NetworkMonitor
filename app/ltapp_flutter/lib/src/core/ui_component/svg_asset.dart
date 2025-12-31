import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum IconName {
  downArrowFill,
  calendar,
  deselectedCalendar,
  threads,
  deselectedThread,
  insights,
  deselectedInsights,
  user,
  deselectedUser,
}

extension IconNameExtension on IconName {
  String get fileName {
    switch (this) {
      case IconName.downArrowFill:
        return "down_arrow_fill.svg";
      case IconName.calendar:
        return "Calendar.svg";
      case IconName.threads:
        return "Threads.svg";
      case IconName.deselectedThread:
        return "deselectedThread.svg";
      case IconName.deselectedCalendar:
        return "deselectedCalendar.svg";
      case IconName.insights:
        return "insights.svg";
      case IconName.deselectedInsights:
        return "deselected_insights.svg";
      case IconName.user:
        return "user.svg";
      case IconName.deselectedUser:
        return "deselected_user.svg";
    }
  }
}

class SvgAsset extends StatelessWidget {
  final IconName iconName;
  final double? width;
  final double? height;
  final Color? color;

  const SvgAsset(
    this.iconName, {
    this.width,
    this.height,
    this.color,
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
    );
  }
}
