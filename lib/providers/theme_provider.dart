import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String themeBoxName = "settings";
  static const String themeKey = "themeMode";

  late Box box;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void _loadTheme() async {
    box = await Hive.openBox(themeBoxName);
    final savedTheme = box.get(themeKey, defaultValue: "light");

    _themeMode = savedTheme == "dark" ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    box.put(themeKey, _themeMode == ThemeMode.dark ? "dark" : "light");
    notifyListeners();
  }
}
