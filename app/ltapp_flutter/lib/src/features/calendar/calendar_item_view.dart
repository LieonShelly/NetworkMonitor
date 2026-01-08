import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return buildMoreThanThreeIconView();
  }

  Widget buildDateView() {
    final day = date.day;
    return Text(
      '$day',
      style: AppTextStyle.feltTipSeniorRegular(
        fontSize: 14,
        color: Color(0xff323232),
      ),
    );
  }

  Widget buildOneIconView() {
    final icon = item?.reflections.last.icon;
    return Stack(
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        iconView(icon, 24, 24),
      ],
    );
  }

  Widget buildTwoIconView() {
    final icon1 = item?.reflections.first.icon;
    final icon2 = item?.reflections.last.icon;
    const double top = 18;
    const double bottom = 10;
    return Stack(
      children: [
        Positioned(top: 4, left: 4, child: buildDateView()),
        Padding(
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 1),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return iconView(icon1, size, size);
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 1),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return iconView(icon2, size, size);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildThreeIconView() {
    final icon1 = item?.reflections.first.icon;
    final icon2 = item?.reflections[1].icon;
    final icon3 = item?.reflections.last.icon;
    const double top = 18;
    const double bottom = 1;
    return Stack(
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        Padding(
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 1),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return iconView(icon1, size, size);
                      },
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 1),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return iconView(icon2, size, size);
                      },
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 1),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return iconView(icon3, size, size);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMoreThanThreeIconView() {
    final icon1 = item?.reflections.first.icon;
    final icon2 = item?.reflections[1].icon;
    final icon3 = item?.reflections.last.icon;
    final remaining = (item?.reflections.length ?? 0) - 3;
    const double top = 20;
    const double bottom = 0;
    const double hp = 0;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        Positioned(
          top: top,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return Container(
                          width: size,
                          height: size,
                          color: Colors.red,
                          child: iconView(icon3, size, size),
                        ); //;
                      },
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return Container(
                          width: size,
                          height: size,
                          color: Colors.blue,
                          child: iconView(icon3, size, size),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return Container(
                          width: size,
                          height: size,
                          color: Colors.red,
                          child: iconView(icon3, size, size),
                        ); //;
                      },
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size =
                            constraints.maxHeight < constraints.maxWidth
                            ? constraints.maxHeight
                            : constraints.maxWidth;
                        return Container(
                          width: size,
                          height: size,
                          color: Colors.blue,
                          child: iconView(icon3, size, size),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
            return SvgAsset(IconName.star, width: width, height: height);
          },
        );
      default:
        return SvgAsset(IconName.star, width: height, height: height);
    }
  }
}
