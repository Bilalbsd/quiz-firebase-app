import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp3_flutter_bilalb/data/repositories/quiz_repository.dart';
import 'quiz_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ThemeSelectionPage extends StatefulWidget {
  const ThemeSelectionPage({super.key});

  @override
  _ThemeSelectionPageState createState() => _ThemeSelectionPageState();
}

class _ThemeSelectionPageState extends State<ThemeSelectionPage> {
  List<String> _themes = [];

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

  void _navigateToQuiz(String theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizPage(title: 'Quiz sur le thème: $theme', theme: theme),
      ),
    );
  }

  void _startShootMode(String theme) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QuizPage(title: 'Quiz en mode SHOOT', theme: theme),
      ),
    );

    // Enregistrer la thématique préférée de l'utilisateur
    FirebaseAnalytics.instance
        .setUserProperty(name: 'preferred_theme', value: theme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un Thème'),
        backgroundColor: Colors.teal, // Personnalisation de l'AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Action sur l'icône d'information (ajouter un popup ou autre fonctionnalité si nécessaire)
            },
          ),
        ],
      ),
      body: _themes.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Indicateur de chargement si pas de thèmes
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _themes.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.star, // Icône personnalisée pour chaque thème
                        color: Colors.teal,
                      ),
                      title: Text(
                        _themes[index],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Appuyez pour commencer le quiz',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () => _navigateToQuiz(_themes[index]),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startShootMode(_themes.isNotEmpty
            ? _themes.first
            : ''), // Démarre le quiz avec le premier thème
        child: const Icon(Icons.play_arrow),
        backgroundColor:
            Colors.teal, // Bouton flottant avec une couleur plus visible
      ),
    );
  }
}
