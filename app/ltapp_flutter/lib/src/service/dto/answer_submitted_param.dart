class AnswerSubmittedParam {
  final String questionId;
  final String content;
  final String createdAt;

  const AnswerSubmittedParam({
    required this.questionId,
    required this.content,
    required this.createdAt,
  });

  Map<String, String> mapToJson() {
    return {
      "questionId": questionId,
      "content": content,
      "createdAt": createdAt,
    };
  }
}
