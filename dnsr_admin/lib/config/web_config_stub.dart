/// Stub implementation for non-web platforms
class WebConfig {
  static String getSupabaseUrl() {
    throw UnsupportedError('WebConfig is only supported on web platforms');
  }
  
  static String getSupabaseAnonKey() {
    throw UnsupportedError('WebConfig is only supported on web platforms');
  }
  
  static String getGoogleMapsApiKey() {
    throw UnsupportedError('WebConfig is only supported on web platforms');
  }
}
