abstract class QuizEvent {}

// class LoadQuizQuestionsEvent extends QuizEvent {
//   final String theme;
//   LoadQuizQuestionsEvent(this.theme);
// }

class SubmitQuizAnswerEvent extends QuizEvent {
  final String questionId;
  final bool userAnswer;

  SubmitQuizAnswerEvent({
    required this.questionId,
    required this.userAnswer,
  });
}

class LoadAvailableThemesEvent extends QuizEvent {}

class CompleteQuizEvent extends QuizEvent {
  final String theme;
  final int score;

  CompleteQuizEvent({
    required this.theme,
    required this.score,
  });
}

class AddQuizQuestionEvent extends QuizEvent {
  final String questionText;
  final bool isCorrect;
  final String theme;
  final String? imageUrl;

  AddQuizQuestionEvent({
    required this.questionText,
    required this.isCorrect,
    required this.theme,
    this.imageUrl,
  });
}
