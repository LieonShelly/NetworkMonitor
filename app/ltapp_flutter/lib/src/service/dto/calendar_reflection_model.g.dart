// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_reflection_model.dart';

// **************************************************************************
// LtDeserializationGenerator
// **************************************************************************

IconModel _$IconModelFromJson(Map<String, dynamic> json) {
  return IconModel(
    url: json['url'] as String?,
    status: IconStatus.fromString(json['status'] as String?),
  );
}

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) {
  return CategoryModel(id: json['id'] as String?, name: json['name'] as String);
}

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) {
  return QuestionModel(
    id: json['id'] as String,
    title: json['title'] as String,
    category: CategoryModel.fromJson(json['category']),
    pinned: json['pinned'] as bool?,
    subCategory: json['sub_category'] == null
        ? null
        : CategoryModel.fromJson(json['sub_category']),
    answers: (json['answers'] as List)
        .map((e) => AnswerModel.fromJson(e))
        .toList(),
  );
}

AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) {
  return AnswerModel(
    id: json['id'] as String,
    content: json['content'] as String,
    createdYmd: json['created_ymd'] as String,
    question: json['question'] == null
        ? null
        : QuestionModel.fromJson(json['question']),
    icon: json['icon'] == null ? null : IconModel.fromJson(json['icon']),
  );
}

CalendardayDto _$CalendardayDtoFromJson(Map<String, dynamic> json) {
  return CalendardayDto(
    date: json['date'] as String,
    reflections: (json['reflections'] as List)
        .map((e) => AnswerModel.fromJson(e))
        .toList(),
  );
}
