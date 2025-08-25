import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

// Import web config conditionally
import 'web_config.dart' if (dart.library.io) 'web_config_stub.dart';

class AppConfig {
  // Get values from environment variables with platform-specific fallbacks
  static String get supabaseUrl {
    if (kIsWeb) {
      return WebConfig.getSupabaseUrl();
    }
    return dotenv.env['SUPABASE_URL'] ?? '';
  }
  
  static String get supabaseAnonKey {
    if (kIsWeb) {
      return WebConfig.getSupabaseAnonKey();
    }
    return dotenv.env['SUPABASE_ANON_KEY'] ?? 
        '';
  }

  // Admin-specific configuration
  static const String appName = 'DNSR Admin';
  static const String appVersion = '1.0.0';

  // Map configuration 
  static String get googleMapsApiKey {
    if (kIsWeb) {
      return WebConfig.getGoogleMapsApiKey();
    }
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }
  
  /// Initialize environment configuration
  static Future<void> initialize() async {
    if (!kIsWeb) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        // If .env file doesn't exist or fails to load, use default values
        developer.log('Warning: Could not load .env file. Using default configuration.');
      }
    }
    // For web, configuration is loaded dynamically from meta tags or URL params
  }
}
