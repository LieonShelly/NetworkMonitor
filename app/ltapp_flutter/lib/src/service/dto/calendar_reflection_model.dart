class IconModel {
  final String? url;
  final String? status;

  IconModel({this.url, this.status});

  factory IconModel.fromJson(Map<String, dynamic> json) {
    return IconModel(
      url: json['url'] as String?,
      status: json['status'] as String?,
    );
  }
}

class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

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

class ReflectionModel {
  final String id;
  final String content;
  final String createdYmd;
  final QuestionModel question;
  final IconModel? icon;

  ReflectionModel({
    required this.id,
    required this.content,
    required this.createdYmd,
    required this.question,
    this.icon,
  });

  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] as String,
      content: json['content'] as String,
      createdYmd: json['created_ymd'] as String,
      question: QuestionModel.fromJson(json['question']),
      icon: json['icon'] != null ? IconModel.fromJson(json['icon']) : null,
    );
  }
}

class CalendardayModel {
  final String date;
  final List<ReflectionModel> reflections;

  CalendardayModel({required this.date, required this.reflections});

  factory CalendardayModel.fromJson(Map<String, dynamic> json) {
    return CalendardayModel(
      date: json['date'],
      reflections: (json['reflections'] as List)
          .map((e) => ReflectionModel.fromJson(e))
          .toList(),
    );
  }
}
