import 'package:lt_annotation/ltdeserialization.dart';
part 'calendar_reflection_model.g.dart';

enum IconStatus {
  generated,
  pending,
  failed,
  unknown;

  static IconStatus fromString(String? status) {
    if (status == null) return IconStatus.unknown;
    switch (status) {
      case "GENERATED":
        return IconStatus.generated;
      case "PENDING":
        return IconStatus.pending;
      case "FAILED":
        return IconStatus.failed;
      default:
        return IconStatus.unknown;
    }
  }
}

@ltDeserialization
class IconModel {
  final String? url;
  final IconStatus status;

  IconModel({this.url, this.status = IconStatus.unknown});

  factory IconModel.fromJson(Map<String, dynamic> json) {
    return IconModel(
      url: json['url'] as String?,
      status: IconStatus.fromString(json['status'] as String?),
    );
  }
}

@ltDeserialization
class CategoryModel {
  final String? id;

  final String name;

  CategoryModel({this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

@ltDeserialization
class QuestionModel {
  final String id;
  final String title;
  final CategoryModel category;

  QuestionModel({
    required this.id,
    required this.title,
    required this.category,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: CategoryModel.fromJson(json['category']),
    );
  }
}

@ltDeserialization
class AnswerModel {
  final String id;
  final String content;
  @JsonKey('created_ymd')
  final String createdYmd;
  final QuestionModel question;
  final IconModel? icon;

  AnswerModel({
    required this.id,
    required this.content,
    required this.createdYmd,
    required this.question,
    this.icon,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      content: json['content'] as String,
      createdYmd: json['created_ymd'] as String,
      question: QuestionModel.fromJson(json['question']),
      icon: json['icon'] != null ? IconModel.fromJson(json['icon']) : null,
    );
  }
}

@ltDeserialization
class CalendardayDto {
  final String date;
  final List<AnswerModel> reflections;

  CalendardayDto({required this.date, required this.reflections});

  factory CalendardayDto.fromJson(Map<String, dynamic> json) {
    return CalendardayDto(
      date: json['date'],
      reflections: (json['reflections'] as List)
          .map((e) => AnswerModel.fromJson(e))
          .toList(),
    );
  }
}

sealed class CalendarDayItemStyle {
  const CalendarDayItemStyle();
}

final class CalendarDayOnlyDateStyle extends CalendarDayItemStyle {
  const CalendarDayOnlyDateStyle();
}

final class CalendarReflectionsStyle extends CalendarDayItemStyle {
  final String date;
  final List<AnswerModel> reflections;
  const CalendarReflectionsStyle(this.date, this.reflections);
}

final class CalendarDayDashlineStyle extends CalendarDayItemStyle {
  const CalendarDayDashlineStyle();
}

class CalendarDayItem {
  final String date;
  final CalendarDayItemStyle style;

  const CalendarDayItem({required this.date, required this.style});
}
