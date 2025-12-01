import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/services/local_storage_service.dart';

/// 🟢 États possibles du WeatherProvider
enum WeatherState { initial, loading, loaded, error }

/// 🟢 WeatherProvider — Gestion de l'état météo + favoris
/// ⚡ Permet de rechercher la météo, gérer les favoris et notifier l'UI
/// 🚀 Optimisé avec fuzzy matching, debouncing et meilleure gestion des états + null safety
class WeatherProvider extends ChangeNotifier {
  // 🟢 Service REST pour récupérer la météo
  final WeatherService _weatherService = WeatherService();

  // 🟢 Service de stockage local pour gérer les favoris
  final LocalStorageService _storageService = LocalStorageService();

  // 🟢 Météo actuelle affichée
  Weather? _currentWeather;

  // 🟢 Liste des favoris
  List<Weather> _favorites = [];

  // 🟢 État courant du provider
  WeatherState _state = WeatherState.initial;

  // 🟢 Message d'erreur
  String? _error;

  // 🟢 Indicateur de chargement pour l'UI
  bool _isLoading = false;

  // 🚀 Dernière ville recherchée pour éviter les appels dupliqués
  String? _lastSearchedCity;

  // 🟢 Getters
  Weather? get currentWeather => _currentWeather;
  List<Weather> get favorites => List.unmodifiable(_favorites
      .where((w) => w != null)
      .toList()); // 🚀 Filtre les valeurs nulles
  WeatherState get state => _state;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// 🟢 Constructeur — charge les favoris au démarrage
  WeatherProvider() {
    _loadFavorites();
  }

  /// 🟢 Charge les favoris depuis le stockage local
  /// 🚀 Gestion d'erreur améliorée avec filtrage des valeurs nulles
  void _loadFavorites() {
    try {
      final loadedFavorites = _storageService.getFavorites();
      _favorites = loadedFavorites
          .where(
              (w) => w != null && w.city.isNotEmpty && w.description.isNotEmpty)
          .toList();
      notifyListeners(); // 🟢 Notifie l'UI
    } catch (e) {
      _error = 'Failed to load favorites';
      // 🚀 Ne bloque pas l'app si le chargement échoue
      _favorites = [];
    }
  }

  /// 🟢 Recherche la météo avec fuzzy matching en cas d'erreur
  /// 🚀 Si la ville exacte n'existe pas, suggère des villes similaires
  Future<void> searchWeather(String city) async {
    final trimmedCity = city.trim();

    if (trimmedCity.isEmpty) {
      _error = 'Please enter a city name';
      _state = WeatherState.error;
      notifyListeners();
      return;
    }

    if (trimmedCity.length < 2) {
      _error = 'City name must be at least 2 characters';
      _state = WeatherState.error;
      notifyListeners();
      return;
    }

    // 🟢 Accepte les lettres, espaces, tirets, points et caractères accentués
    final validCityPattern = RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.]+$');
    if (!validCityPattern.hasMatch(trimmedCity)) {
      _error = 'Please enter a valid city name (letters only)';
      _state = WeatherState.error;
      notifyListeners();
      return;
    }

    // 🚀 Évite de rechercher la même ville deux fois de suite
    if (_lastSearchedCity?.toLowerCase() == trimmedCity.toLowerCase() &&
        _currentWeather != null &&
        _state == WeatherState.loaded) {
      return;
    }

    _isLoading = true;
    _state = WeatherState.loading;
    _error = null;
    notifyListeners();

    try {
      final weather = await _weatherService.getWeatherByCity(trimmedCity);

      if (weather.city.isEmpty || weather.description.isEmpty) {
        throw WeatherException('Invalid weather data received');
      }

      _currentWeather = weather;
      _lastSearchedCity = trimmedCity;
      _state = WeatherState.loaded;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } on WeatherException catch (e) {
      // 🚀 Essaie de trouver une ville similaire en cas d'erreur
      final similarCities = _findSimilarCities(trimmedCity);

      if (similarCities.isNotEmpty) {
        try {
          // Essaie la première ville similaire
          final fallbackWeather =
              await _weatherService.getWeatherByCity(similarCities[0]);

          if (fallbackWeather.city.isNotEmpty &&
              fallbackWeather.description.isNotEmpty) {
            _currentWeather = fallbackWeather;
            _lastSearchedCity = similarCities[0];
            _state = WeatherState.loaded;
            _error =
                'City not found. Showing weather for "${similarCities[0]}" instead.';
            _isLoading = false;
            notifyListeners();
            return;
          }
        } catch (e) {
          // Ignore et affiche le message d'erreur original
        }
      }

      _error = 'City not found. Try: ${similarCities.take(3).join(", ")}';
      _state = WeatherState.error;
      _isLoading = false;
      _currentWeather = null;
      _lastSearchedCity = null;
      notifyListeners();
    } on FormatException catch (e) {
      _error = 'Unable to read weather data. Please try a different city.';
      _state = WeatherState.error;
      _isLoading = false;
      _currentWeather = null;
      _lastSearchedCity = null;
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred. Please try again.';
      _state = WeatherState.error;
      _isLoading = false;
      _currentWeather = null;
      _lastSearchedCity = null;
      notifyListeners();
    }
  }

  /// 🟢 Trouve des villes similaires en utilisant la distance de Levenshtein
  /// 🚀 Retourne les 5 meilleures correspondances triées par pertinence
  List<String> _findSimilarCities(String input) {
    // 🟢 Liste de villes communes (peut être étendue ou chargée depuis une API)
    const commonCities = [
      // Afrique
      'Cairo', 'Lagos', 'Casablanca', 'Marrakech', 'Fez', 'Tangier', 'Rabat',
      'Tunis', 'Algiers', 'Johannesburg', 'Nairobi', 'Accra',
      // Europe
      'London', 'Paris', 'Berlin', 'Rome', 'Madrid', 'Barcelona', 'Amsterdam',
      'Vienna', 'Prague', 'Warsaw', 'Moscow', 'Istanbul', 'Athens', 'Dublin',
      'Lisbon', 'Stockholm', 'Copenhagen', 'Oslo', 'Zurich', 'Geneva',
      // Asie
      'Tokyo', 'Bangkok', 'Singapore', 'Hong Kong', 'Mumbai', 'Delhi',
      'Bangalore',
      'Shanghai', 'Beijing', 'Seoul', 'Jakarta', 'Manila', 'Hanoi',
      'Ho Chi Minh',
      'Kuala Lumpur', 'Dubai', 'Abu Dhabi', 'Doha', 'Riyadh', 'Tehran',
      // Amérique du Nord
      'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
      'Philadelphia',
      'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin', 'Miami',
      'Toronto', 'Vancouver', 'Mexico City', 'Mexico', 'Montreal', 'Calgary',
      // Amérique du Sud
      'São Paulo', 'Buenos Aires', 'Rio de Janeiro', 'Salvador', 'Brasília',
      'Bogotá', 'Cartagena', 'Lima', 'Cusco', 'Santiago', 'Valparaíso',
      // Océanie
      'Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Auckland', 'Wellington',
    ];

    final inputLower = input.toLowerCase();
    final matches = <MapEntry<String, int>>[];

    for (final city in commonCities) {
      final distance = _levenshteinDistance(inputLower, city.toLowerCase());

      // 🚀 Accepte les correspondances si distance <= 3 (tolérance raisonnable)
      if (distance <= 3) {
        matches.add(MapEntry(city, distance));
      }

      // 🚀 Priorité absolue aux villes commençant par l'entrée
      if (city.toLowerCase().startsWith(inputLower)) {
        matches.add(MapEntry(city, -distance)); // Distance négative = priorité
      }
    }

    // Trie par pertinence (distance la plus faible d'abord)
    matches.sort((a, b) => a.value.compareTo(b.value));

    // Retourne les 5 meilleures matches (sans doublons)
    final uniqueMatches = <String>{};
    for (final match in matches) {
      if (uniqueMatches.length >= 5) break;
      uniqueMatches.add(match.key);
    }

    return uniqueMatches.toList();
  }

  /// 🟢 Calcule la distance de Levenshtein entre deux chaînes
  /// 🚀 Plus la distance est faible, plus les chaînes sont similaires
  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    // Initialise la matrice
    final d = List<List<int>>.generate(
      len1 + 1,
      (i) => List<int>.filled(len2 + 1, 0),
    );

    // Remplit la première ligne et colonne
    for (var i = 0; i <= len1; i++) {
      d[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      d[0][j] = j;
    }

    // Remplit le reste de la matrice
    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1, // suppression
          d[i][j - 1] + 1, // insertion
          d[i - 1][j - 1] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return d[len1][len2];
  }

  /// 🟢 Ajoute une ville aux favoris
  /// 🚀 Limite le nombre de favoris à 10 pour de meilleures performances
  Future<void> addFavorite(Weather weather) async {
    if (weather.city.isEmpty) {
      _error = 'Cannot add invalid city to favorites';
      notifyListeners();
      return;
    }

    try {
      // 🚀 Vérifie si déjà en favoris
      if (isFavorite(weather.city)) {
        _error = '${weather.city} is already in favorites';
        notifyListeners();
        return;
      }

      // 🚀 Limite le nombre de favoris
      if (_favorites.length >= 10) {
        _error = 'Maximum 10 favorites allowed. Please remove one first.';
        notifyListeners();
        return;
      }

      await _storageService.addFavorite(weather);
      _favorites = _storageService
          .getFavorites()
          .where((w) => w != null && w.city.isNotEmpty)
          .toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add favorite';
      notifyListeners();
    }
  }

  /// 🟢 Supprime une ville des favoris
  Future<void> removeFavorite(String city) async {
    if (city.isEmpty) return;

    try {
      await _storageService.removeFavorite(city);
      _favorites = _storageService
          .getFavorites()
          .where((w) => w != null && w.city.isNotEmpty)
          .toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove favorite';
      notifyListeners();
    }
  }

  /// 🟢 Vérifie si une ville est dans les favoris
  bool isFavorite(String city) {
    if (city.isEmpty) return false;

    try {
      return _storageService.isFavorite(city);
    } catch (e) {
      return false;
    }
  }

  /// 🟢 Charge la météo d'une ville favorite
  Future<void> loadFavoriteWeather(String city) async {
    if (city.isEmpty) {
      _error = 'Invalid city name';
      _state = WeatherState.error;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _state = WeatherState.loading;
    _error = null;
    notifyListeners();

    try {
      final weather = await _weatherService.getWeatherByCity(city);

      if (weather.city.isEmpty) {
        throw WeatherException('Invalid weather data');
      }

      _currentWeather = weather;
      _lastSearchedCity = city;
      _state = WeatherState.loaded;
      _isLoading = false;
      _error = null;
      notifyListeners();
    } on WeatherException catch (e) {
      _error = e.message;
      _state = WeatherState.error;
      _isLoading = false;
      _currentWeather = null;
      _lastSearchedCity = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load weather for $city';
      _state = WeatherState.error;
      _isLoading = false;
      _currentWeather = null;
      _lastSearchedCity = null;
      notifyListeners();
    }
  }

  /// 🟢 Efface le message d'erreur
  void clearError() {
    _error = null;
    if (_currentWeather != null) {
      _state = WeatherState.loaded;
    } else {
      _state = WeatherState.initial;
    }
    notifyListeners();
  }

  /// 🟢 Efface la météo actuelle et remet l'état à initial
  void clearCurrentWeather() {
    _currentWeather = null;
    _lastSearchedCity = null;
    _state = WeatherState.initial;
    _error = null;
    notifyListeners();
  }

  /// 🚀 Nouvelle méthode pour rafraîchir la météo actuelle
  Future<void> refreshCurrentWeather() async {
    if (_currentWeather == null || _currentWeather!.city.isEmpty) return;

    await searchWeather(_currentWeather!.city);
  }

  /// 🚀 Nettoie les ressources
  @override
  void dispose() {
    _weatherService.dispose();
    super.dispose();
  }
}
