import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/auth_provider.dart';
import 'package:weather_app/providers/theme_provider.dart';
import 'package:weather_app/providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getWeatherIcon(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('clear') || desc.contains('sunny')) {
      return Icons.wb_sunny_rounded;
    }
    if (desc.contains('cloud')) {
      return Icons.cloud_rounded;
    }
    if (desc.contains('rain')) {
      return Icons.water_drop_rounded;
    }
    if (desc.contains('snow')) {
      return Icons.ac_unit_rounded;
    }
    if (desc.contains('storm') || desc.contains('thunder')) {
      return Icons.thunderstorm_rounded;
    }
    if (desc.contains('fog') || desc.contains('mist')) {
      return Icons.filter_drama;
    }
    if (desc.contains('wind')) {
      return Icons.air_rounded;
    }
    return Icons.wb_cloudy_rounded;
  }

  Color _getWeatherColor(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('sunny'))
      return Colors.amber.shade400;
    if (desc.contains('cloud')) return Colors.blueGrey.shade300;
    if (desc.contains('rain')) return Colors.blue.shade400;
    if (desc.contains('snow')) return Colors.lightBlue.shade200;
    if (desc.contains('storm')) return Colors.deepPurple.shade400;
    if (desc.contains('fog') || desc.contains('mist'))
      return Colors.grey.shade400;
    return Colors.cyan.shade400;
  }

  Widget _getWeatherAnimation(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('clear') || desc.contains('sunny')) {
      return SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.wb_sunny_rounded,
                color: Colors.amber.shade300.withOpacity(0.3), size: 90),
            Icon(Icons.wb_sunny_rounded,
                color: Colors.amber.shade400, size: 70),
          ],
        ),
      );
    }

    if (desc.contains('rain')) {
      return SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.cloud_rounded,
                color: Colors.blueGrey.shade300, size: 70),
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.water_drop, color: Colors.blue.shade400, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.water_drop, color: Colors.blue.shade400, size: 16),
                  SizedBox(width: 4),
                  Icon(Icons.water_drop, color: Colors.blue.shade400, size: 16),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (desc.contains('snow')) {
      return SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.cloud_rounded,
                color: Colors.blueGrey.shade200, size: 70),
            Positioned(
              bottom: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.ac_unit, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Icon(Icons.ac_unit, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Icon(Icons.ac_unit, color: Colors.white, size: 14),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (desc.contains('storm') || desc.contains('thunder')) {
      return SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.cloud_rounded, color: Colors.grey.shade700, size: 70),
            Positioned(
              bottom: 5,
              child:
                  Icon(Icons.flash_on, color: Colors.yellow.shade600, size: 28),
            ),
          ],
        ),
      );
    }

    if (desc.contains('cloud')) {
      return SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: Icon(Icons.cloud_rounded,
                  color: Colors.blueGrey.shade200.withOpacity(0.6), size: 60),
            ),
            Positioned(
              right: 0,
              child: Icon(Icons.cloud_rounded,
                  color: Colors.blueGrey.shade300, size: 70),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 90,
      height: 90,
      child: Icon(_getWeatherIcon(description),
          color: _getWeatherColor(description), size: 70),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460)
                  ]
                : [
                    const Color(0xFF4A90E2),
                    const Color(0xFF5BA3F5),
                    const Color(0xFF7CB9E8)
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(isDark, themeProvider),
              _buildSearchBar(weatherProvider, isDark),
              Expanded(
                child: weatherProvider.isLoading
                    ? _buildLoading()
                    : weatherProvider.error != null
                        ? _buildError(weatherProvider.error!)
                        : _buildContent(weatherProvider, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.wb_sunny, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(
            'WeatherNow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon:
                const Icon(Icons.logout_rounded, color: Colors.white, size: 26),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WeatherProvider weatherProvider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search city...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: (value) => setState(() {}),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              weatherProvider.searchWeather(value);
              _searchController.clear();
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'Loading weather data...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off, size: 80, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Text(
            'Oops!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(WeatherProvider wp, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (wp.currentWeather != null)
          _buildMainWeatherCard(wp.currentWeather!, wp),
        const SizedBox(height: 30),
        _buildSectionHeader('My Places', wp.favorites.length),
        const SizedBox(height: 15),
        if (wp.favorites.isEmpty)
          _buildEmptyState()
        else
          ...wp.favorites.map((fav) => _buildLocationCard(fav, wp)),
      ],
    );
  }

  Widget _buildMainWeatherCard(weather, WeatherProvider wp) {
    final isFav = wp.isFavorite(weather.city);
    final weatherColor = _getWeatherColor(weather.description);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 24),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        weather.city,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isFav
                      ? Colors.red.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red.shade300 : Colors.white,
                    size: 26,
                  ),
                  onPressed: () => isFav
                      ? wp.removeFavorite(weather.city)
                      : wp.addFavorite(weather),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // 🔧 FIXED: Wrapped in Expanded to give proper constraints
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _getWeatherAnimation(weather.description),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperature.toInt()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w200,
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: weatherColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: weatherColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        weather.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickInfo(
                        Icons.water_drop_rounded,
                        '${weather.humidity}%',
                        'Humidity',
                        Colors.blue.shade300,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildQuickInfo(
                        Icons.air_rounded,
                        '${weather.windSpeed.toInt()} km/h',
                        'Wind',
                        Colors.cyan.shade300,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickInfo(
                        Icons.thermostat_rounded,
                        '${weather.feelsLike.toInt()}°',
                        'Feels Like',
                        Colors.orange.shade300,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildQuickInfo(
                        Icons.visibility_rounded,
                        weather.humidity > 70 ? 'Poor' : 'Good',
                        'Visibility',
                        Colors.purple.shade300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(
      IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink.shade400, Colors.red.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.favorite, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'saved',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(fav, WeatherProvider wp) {
    final weatherColor = _getWeatherColor(fav.description);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => wp.loadFavoriteWeather(fav.city),
        onLongPress: () => _showDeleteDialog(context, wp, fav.city),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: weatherColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: weatherColor.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _getWeatherIcon(fav.description),
                      color: weatherColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white70, size: 16),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                fav.city,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            fav.description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${fav.temperature.toInt()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.thermostat,
                                color: Colors.white70, size: 12),
                            SizedBox(width: 2),
                            Text(
                              '${fav.feelsLike.toInt()}°',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCompactInfo(
                      Icons.water_drop_rounded,
                      '${fav.humidity}%',
                      'Humidity',
                      Colors.blue.shade300,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildCompactInfo(
                      Icons.air_rounded,
                      '${fav.windSpeed.toInt()} km/h',
                      'Wind',
                      Colors.cyan.shade300,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildCompactInfo(
                      Icons.visibility_rounded,
                      fav.humidity > 70 ? 'Poor' : 'Good',
                      'Visibility',
                      Colors.purple.shade300,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfo(
      IconData icon, String value, String label, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(Icons.location_off,
                size: 60, color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Saved Locations',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Search for a city and tap the ❤️ icon\nto add it to your favorites',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WeatherProvider wp, String city) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red.shade400),
            SizedBox(width: 10),
            Text('Remove Location?'),
          ],
        ),
        content: Text('Remove $city from saved locations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              wp.removeFavorite(city);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
