import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Inscription d'un nouvel utilisateur
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
    File? avatarFile,
  }) async {
    try {
      // Création de l'utilisateur via Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Téléchargement de l'avatar si fourni
      String? avatarUrl;
      if (avatarFile != null) {
        avatarUrl = await uploadAvatar(userCredential.user!.uid, avatarFile);
      }

      // Création de l'objet utilisateur
      final newUser = AppUser(
        id: userCredential.user!.uid,
        email: email,
        displayName: displayName ?? email.split('@').first,
        avatarUrl: avatarUrl,
      );

      // Sauvegarde dans Firestore
      await _firestore
          .collection('users')
          .doc(newUser.id)
          .set(newUser.toFirestore());

      return newUser;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  // Connexion d'un utilisateur existant
  Future<AppUser> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Récupération des données utilisateur depuis Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Assurez-vous de convertir les scores en List<int>
      Map<String, List<int>> themeScores = {};
      final rawThemeScores =
          (userDoc.data() as Map<String, dynamic>)['themeScores'] ?? {};

      if (rawThemeScores is Map) {
        rawThemeScores.forEach((key, value) {
          if (value is List) {
            themeScores[key] = List<int>.from(value.map((e) => e is int
                ? e
                : 0)); // Remplacez 0 par une valeur par défaut si nécessaire
          }
        });
      }

      return AppUser.fromFirestore(
        userDoc.data() as Map<String, dynamic>,
        userCredential.user!.uid,
        themeScores: themeScores,
      );
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  // Téléchargement de l'avatar utilisateur vers Firebase Storage
  Future<String?> uploadAvatar(String userId, File avatarFile) async {
    try {
      Reference reference = _storage.ref().child('avatars/$userId.jpg');
      await reference.putFile(avatarFile);
      return await reference.getDownloadURL();
    } catch (e) {
      throw Exception('Avatar upload failed: ${e.toString()}');
    }
  }

  // Mise à jour des informations utilisateur dans Firestore
  Future<void> updateUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Déconnexion de l'utilisateur
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Flux d'écoute pour l'état d'authentification
  Stream<AppUser?> get user {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      return AppUser.fromFirestore(
        userDoc.data() as Map<String, dynamic>,
        firebaseUser.uid,
      );
    });
  }
}
