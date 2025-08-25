import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageService>(
      builder: (context, languageService, child) {
        return PopupMenuButton<Locale>(
          icon: const Icon(Icons.language),
          tooltip: _getLocalizedText(context, 'language'),
          onSelected: (Locale locale) {
            languageService.changeLanguage(locale);
          },
          itemBuilder: (BuildContext context) {
            return LanguageService.supportedLocales.map((Locale locale) {
              return PopupMenuItem<Locale>(
                value: locale,
                child: Row(
                  children: [
                    Text(
                      _getFlagEmoji(locale),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(languageService.getLanguageDisplayName(locale)),
                    if (languageService.currentLocale.languageCode ==
                        locale.languageCode)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, color: Colors.green, size: 18),
                      ),
                  ],
                ),
              );
            }).toList();
          },
        );
      },
    );
  }

  String _getFlagEmoji(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'ar':
        return '🇩🇿';
      default:
        return '🌐';
    }
  }

  String _getLocalizedText(BuildContext context, String key) {
    switch (key) {
      case 'language':
        return 'Language';
      default:
        return key;
    }
  }
}
