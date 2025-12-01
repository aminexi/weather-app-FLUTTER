import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/weather_model.dart';

/// 🟢 Exception personnalisée pour la gestion des erreurs météo
class WeatherException implements Exception {
  final String message; // 🟢 Message d'erreur lisible
  final String? code; // 🟢 Code d'erreur optionnel (ex: NETWORK, TIMEOUT)

  WeatherException(this.message, {this.code});

  @override
  String toString() => message;
}

/// 🟢 Service pour récupérer la météo depuis l'API WeatherAPI
/// ⚡ Supporte cache interne pour éviter des appels répétés
/// 🚀 Optimisé avec un client HTTP réutilisable et une meilleure gestion du cache
class WeatherService {
  // 🟢 URL de base de l'API
  static const String _baseUrl = 'http://api.weatherapi.com/v1/current.json';

  // 🟢 Clé API pour authentification auprès du service météo
  static const String _apiKey = 'f19c165f74fb4198805212448251710';

  // 🟢 Timeout pour les requêtes HTTP
  static const Duration _timeout = Duration(seconds: 10);

  // 🚀 Client HTTP réutilisable pour de meilleures performances
  static final http.Client _client = http.Client();

  // 🟢 Cache en mémoire pour stocker les résultats récents
  final Map<String, Weather> _cache = {};
  final Map<String, DateTime> _cacheTime = {};

  // 🟢 Durée de validité du cache
  static const Duration _cacheDuration = Duration(minutes: 10);

  /// 🟢 Nettoie le cache des entrées expirées
  /// 🚀 Optimisé pour éviter les itérations multiples
  void _cleanCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    // 🟢 Identifie les clés expirées
    _cacheTime.forEach((key, time) {
      if (now.difference(time) > _cacheDuration) {
        expiredKeys.add(key);
      }
    });

    // 🟢 Supprime les données expirées
    for (final key in expiredKeys) {
      _cacheTime.remove(key);
      _cache.remove(key);
    }
  }

  /// 🟢 Récupère la météo d'une ville par son nom
  Future<Weather> getWeatherByCity(String city) async {
    // 🚀 Validation plus stricte pour éviter les appels inutiles
    final trimmedCity = city.trim();
    if (trimmedCity.isEmpty) {
      throw WeatherException('City name cannot be empty');
    }

    _cleanCache();
    final key = trimmedCity.toLowerCase();

    // 🟢 Retourne la météo depuis le cache si disponible
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    try {
      // 🚀 Utilise le client HTTP réutilisable
      final uri = Uri.parse('$_baseUrl?key=$_apiKey&q=$trimmedCity&aqi=no');
      final response = await _client.get(uri).timeout(_timeout);

      return _handleResponse(response, key);
    } on http.ClientException catch (e) {
      throw WeatherException('Network error: ${e.message}', code: 'NETWORK');
    } on TimeoutException {
      throw WeatherException('Request timed out. Please check your connection.',
          code: 'TIMEOUT');
    } on FormatException catch (e) {
      throw WeatherException('Invalid data received: ${e.message}',
          code: 'FORMAT');
    } catch (e) {
      throw WeatherException('Unexpected error: $e', code: 'UNKNOWN');
    }
  }

  /// 🟢 Récupère la météo par latitude et longitude
  Future<Weather> getWeatherByCoordinates(
      double latitude, double longitude) async {
    // 🟢 Vérification de la validité des coordonnées
    if (latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw WeatherException('Invalid coordinates');
    }

    final cacheKey =
        '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    _cleanCache();

    // 🟢 Retourne depuis le cache si disponible
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    try {
      // 🚀 Utilise le client HTTP réutilisable
      final uri =
          Uri.parse('$_baseUrl?key=$_apiKey&q=$latitude,$longitude&aqi=no');
      final response = await _client.get(uri).timeout(_timeout);

      return _handleResponse(response, cacheKey);
    } on http.ClientException catch (e) {
      throw WeatherException('Network error: ${e.message}', code: 'NETWORK');
    } on TimeoutException {
      throw WeatherException('Request timed out. Please check your connection.',
          code: 'TIMEOUT');
    } on FormatException catch (e) {
      throw WeatherException('Invalid data received: ${e.message}',
          code: 'FORMAT');
    } catch (e) {
      throw WeatherException('Unexpected error: $e', code: 'UNKNOWN');
    }
  }

  /// 🟢 Analyse la réponse HTTP et convertit en Weather
  /// 🚀 Gestion d'erreur améliorée avec messages plus clairs
  Weather _handleResponse(http.Response response, String cacheKey) {
    if (response.statusCode != 200) {
      // 🟢 Tente de parser le message d'erreur de l'API si disponible
      String errorMessage = 'Failed to fetch weather';

      try {
        final errorJson = jsonDecode(response.body);
        if (errorJson['error'] != null &&
            errorJson['error']['message'] != null) {
          errorMessage = errorJson['error']['message'];
        }
      } catch (e) {
        // 🟢 Si le parsing échoue, utilise des messages génériques
      }

      // 🟢 Retourne des erreurs spécifiques selon le code HTTP
      if (response.statusCode == 400) {
        throw WeatherException('Invalid request. Please check the city name.',
            code: 'BAD_REQUEST');
      } else if (response.statusCode == 401) {
        throw WeatherException('Invalid API key', code: 'UNAUTHORIZED');
      } else if (response.statusCode == 404 || response.statusCode == 1006) {
        throw WeatherException(
            'City not found. Please check spelling and try again.',
            code: 'NOT_FOUND');
      } else if (response.statusCode == 429) {
        throw WeatherException('Too many requests. Please try again later.',
            code: 'RATE_LIMIT');
      } else if (response.statusCode >= 500) {
        throw WeatherException('Server error. Please try again later.',
            code: 'SERVER_ERROR');
      } else {
        throw WeatherException(errorMessage, code: 'HTTP_ERROR');
      }
    }

    // 🟢 Parsing sécurisé de la réponse JSON
    try {
      final jsonData = jsonDecode(response.body);

      if (jsonData == null ||
          jsonData['location'] == null ||
          jsonData['current'] == null) {
        throw WeatherException('Invalid response from weather service',
            code: 'INVALID_DATA');
      }

      final weather = Weather.fromJson(jsonData);

      // 🟢 Sauvegarde dans le cache
      _cache[cacheKey] = weather;
      _cacheTime[cacheKey] = DateTime.now();
      return weather;
    } on FormatException catch (e) {
      throw WeatherException('Unable to read weather data. Please try again.',
          code: 'PARSE_ERROR');
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException('Failed to process weather data',
          code: 'PARSE_ERROR');
    }
  }

  /// 🟢 Vide complètement le cache en mémoire
  void clearCache() {
    _cache.clear();
    _cacheTime.clear();
  }

  /// 🚀 Nouvelle méthode pour nettoyer les ressources
  void dispose() {
    _cache.clear();
    _cacheTime.clear();
  }
}
