import 'package:flutter/material.dart'; // 🟢 UI / Architecture Flutter
import 'package:weather_app/models/user_model.dart'; // 🟢 Gestion des données Hive / User
import 'package:weather_app/services/local_storage_service.dart'; // 🟢 Persistance locale (Hive / SharedPreferences)

/// 🟢 AuthProvider — Gestion de l'état utilisateur + Authentification
/// Fournit login, signup, logout et état utilisateur global
/// 🚀 Optimisé avec meilleure validation et gestion des états
enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  // 🟢 Service de persistance locale (Hive) pour stocker l'utilisateur
  final LocalStorageService _storageService = LocalStorageService();

  // 🟢 Données utilisateur actuelle
  User? _user;

  // 🟢 État courant de l'authentification
  AuthState _state = AuthState.initial;

  // 🟢 Message d'erreur
  String? _error;

  // 🟢 Indicateur de chargement pour l'UI (ex: Spinner)
  bool _isLoading = false;

  // 🟢 Getters pour accès depuis l'UI / Consumer
  User? get user => _user; // 🟢 UI / logique
  AuthState get state => _state; // 🟢 UI / logique
  bool get isLoggedIn => _user != null; // 🟢 UI / navigation conditionnelle
  bool get isLoading => _isLoading; // 🟢 UI / chargement
  String? get error => _error; // 🟢 UI / affichage erreurs

  // 🟢 Constructeur — charge automatiquement l'utilisateur depuis stockage
  AuthProvider() {
    _loadUser();
  }

  /// 🟢 Chargement de l'utilisateur depuis Hive / SharedPreferences
  /// 🚀 Gestion d'erreur améliorée
  void _loadUser() {
    try {
      _user = _storageService.getUser(); // 🟢 Gestion données / Hive
      _state = _user != null
          ? AuthState.authenticated
          : AuthState.unauthenticated; // 🟢 Auth / état logique
      _error = null;
    } catch (e) {
      _state = AuthState
          .unauthenticated; // 🚀 Permet de continuer même si le chargement échoue
      _error = null; // 🚀 Pas d'erreur affichée au démarrage
      _user = null;
    }
    notifyListeners(); // 🟢 Provider / BLoC — notifie l'UI
  }

  /// 🚀 Validation d'email améliorée avec regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// 🟢 Login — Authentification d'un utilisateur
  /// 🚀 Validation améliorée et gestion d'erreur robuste
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _state = AuthState.loading; // 🟢 Auth / loading
    _error = null;
    notifyListeners(); // 🟢 UI réactive

    try {
      // 🟢 Validation côté client
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // 🚀 Validation d'email plus robuste
      if (!_isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // 🟢 Simulation d'appel API
      await Future.delayed(const Duration(milliseconds: 800));

      // 🟢 Création d'un utilisateur temporaire (pour stockage local)
      final user = User(
        email: email.trim().toLowerCase(), // 🚀 Normalise l'email
        password: password,
        createdAt: DateTime.now(),
      );

      await _storageService.saveUser(user); // 🟢 Persistance locale
      _user = user;
      _state = AuthState.authenticated; // 🟢 Auth réussie
      _isLoading = false;
      _error = null;
      notifyListeners(); // 🟢 UI réactive
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error; // 🟢 Gestion d'erreur
      _isLoading = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// 🟢 Signup — Création d'un nouvel utilisateur
  /// 🚀 Validation améliorée avec vérification de force du mot de passe
  Future<bool> signup(
      String email, String password, String confirmPassword) async {
    _isLoading = true;
    _state = AuthState.loading; // 🟢 Auth / loading
    _error = null;
    notifyListeners();

    try {
      // 🟢 Validation des champs
      if (email.trim().isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        throw Exception('All fields are required');
      }

      // 🚀 Validation d'email plus robuste
      if (!_isValidEmail(email.trim())) {
        throw Exception('Please enter a valid email address');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // 🚀 Vérification de force du mot de passe
      if (!password.contains(RegExp(r'[A-Za-z]')) ||
          !password.contains(RegExp(r'[0-9]'))) {
        throw Exception('Password must contain letters and numbers');
      }

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // 🟢 Simulation d'API call
      await Future.delayed(const Duration(milliseconds: 800));

      // 🟢 Création du nouvel utilisateur
      final user = User(
        email: email.trim().toLowerCase(), // 🚀 Normalise l'email
        password: password,
        createdAt: DateTime.now(),
      );

      await _storageService.saveUser(user); // 🟢 Persistance locale
      _user = user;
      _state = AuthState.authenticated; // 🟢 Auth réussie
      _isLoading = false;
      _error = null;
      notifyListeners(); // 🟢 UI réactive
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error; // 🟢 Gestion d'erreur
      _isLoading = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  /// 🟢 Logout — Déconnexion utilisateur
  Future<void> logout() async {
    try {
      _isLoading = true;
      _state = AuthState.loading; // 🟢 Auth / loading
      notifyListeners();

      await _storageService.clearUser(); // 🟢 Persistance locale
      _user = null;
      _error = null;
      _state = AuthState.unauthenticated; // 🟢 Auth / déconnecté
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to logout'; // 🟢 Gestion d'erreur
      _state = AuthState.error;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 🟢 Clear erreur affichée (UI/UX)
  void clearError() {
    _error = null;
    if (_state == AuthState.error) {
      _state =
          AuthState.unauthenticated; // 🚀 Retourne à l'état non authentifié
    }
    notifyListeners();
  }
}
