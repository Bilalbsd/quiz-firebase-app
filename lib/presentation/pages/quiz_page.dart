// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp3_flutter_bilalb/business_logic/blocs/auth_bloc.dart';
import 'package:tp3_flutter_bilalb/data/models/question.dart';
import 'package:tp3_flutter_bilalb/data/repositories/quiz_repository.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.title, required this.theme});
  final String title;
  final String theme;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;

  List<Question> _questions = [];
  List<bool> _answeredQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final quizRepository = context.read<QuizRepository>();
    _questions = await quizRepository.getQuizQuestions(widget.theme);
    _answeredQuestions = List.generate(_questions.length, (index) => false);
    setState(() {});
  }

  void _checkAnswer(bool userChoice) {
    if (!_answeredQuestions[_currentQuestionIndex]) {
      final isCorrect =
          _questions[_currentQuestionIndex].isCorrect == userChoice;
      setState(() {
        _answeredQuestions[_currentQuestionIndex] = true;
        if (isCorrect) _score++;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
          });
        } else {
          _showFinalScore();
        }
      });
    }
  }

  void _showFinalScore() async {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;

      try {
        final quizRepository = context.read<QuizRepository>();
        await quizRepository.updateUserQuizScore(userId, _score, widget.theme);

        await FirebaseAnalytics.instance.logEvent(
          name: 'quiz_completed',
          parameters: {
            'user_id': userId,
            'score': _score,
            'theme': widget.theme,
          },
        );

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Le Quiz est terminé !'),
            content: Text('Score final: $_score/${_questions.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erreur lors de la mise à jour du score : ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Vous devez être connecté pour enregistrer votre score.')),
      );
    }
  }

  void _goToPreviousQuestion() {
    setState(() {
      if (_currentQuestionIndex > 0) {
        _currentQuestionIndex--;
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnswered = _answeredQuestions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Flèche retour
          onPressed: () => Navigator.pop(context), // Retour à l'écran précédent
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              _questions[_currentQuestionIndex].imageUrl ??
                  'assets/images/no_image.jpg',
              height: 300,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _questions[_currentQuestionIndex].questionText,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _goToPreviousQuestion,
                  icon: const Icon(Icons.arrow_left),
                  color: Colors.blueAccent,
                  iconSize: 36,
                ),
                ElevatedButton(
                  onPressed: isAnswered ? null : () => _checkAnswer(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAnswered ? Colors.grey : Colors.blueAccent,
                  ),
                  child: const Text('VRAI'),
                ),
                ElevatedButton(
                  onPressed: isAnswered ? null : () => _checkAnswer(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAnswered ? Colors.grey : Colors.blueAccent,
                  ),
                  child: const Text('FAUX'),
                ),
                IconButton(
                  onPressed: _goToNextQuestion,
                  icon: const Icon(Icons.arrow_right),
                  color: Colors.blueAccent,
                  iconSize: 36,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
