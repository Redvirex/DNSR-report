import 'package:web/web.dart' as web;

/// Web-specific configuration that reads from environment or URL parameters
class WebConfig {
  /// Get configuration from various sources in order of priority:
  /// 1. URL parameters (for development)
  /// 2. Meta tags in index.html (for production)
  /// 3. Default fallback values
  static String getSupabaseUrl() {
    // Check URL parameters first (development)
    final uri = Uri.parse(web.window.location.href);
    if (uri.queryParameters.containsKey('supabase_url')) {
      return uri.queryParameters['supabase_url']!;
    }
    
    // Check meta tags (production deployment)
    final metaElement = web.document.querySelector('meta[name="supabase-url"]');
    if (metaElement != null) {
      final content = metaElement.getAttribute('content');
      if (content != null && content.isNotEmpty) {
        return content;
      }
    }
    
    // Fallback to default
    return '';
  }
  
  static String getSupabaseAnonKey() {
    // Check URL parameters first (development)
    final uri = Uri.parse(web.window.location.href);
    if (uri.queryParameters.containsKey('supabase_key')) {
      return uri.queryParameters['supabase_key']!;
    }
    
    // Check meta tags (production deployment)
    final metaElement = web.document.querySelector('meta[name="supabase-anon-key"]');
    if (metaElement != null) {
      final content = metaElement.getAttribute('content');
      if (content != null && content.isNotEmpty) {
        return content;
      }
    }
    
    // Fallback to default
    return '';
  }
  
  static String getGoogleMapsApiKey() {
    final uri = Uri.parse(web.window.location.href);
    if (uri.queryParameters.containsKey('maps_key')) {
      return uri.queryParameters['maps_key']!;
    }
    
    final metaElement = web.document.querySelector('meta[name="google-maps-key"]');
    if (metaElement != null) {
      final content = metaElement.getAttribute('content');
      if (content != null && content.isNotEmpty) {
        return content;
      }
    }
    
    return '';
  }
}
