import 'package:flutter/material.dart';
import 'package:weather_app/models/weather_model.dart';

class FavoriteItem extends StatelessWidget {
  final Weather weather;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const FavoriteItem({
    Key? key,
    required this.weather,
    required this.onTap,
    required this.onRemove,
  }) : super(key: key);

  String _getWeatherIcon(String icon) {
    switch (icon) {
      case '01d':
        return '☀️';
      case '01n':
        return '🌙';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
      case '10d':
      case '10n':
        return '🌧️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(
          _getWeatherIcon(weather.icon),
          style: const TextStyle(fontSize: 32),
        ),
        title: Text(
          weather.city,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${weather.temperature.toStringAsFixed(1)}°C - ${weather.description}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onRemove,
        ),
        onTap: onTap,
      ),
    );
  }
}
