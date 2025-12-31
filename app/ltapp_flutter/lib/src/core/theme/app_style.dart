import 'package:flutter/widgets.dart';

enum AppFont {
  poppins,
  feltTipSeniorRegular,
  poppinsMediumItalic,
  vividlyRegular,
}

extension AppFontExtension on AppFont {
  String get value {
    switch (this) {
      case AppFont.poppins:
        return "Poppins";
      case AppFont.feltTipSeniorRegular:
        return "FeltTipSeniorRegular";
      case AppFont.poppinsMediumItalic:
        return "PoppinsMediumItalic";
      case AppFont.vividlyRegular:
        return "VividlyRegular";
    }
  }
}

class AppTextStyle extends TextStyle {
  AppTextStyle({
    required AppFont font,
    super.fontSize,
    super.fontWeight,
    super.color,
    super.height,
    super.letterSpacing,
    super.decoration,
  }) : super(fontFamily: font.value);

  AppTextStyle.poppins({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.poppins,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.feltTipSeniorRegular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.feltTipSeniorRegular,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.poppinsMediumItalic({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.poppinsMediumItalic,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );

  AppTextStyle.vividlyRegular({
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    double? height,
  }) : this(
         font: AppFont.vividlyRegular,
         fontSize: fontSize,
         color: color,
         fontWeight: fontWeight,
         height: height,
       );
}
