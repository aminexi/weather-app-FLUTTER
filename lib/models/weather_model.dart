class Weather {
  final String city;
  final double temperature;
  final String description;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String icon;
  final int pressure;
  final int visibility;
  final double uvIndex;
  final DateTime timestamp;

  Weather({
    required this.city,
    required this.temperature,
    required this.description,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.icon,
    this.pressure = 0,
    this.visibility = 0,
    this.uvIndex = 0.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Weather copyWith({
    String? city,
    double? temperature,
    String? description,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    String? icon,
    int? pressure,
    int? visibility,
    double? uvIndex,
    DateTime? timestamp,
  }) {
    return Weather(
      city: city ?? this.city,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      icon: icon ?? this.icon,
      pressure: pressure ?? this.pressure,
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory Weather.fromJson(Map<String, dynamic> json) {
    try {
      // 🟢 Validation stricte des données essentielles
      if (json['location'] == null) {
        throw const FormatException('Missing location data in API response');
      }
      if (json['current'] == null) {
        throw const FormatException(
            'Missing current weather data in API response');
      }

      final location = json['location'] as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>;

      if (current['condition'] == null) {
        throw const FormatException(
            'Missing weather condition in API response');
      }

      final condition = current['condition'] as Map<String, dynamic>;

      // 🚀 Extraction sécurisée avec valeurs par défaut robustes
      return Weather(
        city: location['name']?.toString() ?? 'Unknown Location',
        temperature: _safeDouble(current['temp_c'], 0.0),
        description: condition['text']?.toString() ?? 'No Description',
        feelsLike: _safeDouble(current['feelslike_c'], 0.0),
        humidity: _safeInt(current['humidity'], 0),
        windSpeed: _safeDouble(current['wind_kph'], 0.0),
        icon: condition['icon']?.toString() ?? '',
        pressure: _safeInt(current['pressure_mb'], 0),
        visibility: _safeDouble(current['vis_km'], 0.0).toInt(),
        uvIndex: _safeDouble(current['uv'], 0.0),
      );
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Failed to parse weather data: $e');
    }
  }

  /// 🟢 Convertit en toute sécurité une valeur en double
  static double _safeDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// 🟢 Convertit en toute sécurité une valeur en int
  static int _safeInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'temperature': temperature,
      'description': description,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'icon': icon,
      'pressure': pressure,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      city: map['city']?.toString() ?? 'Unknown Location',
      temperature: _safeDouble(map['temperature'], 0.0),
      description: map['description']?.toString() ?? 'No Description',
      feelsLike: _safeDouble(map['feelsLike'], 0.0),
      humidity: _safeInt(map['humidity'], 0),
      windSpeed: _safeDouble(map['windSpeed'], 0.0),
      icon: map['icon']?.toString() ?? '',
      pressure: _safeInt(map['pressure'], 0),
      visibility: _safeInt(map['visibility'], 0),
      uvIndex: _safeDouble(map['uvIndex'], 0.0),
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          city == other.city &&
          temperature == other.temperature;

  @override
  int get hashCode => city.hashCode ^ temperature.hashCode;

  @override
  String toString() =>
      'Weather(city: $city, temp: $temperature°C, desc: $description)';
}
