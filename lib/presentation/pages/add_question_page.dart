import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp3_flutter_bilalb/data/models/question.dart';
import 'package:tp3_flutter_bilalb/data/repositories/quiz_repository.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _questionController = TextEditingController();
  bool?
      _isCorrect; // Remplacement du TextEditingController par une variable booléenne
  String? _selectedTheme;
  List<String> _themes = [];
  final _newThemeController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  Future<void> _loadThemes() async {
    final quizRepository = context.read<QuizRepository>();
    _themes = await quizRepository.getAvailableThemes();
    setState(() {});
  }

  Future<void> _addQuestion() async {
    final quizRepository = context.read<QuizRepository>();
    await quizRepository.addQuizQuestion(Question(
      questionText: _questionController.text,
      isCorrect: _isCorrect ?? false, // Utilisation de _isCorrect
      theme: _selectedTheme ?? _newThemeController.text,
      imageUrl: _imageUrlController.text,
    ));
    await _loadThemes();

    // Clear the form after adding the question
    _questionController.clear();
    _newThemeController.clear();
    _imageUrlController.clear();
    _selectedTheme = null;
    _isCorrect = null; // Reset the correct answer selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une question')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Remplacement du TextField par des boutons radio
                    const Text(
                      'Est-ce correct ?',
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: _isCorrect,
                          onChanged: (value) {
                            setState(() {
                              _isCorrect = value;
                            });
                          },
                        ),
                        const Text('Vrai'),
                        Radio<bool>(
                          value: false,
                          groupValue: _isCorrect,
                          onChanged: (value) {
                            setState(() {
                              _isCorrect = value;
                            });
                          },
                        ),
                        const Text('Faux'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _selectedTheme,
                      hint: const Text('Sélectionnez un thème'),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTheme = newValue;
                        });
                      },
                      items:
                          _themes.map<DropdownMenuItem<String>>((String theme) {
                        return DropdownMenuItem<String>(
                          value: theme,
                          child: Text(theme),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newThemeController,
                      decoration: InputDecoration(
                        labelText: 'Nouveau thème (optionnel)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      enabled: _selectedTheme == null,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL de l\'image (optionnel)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _addQuestion,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 16),
                foregroundColor: Colors.white, // Définit la couleur du texte
              ),
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
