// 🟢 UI / Architecture Flutter — Import principal Material
import 'package:flutter/material.dart';

// 🟢 Gestion des données (Hive - DB locale)
import 'package:hive_flutter/hive_flutter.dart';

// 🟢 Architecture & State management — Provider
import 'package:provider/provider.dart';

// 🟢 Authentification — Gestion de l’état utilisateur
import 'package:weather_app/providers/auth_provider.dart';

// 🟢 Thèmes & UI/UX dynamique
import 'package:weather_app/providers/theme_provider.dart';

// 🟢 Gestion API météo (REST)
import 'package:weather_app/providers/weather_provider.dart';

// 🟢 Écran d’authentification
import 'package:weather_app/screens/login_screen.dart';

// 🟢 Écran principal (après connexion)
import 'package:weather_app/screens/home_screen.dart';

// 🟢 Persistance locale — Service de stockage (Hive / SharedPreferences / etc.)
import 'package:weather_app/services/local_storage_service.dart';

// 🟢 Design & UI — Thèmes globaux
import 'package:weather_app/theme/app_theme.dart';

// 🟢 Point d’entrée principal de l’application
void main() async {
  // 🟢 Nécessaire pour utiliser async avant runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 🟢 Initialisation de Hive pour DB locale
  await Hive.initFlutter();

  // 🟢 Chargement du service de stockage local
  final storageService = LocalStorageService();
  await storageService.initialize();

  // 🟢 Box pour stocker l'authentification
  await Hive.openBox('auth');

  // 🟢 Box pour stocker les villes favorites
  await Hive.openBox('favorites');

  // 🟢 Lancement de l’application
  runApp(const MyApp());
}

// 🟢 Widget principal — Architecture propre (aucune logique ici)
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🟢 Gestion d’état globale (architecture propre) — MultiProvider
    return MultiProvider(
      providers: [
        // 🟢 Authentification
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // 🟢 Gestion API REST (Weather)
        ChangeNotifierProvider(create: (_) => WeatherProvider()),

        // 🟢 Thème clair/sombre (UI/UX + Accessibilité)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      // 🟢 Consumer pour écouter changement de thème en temps réel
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            // 🟢 Identité de l’application
            title: 'Weather App',

            // 🟢 Thème clair
            theme: AppTheme.lightTheme,

            // 🟢 Thème sombre
            darkTheme: AppTheme.darkTheme,

            // 🟢 Utilise le thème sélectionné via provider
            themeMode: themeProvider.themeMode,

            // 🟢 Logique de navigation sécurisée selon authentification
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                // 🟢 Si connecté → Home
                // 🟢 Sinon → Login
                return authProvider.isLoggedIn
                    ? const HomeScreen()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
