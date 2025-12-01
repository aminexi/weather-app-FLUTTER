import 'package:hive/hive.dart';
import 'package:weather_app/models/user_model.dart';
import 'package:weather_app/models/weather_model.dart';

/// 🟢 Exception personnalisée pour gérer les erreurs de stockage local
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => message;
}

/// 🟢 Service de stockage local avec Hive
/// Permet de gérer :
/// - Authentification utilisateur (User)
/// - Favoris météo (Weather)
class LocalStorageService {
  // 🟢 Nom de la box Hive pour l’authentification
  static const String _authBox = 'auth';

  // 🟢 Nom de la box Hive pour les favoris météo
  static const String _favoritesBox = 'favorites';

  // 🟢 Clé pour stocker l’utilisateur
  static const String _userKey = 'user';

  // 🟢 Indique si le service a déjà été initialisé
  bool _isInitialized = false;

  /// 🟢 Initialise Hive et ouvre les boxes nécessaires
  Future<void> initialize() async {
    if (_isInitialized) return; // 🟢 Évite d'ouvrir plusieurs fois les boxes
    try {
      if (!Hive.isBoxOpen(_authBox)) {
        await Hive.openBox(_authBox); // 🟢 Box pour l’utilisateur
      }
      if (!Hive.isBoxOpen(_favoritesBox)) {
        await Hive.openBox(_favoritesBox); // 🟢 Box pour les favoris météo
      }
      _isInitialized = true; // 🟢 Marque le service comme initialisé
    } catch (e) {
      throw StorageException('Failed to initialize storage: $e');
    }
  }

  // ----------------------------
  // 🟢 Méthodes pour l’authentification
  // ----------------------------

  /// 🟢 Sauvegarde un utilisateur dans Hive
  /// ⚠️ Vérifie la validité de l’email et du mot de passe
  Future<void> saveUser(User user) async {
    try {
      if (!user.isValidEmail()) {
        throw StorageException('Invalid email format'); // 🟢 Email invalide
      }
      if (!user.isValidPassword()) {
        throw StorageException(
            'Password must be at least 6 characters'); // 🟢 Mot de passe trop court
      }

      final box = Hive.box(_authBox); // 🟢 Récupère la box Hive
      await box.put(
          _userKey, user.toMap()); // 🟢 Sauvegarde l’utilisateur en Map
    } catch (e) {
      throw StorageException('Failed to save user: $e');
    }
  }

  /// 🟢 Récupère l’utilisateur depuis Hive
  User? getUser() {
    try {
      final box = Hive.box(_authBox);
      final userData =
          box.get(_userKey); // 🟢 Récupère les données de l’utilisateur
      if (userData != null) {
        return User.fromMap(
            Map<String, dynamic>.from(userData)); // 🟢 Convertit Map → User
      }
      return null; // 🟢 Aucun utilisateur enregistré
    } catch (e) {
      throw StorageException('Failed to retrieve user: $e');
    }
  }

  /// 🟢 Supprime l’utilisateur de Hive (déconnexion)
  Future<void> clearUser() async {
    try {
      final box = Hive.box(_authBox);
      await box.delete(_userKey); // 🟢 Supprime la clé User
    } catch (e) {
      throw StorageException('Failed to clear user: $e');
    }
  }

  // ----------------------------
  // 🟢 Méthodes pour les favoris météo
  // ----------------------------

  /// 🟢 Ajoute une ville aux favoris
  Future<void> addFavorite(Weather weather) async {
    try {
      final box = Hive.box(_favoritesBox);
      await box.put(weather.city.toLowerCase(),
          weather.toMap()); // 🟢 Sauvegarde avec la clé en minuscule
    } catch (e) {
      throw StorageException('Failed to add favorite: $e');
    }
  }

  /// 🟢 Supprime une ville des favoris
  Future<void> removeFavorite(String city) async {
    try {
      final box = Hive.box(_favoritesBox);
      await box.delete(city.toLowerCase());
    } catch (e) {
      throw StorageException('Failed to remove favorite: $e');
    }
  }

  /// 🟢 Récupère toutes les villes favorites
  List<Weather> getFavorites() {
    try {
      final box = Hive.box(_favoritesBox);
      return box.values
          .map((e) => Weather.fromMap(Map<String, dynamic>.from(
              e))) // 🟢 Convertit chaque Map en Weather
          .toList();
    } catch (e) {
      throw StorageException('Failed to retrieve favorites: $e');
    }
  }

  /// 🟢 Vérifie si une ville est déjà en favoris
  bool isFavorite(String city) {
    try {
      final box = Hive.box(_favoritesBox);
      return box.containsKey(city.toLowerCase());
    } catch (e) {
      throw StorageException('Failed to check favorite: $e');
    }
  }

  /// 🟢 Retourne le nombre de favoris enregistrés
  int getFavoriteCount() {
    try {
      final box = Hive.box(_favoritesBox);
      return box.length;
    } catch (e) {
      throw StorageException('Failed to get favorite count: $e');
    }
  }

  /// 🟢 Supprime toutes les données (User + favoris)
  Future<void> clearAll() async {
    try {
      final authBox = Hive.box(_authBox);
      final favBox = Hive.box(_favoritesBox);
      await authBox.clear();
      await favBox.clear();
    } catch (e) {
      throw StorageException('Failed to clear all data: $e');
    }
  }
}
