import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltapp_flutter/src/core/theme/app_style.dart';
import 'package:ltapp_flutter/src/core/theme/icon_name.dart';
import 'package:ltapp_flutter/src/core/ui_component/svg_asset.dart';
import 'package:ltapp_flutter/src/features/calendar/diagonal_line.dart';
import 'package:ltapp_flutter/src/service/dto/calendar_reflection_model.dart';

class CalendarItemView extends ConsumerWidget with ImageCacheKeyType {
  final DateTime date;
  final CalendarDayItem? item;
  const CalendarItemView({super.key, required this.date, this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (DateUtils.isSameDay(date, DateTime.now())) {
      return _buildAddBtnView();
    }
    if (item == null) {
      return _buildNoneIconView();
    }
    return switch (item!.style) {
      CalendarDayOnlyDateStyle() => _buildNoneIconView(),
      CalendarReflectionsStyle(reflections: var list) => _buildReflectionView(
        list,
      ),
      CalendarDayDashlineStyle() => _buildDashLineView(),
    };
  }

  Widget _buildReflectionView(List<ReflectionModel> reflections) {
    final relfections = reflections;
    if (reflections.isEmpty && DateUtils.isSameDay(date, DateTime.now())) {
      return _buildAddBtnView();
    } else if (relfections.length == 1) {
      return buildOneIconView(reflections);
    } else if (relfections.length == 2) {
      return buildTwoIconView(reflections);
    } else if (relfections.length == 3) {
      return buildThreeIconView(reflections);
    } else if (relfections.length >= 3) {
      return buildMoreThanThreeIconView(reflections);
    } else {
      return _buildNoneIconView();
    }
  }

  Widget _buildNoneIconView() {
    return Stack(
      children: [Positioned(left: 4, top: 4, child: buildDateView())],
    );
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

  Widget buildOneIconView(List<ReflectionModel> reflections) {
    final icon = reflections.last.icon;
    const double top = 18;
    const double bottom = 10;
    return Stack(
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        Padding(
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: iconView(icon, 24, 24),
          ),
        ),
      ],
    );
  }

  Widget buildTwoIconView(List<ReflectionModel> reflections) {
    final icon1 = reflections.first.icon;
    final icon2 = reflections.last.icon;
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

  Widget buildThreeIconView(List<ReflectionModel> reflections) {
    final icon1 = reflections.first.icon;
    final icon2 = reflections[1].icon;
    final icon3 = reflections.last.icon;
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

  Widget buildMoreThanThreeIconView(List<ReflectionModel> reflections) {
    final icon1 = reflections.first.icon;
    final icon2 = reflections[1].icon;
    final icon3 = reflections.last.icon;
    final remaining = (reflections.length) - 3;
    const double top = 20;
    const double bottom = 0;
    const double hp = 2;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        Padding(
          padding: const EdgeInsets.only(
            top: top,
            left: hp,
            right: hp,
            bottom: bottom,
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildGridItem(
                        icon1,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    Expanded(
                      child: _buildGridItem(
                        icon2,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildGridItem(
                        icon3,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Expanded(
                      child: _buildCountItem(
                        remaining,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget iconView(IconModel? icon, double width, double height) {
    final placehoder = SvgAsset(IconName.star, width: width, height: height);
    if (icon == null) {
      return placehoder;
    }

    switch (icon.status) {
      case IconStatus.generated:
        return CachedNetworkImage(
          imageUrl: icon.url ?? "",
          width: width,
          height: height,
          fit: BoxFit.contain,
          memCacheWidth: (150 * 3).toInt(),
          placeholder: (context, url) => placehoder,
          errorWidget: (context, url, error) => placehoder,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          key: ValueKey(cacheKey(icon.url ?? "")),
          cacheKey: cacheKey(icon.url ?? ""),
        );
      default:
        return placehoder;
    }
  }

  Widget _buildGridItem(
    IconModel? icon, {
    Alignment alignment = Alignment.bottomCenter,
  }) {
    // if (icon == null) return const SizedBox();
    return Container(
      alignment: alignment,
      // color: Colors.red,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxHeight < constraints.maxWidth
              ? constraints.maxHeight
              : constraints.maxWidth;
          return SizedBox(
            width: size,
            height: size,
            child: iconView(icon, size, size),
          );
        },
      ),
    );
  }

  Widget _buildCountItem(
    int count, {
    Alignment alignment = Alignment.topCenter,
  }) {
    return Container(
      alignment: alignment,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double maxsize = constraints.maxHeight < constraints.maxWidth
              ? constraints.maxHeight
              : constraints.maxWidth;
          final cornorText = Text(
            '$count+',
            style: AppTextStyle.poppinsMediumItalic(
              fontSize: 8,
              color: const Color(0xff000000),
              height: 1,
            ),
          );
          return SizedBox(
            width: maxsize,
            height: maxsize,
            child: Center(child: cornorText),
          );
        },
      ),
    );
  }

  Widget _buildDashLineView() {
    const double top = 18;
    const double bottom = 12;
    return Stack(
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        Padding(
          padding: const EdgeInsets.only(top: top, bottom: bottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(width: 12, height: 12, child: DiagonalLine()),
          ),
        ),
      ],
    );
  }

  Widget _buildAddBtnView() {
    final cross = SvgAsset(IconName.smallCross, width: 10, height: 10);
    final gradient = Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF040404), Color(0xFF656565)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final gradientContainer = Stack(
      alignment: Alignment.center,
      children: [
        gradient,
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 1.0),
            child: Container(color: Colors.transparent),
          ),
        ),
        cross,
      ],
    );

    final btn = GestureDetector(
      onTap: () {},
      child: SizedBox(width: 30, height: 30, child: gradientContainer),
    );
    const double top = 18;
    const double bottom = 5;
    return Stack(
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        Padding(
          padding: const EdgeInsets.only(top: top, bottom: bottom),
          child: Align(alignment: Alignment.bottomCenter, child: btn),
        ),
      ],
    );
  }
}

mixin ImageCacheKeyType {
  String cacheKey(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.last;
    } catch (e) {
      return url;
    }
  }
}
