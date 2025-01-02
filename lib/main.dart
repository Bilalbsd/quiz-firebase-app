import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp3_flutter_bilalb/business_logic/blocs/quiz_bloc.dart';
import 'firebase_options.dart';

import 'presentation/pages/auth_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/quiz_page.dart';
import 'presentation/pages/add_question_page.dart';
import 'presentation/pages/theme_selection_page.dart';

import 'business_logic/blocs/auth_bloc.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/quiz_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository = UserRepository();
  final QuizRepository quizRepository = QuizRepository();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: userRepository),
        RepositoryProvider.value(value: quizRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(userRepository),
          ),
          BlocProvider(
            create: (context) => QuizBloc(quizRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Quiz App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/auth',
          routes: {
            '/auth': (context) => const AuthPage(),
            '/profile': (context) => const ProfilePage(),
            '/theme-selection': (context) => const ThemeSelectionPage(),
            '/quiz': (context) => const QuizPage(
                  title: 'Questions/Réponses',
                  theme: '',
                ),
            '/add-question': (context) => const AddQuestionPage(),
          },
        ),
      ),
    );
  }
}
