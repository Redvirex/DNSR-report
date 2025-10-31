import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

// Import web config conditionally
import 'web_config.dart' if (dart.library.io) 'web_config_stub.dart';

class AppConfig {
  // Get values from environment variables with platform-specific fallbacks
  static String get supabaseUrl {
    if (kIsWeb) {
      final webUrl = WebConfig.getSupabaseUrl();
      // If web config is empty (local dev), fall back to .env
      if (webUrl.isEmpty && dotenv.env.containsKey('SUPABASE_URL')) {
        return dotenv.env['SUPABASE_URL']!;
      }
      return webUrl;
    }
    return dotenv.env['SUPABASE_URL'] ?? '';
  }
  
  static String get supabaseAnonKey {
    if (kIsWeb) {
      final webKey = WebConfig.getSupabaseAnonKey();
      // If web config is empty (local dev), fall back to .env
      if (webKey.isEmpty && dotenv.env.containsKey('SUPABASE_ANON_KEY')) {
        return dotenv.env['SUPABASE_ANON_KEY']!;
      }
      return webKey;
    }
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  // Admin-specific configuration
  static const String appName = 'DNSR Admin';
  static const String appVersion = '1.0.0';

  // Map configuration 
  static String get googleMapsApiKey {
    if (kIsWeb) {
      final webKey = WebConfig.getGoogleMapsApiKey();
      // If web config is empty (local dev), fall back to .env
      if (webKey.isEmpty && dotenv.env.containsKey('GOOGLE_MAPS_API_KEY')) {
        return dotenv.env['GOOGLE_MAPS_API_KEY']!;
      }
      return webKey;
    }
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }
  
  /// Initialize environment configuration
  static Future<void> initialize() async {
    try {
      // Load .env for both web and native platforms
      await dotenv.load(fileName: '.env');
      developer.log('✅ Loaded configuration from .env file');
    } catch (e) {
      // If .env file doesn't exist or fails to load, use default values
      developer.log('Warning: Could not load .env file. Using web configuration or defaults.');
    }
    // For web in production, configuration can also be loaded from meta tags or URL params
  }
}
