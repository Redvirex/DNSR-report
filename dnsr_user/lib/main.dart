import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:developer';
import 'services/supabase_service.dart';
import 'services/fcm_service.dart';
import 'services/language_service.dart';
import 'services/deep_link_handler.dart';
import 'providers/auth_provider.dart';
import 'controllers/navigation_controller.dart';
import 'pages/splash_page.dart';
import 'pages/delete_account_confirmation_page.dart';
import 'config/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Main entry point of the Flutter application
/// Initializes Firebase, Supabase, FCM, and language services before starting the app
void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  final languageService = LanguageService();
  await languageService.initialize();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await Future.wait([
      FCMService.initialize(),
      SupabaseService.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      ),
    ]);
    
    // Initialize deep link handler
    DeepLinkHandler.instance.initialize();
  } catch (e) {
    log('Initialization error: $e');
  }

  runApp(DNSRApp(languageService: languageService));
}

/// Root widget of the application
/// Sets up providers, localization, and theme configuration
class DNSRApp extends StatelessWidget {
  final LanguageService languageService;

  const DNSRApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<LanguageService>.value(value: languageService),
        ChangeNotifierProvider<NavigationController>(create: (_) => NavigationController()),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
            title: 'Flutter Auth App',
            debugShowCheckedModeBanner: false,
            locale: languageService.currentLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
              Locale('ar', ''),
            ],
            home: const SplashPage(),
            routes: {
              '/delete-account-confirmation': (context) => const DeleteAccountConfirmationPage(),
            },
            onGenerateRoute: (settings) {
              // Handle deep links for account deletion
              if (settings.name?.contains('delete-account') == true) {
                return MaterialPageRoute(
                  builder: (context) => const DeleteAccountConfirmationPage(),
                );
              }
              return null;
            },
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
          );
        },
      ),
    );
  }
}
