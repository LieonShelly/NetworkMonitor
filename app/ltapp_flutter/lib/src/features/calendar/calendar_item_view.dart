import 'package:flutter/widgets.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/core/theme/icon_name.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';
import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';

class CalendarItemView extends StatelessWidget {
  final CalendardayModel? item;
  final DateTime date;
  const CalendarItemView({super.key, required this.date, this.item});

  @override
  Widget build(BuildContext context) {
    return buildOneIconView();
  }

  Widget buildDateView() {
    final day = date.day;
    return Padding(
      padding: EdgeInsets.only(left: 3, top: 4),
      child: Text(
        '$day',
        style: AppTextStyle.feltTipSeniorRegular(
          fontSize: 14,
          color: Color(0xff323232),
        ),
      ),
    );
  }

  Widget buildOneIconView() {
    final icon = item?.reflections.last.icon;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: iconView(icon, 24, 24),
    );
  }

  Widget iconView(IconModel? icon, double width, double height) {
    switch (icon?.status) {
      case IconStatus.generated:
        return Image.network(
          icon?.url ?? "",
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return SvgAsset(IconName.star, width: 12, height: 12);
          },
        );
      default:
        return SvgAsset(IconName.star, width: 12, height: 12);
    }
  }
}
