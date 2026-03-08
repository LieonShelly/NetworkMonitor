import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'diagonal_line.dart';
import 'package:lt_reflection_service/reflection_service.dart';
import 'package:feature_core/feature_core.dart';

class CalendarItemView extends ConsumerWidget with ImageCacheKeyType {
  final DateTime date;
  final CalendarDayItem? item;
  const CalendarItemView({super.key, required this.date, this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item == null) {
      if (DateUtils.isSameDay(date, DateTime.now())) {
        return _buildAddBtnView();
      }
      return _buildNoneIconView();
    }
    return switch (item!.style) {
      CalendarDayOnlyDateStyle() => _buildNoneIconView(),
      CalendarReflectionsStyle(reflections: var list) => _buildReflectionView(
        context,
        list,
      ),
      CalendarDayDashlineStyle() => _buildDashLineView(),
    };
  }

  Widget _buildReflectionView(
    BuildContext context,
    List<AnswerModel> reflections,
  ) {
    final relfections = reflections;
    if (reflections.isEmpty && DateUtils.isSameDay(date, DateTime.now())) {
      return _buildAddBtnView();
    } else if (relfections.length == 1) {
      return buildOneIconView(context, reflections);
    } else if (relfections.length == 2) {
      return buildTwoIconView(context, reflections);
    } else if (relfections.length == 3) {
      return buildThreeIconView(context, reflections);
    } else if (relfections.length >= 3) {
      return buildMoreThanThreeIconView(context, reflections);
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

  Widget buildOneIconView(BuildContext context, List<AnswerModel> reflections) {
    const double top = 18;
    const double bottom = 10;
    return Stack(
      children: [
        Positioned(left: 4, top: 4, child: buildDateView()),
        Padding(
          padding: EdgeInsets.only(top: top, bottom: bottom),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: iconView(context, reflections.last, 24, 24),
          ),
        ),
      ],
    );
  }

  Widget buildTwoIconView(BuildContext context, List<AnswerModel> reflections) {
    final icon1 = reflections.first;
    final icon2 = reflections.last;
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
                        return iconView(context, icon1, size, size);
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
                        return iconView(context, icon2, size, size);
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

  Widget buildThreeIconView(
    BuildContext context,
    List<AnswerModel> reflections,
  ) {
    final icon1 = reflections.first;
    final icon2 = reflections[1];
    final icon3 = reflections.last;
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
                        return iconView(context, icon1, size, size);
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
                        return iconView(context, icon2, size, size);
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
                        return iconView(context, icon3, size, size);
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

  Widget buildMoreThanThreeIconView(
    BuildContext context,
    List<AnswerModel> reflections,
  ) {
    final icon1 = reflections.first;
    final icon2 = reflections[1];
    final icon3 = reflections.last;
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

  Widget iconView(
    BuildContext context,
    AnswerModel? answert,
    double width,
    double height,
  ) {
    final icon = answert?.icon;
    final placeholder = SvgAsset(IconName.star, width: width, height: height);
    if (icon == null) {
      return placeholder;
    }

    switch (icon.status) {
      case IconStatus.generated:
        return GestureDetector(
          onTap: () {
            context.push('/answer_detail', extra: answert);
          },
          child: Container(
            // color: Colors.red,
            padding: EdgeInsets.all(3),
            child: ProcessedIconView(
              imageUrl: icon.url ?? "",
              width: width,
              height: height,
              placeholder: placeholder,
              herTag: answert?.id ?? "",
            ),
          ),
        );
      default:
        return placeholder;
    }
  }

  Widget _buildGridItem(
    AnswerModel? icon, {
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
            child: iconView(context, icon, size, size),
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
