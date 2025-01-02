import 'dart:io';

// Base pour tous les événements d'authentification
abstract class AuthEvent {}

// Événement pour l'inscription
class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;
  final File? avatarFile;

  SignUpEvent({
    required this.email,
    required this.password,
    this.displayName,
    this.avatarFile,
  });
}

// Événement pour la connexion
class SignInEvent extends AuthEvent {
  final String email;
  final String password;

  SignInEvent({
    required this.email,
    required this.password,
  });
}

// Événement pour la déconnexion
class SignOutEvent extends AuthEvent {}

// Événement pour la mise à jour du profil utilisateur
class UpdateProfileEvent extends AuthEvent {
  final String? displayName;
  final File? avatarFile;

  UpdateProfileEvent({
    this.displayName,
    this.avatarFile,
  });
}
