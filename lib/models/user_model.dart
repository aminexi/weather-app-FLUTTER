import 'package:hive/hive.dart';

part 'user_model.g.dart'; // 🟢 Obligatoire pour générer le Hive adapter

@HiveType(typeId: 0) // 🟢 Gestion des données Hive, ID unique par modèle
class User extends HiveObject {
  // 🟢 Recommandé pour Hive (méthodes save(), delete())

  @HiveField(0) // 🟢 Champ 0 dans Hive
  final String email;

  @HiveField(1) // 🟢 Champ 1 dans Hive
  final String password;

  @HiveField(2) // 🟢 Champ 2 dans Hive
  final DateTime createdAt;

  @HiveField(3) // 🟢 Champ 3 (optionnel)
  final String? displayName;

  @HiveField(4) // 🟢 Champ 4 (optionnel)
  final String? profileImageUrl;

  // 🟢 Constructeur — paramètres nommés
  User({
    required this.email,
    required this.password,
    required this.createdAt,
    this.displayName,
    this.profileImageUrl,
  });

  // 🟢 Permet de créer un nouvel objet avec certains champs modifiés
  User copyWith({
    String? email,
    String? password,
    DateTime? createdAt,
    String? displayName,
    String? profileImageUrl,
  }) {
    return User(
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  // 🟢 Vérifie la validité d’un email (authentification)
  bool isValidEmail() {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  // 🟢 Vérifie que le mot de passe a au moins 6 caractères
  bool isValidPassword() => password.length >= 6;

  // 🟢 Convertir en Map (optionnel pour persistance ou API)
  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password, // ⚠️ En production : hasher
        'createdAt': createdAt.toIso8601String(),
        'displayName': displayName,
        'profileImageUrl': profileImageUrl,
      };

  // 🟢 Créer un objet User depuis une Map
  factory User.fromMap(Map<String, dynamic> map) {
    try {
      return User(
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        createdAt: DateTime.parse(
          map['createdAt'] ?? DateTime.now().toIso8601String(),
        ),
        displayName: map['displayName'],
        profileImageUrl: map['profileImageUrl'],
      );
    } catch (e) {
      throw FormatException('Failed to parse user data: $e');
    }
  }

  // 🟢 Comparaison : deux Users sont égaux si leurs emails sont identiques
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && email == other.email;

  // 🟢 Hash basé sur l’email
  @override
  int get hashCode => email.hashCode;

  // 🟢 Debug friendly
  @override
  String toString() => 'User(email: $email, displayName: $displayName)';
}
