import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tp3_flutter_bilalb/business_logic/blocs/auth_bloc.dart';
import 'package:tp3_flutter_bilalb/business_logic/events/auth_events.dart';
import 'add_question_page.dart'; // Importer la page d'ajout de question
// Importer la page de sélection de thème
import 'settings_page.dart'; // Importer la page des paramètres

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
      if (authState is AuthAuthenticated) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings), // Icône pour les paramètres
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                  Navigator.of(context).pushReplacementNamed('/auth');
                },
              ),
            ],
          ),
          body: Container(
            color: Colors.blue[50],
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildProfileCard(context, authState),
                  Positioned(
                    top: 60,
                    child: _buildAvatar(authState),
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (authState is AuthLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      } else if (authState is AuthError) {
        return Scaffold(
          body: Center(
            child: Text('Erreur : ${authState.message}'),
          ),
        );
      }
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter.')),
      );
    });
  }

  Widget _buildProfileCard(BuildContext context, AuthAuthenticated state) {
    return Container(
      margin: const EdgeInsets.only(top: 150),
      padding: const EdgeInsets.all(20),
      width: 350,
      decoration: BoxDecoration(
        color: Colors.blue[900],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Text(
            state.user.displayName ?? 'Utilisateur',
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.user.email,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigue vers la page de sélection de thème
                Navigator.pushNamed(context, '/theme-selection');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Commencer le Quiz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigue vers la page d'ajout de question
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddQuestionPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ajouter un Quiz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AuthAuthenticated state) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue[50]!, width: 5),
      ),
      child: CircleAvatar(
        backgroundImage: state.user.avatarUrl != null
            ? NetworkImage(state.user.avatarUrl!)
            : const AssetImage('assets/images/profile.jpg') as ImageProvider,
      ),
    );
  }
}
