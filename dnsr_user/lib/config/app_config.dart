import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
    // Supabase Configuration
    static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
    static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    static String get redirectTo => dotenv.env['REDIRECT_TO'] ?? '';

    // Google Sign-In Configuration
    static String get googleWebClientId => dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

    // Twilio Configuration
    static String get twilioAccountSid => dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
    static String get twilioAuthToken => dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
    static String get twilioVerifyServiceSid => dotenv.env['TWILIO_VERIFY_SERVICE_SID'] ?? '';
    static String get twilioPhoneNumber => dotenv.env['TWILIO_PHONE_NUMBER'] ?? '';

    // App Configuration
    static String get appName => dotenv.env['APP_NAME'] ?? '';
    static String get appVersion => dotenv.env['APP_VERSION'] ?? '';
}
