import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';

  Locale _currentLocale = const Locale('fr');

  Locale get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('ar', 'DZ'),
  ];

  /// Initializes the language service and loads the saved locale from preferences
  /// Sets the current locale to saved value or defaults to system locale
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  /// Changes the app language to the specified locale
  /// Saves the preference and notifies all listeners of the change
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;

    _currentLocale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      default:
        return locale.languageCode;
    }
  }
}
