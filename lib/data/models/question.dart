import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String questionText;
  final bool isCorrect;
  final String theme;
  final String? imageUrl;

  const Question({
    required this.questionText,
    required this.isCorrect,
    required this.theme,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [questionText, isCorrect, theme, imageUrl];

  factory Question.fromFirestore(Map<String, dynamic> data) {
    return Question(
      questionText: data['questionText'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
      theme: data['theme'] ?? 'default',
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'questionText': questionText,
      'isCorrect': isCorrect,
      'theme': theme,
      'imageUrl': imageUrl,
    };
  }
}
