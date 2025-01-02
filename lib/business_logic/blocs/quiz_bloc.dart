import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tp3_flutter_bilalb/data/repositories/quiz_repository.dart';

// Quiz States
abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<LoadQuizQuestionsEvent> questions;
  QuizLoaded(this.questions);
}

class QuizError extends QuizState {
  final String message;
  QuizError(this.message);
}

// Quiz Events
abstract class QuizEvent {}

class LoadQuizQuestionsEvent extends QuizEvent {
  final String theme;
  LoadQuizQuestionsEvent(this.theme);
}

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository _repository;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  QuizBloc(this._repository) : super(QuizInitial()) {
    on<LoadQuizQuestionsEvent>((event, emit) async {
      emit(QuizLoading());
      try {
        final questions = await _repository.getQuizQuestions(event.theme);

        // Log analytics event
        _analytics.logEvent(
            name: 'quiz_theme_loaded',
            parameters: {'theme': event.theme});

        emit(QuizLoaded(questions.cast<LoadQuizQuestionsEvent>()));
      } catch (e) {
        emit(QuizError('Failed to load quiz questions'));
      }
    });
  }
}
