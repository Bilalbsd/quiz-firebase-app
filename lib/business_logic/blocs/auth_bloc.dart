import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tp3_flutter_bilalb/data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import '../events/auth_events.dart';

// Definition des differents etats possibles de l'authentification
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Bloc pour la gestion des evenements d'authentification
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  AuthBloc(this._userRepository) : super(AuthInitial()) {
    // Association des evenements avec leurs gestionnaires
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  // Gestion de l'evenement d'inscription
  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _userRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        avatarFile: event.avatarFile,
      );

      // Enregistrement de l'evenement d'inscription
      await _analytics.logSignUp(signUpMethod: 'email');

      // Configuration des proprietes utilisateur pour Firebase Analytics
      await _analytics.setUserProperty(
          name: 'display_name', value: user.displayName);

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Gestion de l'evenement de connexion
  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _userRepository.signIn(event.email, event.password);

      // Enregistrement de l'evenement de connexion
      await _analytics.logLogin(loginMethod: 'email');

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Gestion de l'evenement de deconnexion
  Future<void> _onSignOut(SignOutEvent event, Emitter<AuthState> emit) async {
    try {
      await _userRepository.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Gestion de l'evenement de mise a jour du profil utilisateur
  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<AuthState> emit) async {
    if (state is! AuthAuthenticated) return;

    final currentUser = (state as AuthAuthenticated).user;
    emit(AuthLoading());

    try {
      // Mise a jour des informations utilisateur
      final updatedAvatarUrl = event.avatarFile != null
          ? await _userRepository.uploadAvatar(
              currentUser.id, event.avatarFile!)
          : currentUser.avatarUrl;

      final updatedUser = currentUser.copyWith(
        displayName: event.displayName,
        avatarUrl: updatedAvatarUrl,
      );

      await _userRepository.updateUserProfile(updatedUser);
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
