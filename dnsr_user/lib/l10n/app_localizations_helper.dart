import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'DNSR Report App',
      'welcome': 'Welcome',
      'continue': 'Continue',
      'continueWithGoogle': 'Continue with Google',
      'or': 'or',
      'profile': 'Profile',
      'signOut': 'Sign Out',
      'loading': 'Loading...',
      'cancel': 'Cancel',
      'settings': 'Settings',
    },
    'fr': {
      'appTitle': 'Application DNSR Report',
      'welcome': 'Bienvenue',
      'continue': 'Continuer',
      'continueWithGoogle': 'Continuer avec Google',
      'or': 'ou',
      'profile': 'Profil',
      'signOut': 'Se déconnecter',
      'loading': 'Chargement...',
      'cancel': 'Annuler',
      'settings': 'Paramètres',
    },
    'ar': {
      'appTitle': 'تطبيق تقرير DNSR',
      'welcome': 'مرحبا',
      'continue': 'متابعة',
      'continueWithGoogle': 'متابعة مع جوجل',
      'or': 'أو',
      'profile': 'الملف الشخصي',
      'signOut': 'تسجيل الخروج',
      'loading': 'جاري التحميل...',
      'cancel': 'إلغاء',
      'settings': 'الإعدادات',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('appTitle');
  String get welcome => translate('welcome');
  String get continueText => translate('continue');
  String get continueWithGoogle => translate('continueWithGoogle');
  String get or => translate('or');
  String get profile => translate('profile');
  String get signOut => translate('signOut');
  String get loading => translate('loading');
  String get cancel => translate('cancel');
  String get settings => translate('settings');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
