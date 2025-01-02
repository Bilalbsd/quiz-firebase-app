import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/question.dart';

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Question>> getQuizQuestions(String theme) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('quiz_questions')
          .where('theme', isEqualTo: theme)
          .get();

      return querySnapshot.docs.map((doc) {
        return Question(
          questionText: doc['questionText'] as String,
          isCorrect: doc['isCorrect'] as bool,
          theme: doc['theme'] as String,
          imageUrl: doc['imageUrl'] as String?,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load quiz questions: ${e.toString()}');
    }
  }

  Future<void> addQuizQuestion(Question question) async {
    try {
      await _firestore.collection('quiz_questions').add({
        'questionText': question.questionText,
        'isCorrect': question.isCorrect,
        'theme': question.theme,
        'imageUrl': question.imageUrl,
      });
    } catch (e) {
      throw Exception('Failed to add quiz question: ${e.toString()}');
    }
  }

  Future<List<String>> getAvailableThemes() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('quiz_questions').get();

      // Extract unique themes
      Set<String> themes =
          querySnapshot.docs.map((doc) => doc['theme'] as String).toSet();

      return themes.toList();
    } catch (e) {
      throw Exception('Failed to load themes: ${e.toString()}');
    }
  }

  Future<void> updateUserQuizScore(
      String userId, int score, String theme) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      // Convertissez explicitement les scores de thème
      Map<String, dynamic> themeScores = userData?['themeScores'] ?? {};

      // Convertissez les listes existantes en List<int>
      Map<String, List<int>> convertedThemeScores =
          themeScores.map((key, value) {
        return MapEntry(
            key, (value as List).map((e) => int.parse(e.toString())).toList());
      });

      if (convertedThemeScores.containsKey(theme)) {
        convertedThemeScores[theme]!.add(score);
      } else {
        convertedThemeScores[theme] = [score];
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'themeScores': convertedThemeScores});
    } catch (e) {
      throw Exception('Failed to update user quiz score: ${e.toString()}');
    }
  }

  Future<void> populateQuizQuestions() async {
    final questions = [
      {
        'questionText': "La Révolution française a commencé en 1789.",
        'isCorrect': true,
        'theme': 'Histoire',
        'imageUrl': null,
      },
      {
        'questionText': "Napoléon Bonaparte est devenu empereur en 1804.",
        'isCorrect': true,
        'theme': 'Histoire',
        'imageUrl': null,
      },
      {
        'questionText':
            "La bataille de Verdun a eu lieu pendant la Seconde Guerre mondiale.",
        'isCorrect': false,
        'theme': 'Histoire',
        'imageUrl': null,
      },
    ];

    for (var question in questions) {
      await _firestore.collection('quiz_questions').add(question);
    }
  }
}
