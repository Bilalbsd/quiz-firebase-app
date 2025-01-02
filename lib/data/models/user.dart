import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final Map<String, List<int>> themeScores;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.themeScores = const {},
  });

  @override
  List<Object?> get props => [id, email, displayName, avatarUrl, themeScores];

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    Map<String, List<int>>? themeScores,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeScores: themeScores ?? this.themeScores,
    );
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data, String documentId,
      {Map<String, List<int>>? themeScores}) {
    return AppUser(
      id: documentId,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      avatarUrl: data['avatarUrl'],
      themeScores: themeScores ??
          Map<String, List<int>>.from(data['themeScores'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'themeScores': themeScores,
    };
  }
}
