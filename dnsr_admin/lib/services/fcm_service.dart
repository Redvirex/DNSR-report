import 'dart:convert';
import 'package:flutter_admin_dashboard/config/app_config.dart';
import 'package:flutter_admin_dashboard/services/supabase_service.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/incident.dart';
import '../config/fcm_config.dart';

class FCMService {
  /// Test edge function authentication
  static Future<bool> testEdgeFunctionAuth() async {
    try {
      final session = AdminSupabaseService.instance.client.auth.currentSession;
      if (session == null) {
        developer.log('No active session for auth test', name: 'FCMService');
        return false;
      }

      developer.log('Testing edge function authentication...', name: 'FCMService');
      developer.log('Session token length: ${session.accessToken.length}', name: 'FCMService');
      developer.log('Session expires at: ${session.expiresAt}', name: 'FCMService');

      // Test with a simple payload
      final testPayload = {
        'title': 'Test',
        'body': 'Auth test',
        'tokens': ['test_token'],
        'data': {},
      };

      final response = await AdminSupabaseService.instance.client.functions.invoke(
        'sendNotification',
        body: testPayload,
      );

      developer.log('Edge function test response status: ${response.status}', name: 'FCMService');
      developer.log('Edge function test response data: ${response.data}', name: 'FCMService');

      return response.status == 200 || response.status == 400; // 400 is OK, means auth worked but invalid token
    } catch (e) {
      developer.log('Edge function auth test failed: $e', name: 'FCMService', error: e);
      return false;
    }
  }

  /// Send push notification to a single FCM token using FCM v1 API
  static Future<bool> sendNotificationToToken({
    required String fcmToken,
    required String title,
    required String message,
    required Map<String, dynamic> data,
  }) async {
    try {
      final notificationPayload = {
        'message': {
          'token': fcmToken,
          'notification': {'title': title, 'body': message},
          'data': {'maps_link': data['maps_link']?.toString() ?? ''},
        },
      };

      if (kDebugMode) {
        developer.log(
          'Sending FCM notification to token: ${fcmToken.substring(0, 20)}...',
          name: 'FCMService',
        );
        developer.log('Title: $title', name: 'FCMService');
        developer.log('Message: $message', name: 'FCMService');
        if (data.containsKey('maps_link')) {
          developer.log('Maps Link: ${data['maps_link']}', name: 'FCMService');
        }
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          developer.log(
            'Location: ${data['latitude']}, ${data['longitude']}',
            name: 'FCMService',
          );
        }
      }

      final response = await AdminSupabaseService.instance.client.functions
          .invoke('sendNotification', body: jsonEncode(notificationPayload));

      if (response.status == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Send notifications to multiple FCM tokens using edge function batch processing
  static Future<Map<String, bool>> sendNotificationsToTokensBatch({
    required List<String> fcmTokens,
    required String title,
    required String message,
    required Map<String, dynamic> data,
  }) async {
    try {
      _logBatchStart(fcmTokens.length, title, message);

      // Check session and prepare payload
      final session = AdminSupabaseService.instance.client.auth.currentSession;
      if (session == null) {
        developer.log('No active session for edge function call', name: 'FCMService');
        return _fallbackToIndividualTokens(fcmTokens, title, message, data);
      }

      final requestPayload = _buildRequestPayload(title, message, fcmTokens, data);
      
      // Try Supabase client first, then HTTP fallback
      final result = await _trySupabaseClient(requestPayload) ?? 
                    await _tryDirectHttp(requestPayload, session);
      
      if (result != null) return result;

      // Both methods failed, fallback to individual processing
      developer.log('Both edge function methods failed, falling back to individual tokens', name: 'FCMService');
      return _fallbackToIndividualTokens(fcmTokens, title, message, data);
      
    } catch (e) {
      developer.log('Batch notification error: $e', name: 'FCMService', error: e);
      return _fallbackToIndividualTokens(fcmTokens, title, message, data);
    }
  }

  /// Log batch notification start
  static void _logBatchStart(int tokenCount, String title, String message) {
    if (!kDebugMode) return;
    
    developer.log('Sending batch notification to $tokenCount tokens', name: 'FCMService');
    developer.log('Title: $title', name: 'FCMService');
    developer.log('Message: $message', name: 'FCMService');
  }

  /// Build request payload for edge function
  static Map<String, dynamic> _buildRequestPayload(
    String title, 
    String message, 
    List<String> tokens, 
    Map<String, dynamic> data,
  ) {
    final dataPayload = <String, String>{};
    data.forEach((key, value) {
      dataPayload[key] = value?.toString() ?? '';
    });

    return {
      'title': title,
      'body': message,
      'tokens': tokens,
      'data': dataPayload,
    };
  }

  /// Try sending via Supabase client
  static Future<Map<String, bool>?> _trySupabaseClient(Map<String, dynamic> payload) async {
    try {
      final response = await AdminSupabaseService.instance.client.functions.invoke(
        'sendNotification',
        body: payload,
      );

      if (response.status == 200 && response.data != null) {
        return _parseEdgeFunctionResponse(response.data, 'Supabase client');
      }
    } catch (e) {
      developer.log('Supabase client invoke failed, trying direct HTTP: $e', name: 'FCMService');
    }
    return null;
  }

  /// Try sending via direct HTTP
  static Future<Map<String, bool>?> _tryDirectHttp(
    Map<String, dynamic> payload, 
    dynamic session, // Using dynamic since we don't import supabase Session type directly
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.supabaseUrl}/functions/v1/sendNotification'),
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
          'apikey': AppConfig.supabaseAnonKey,
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseEdgeFunctionResponse(responseData, 'Direct HTTP');
      } else {
        developer.log(
          'Direct HTTP failed: ${response.statusCode} - ${response.body}',
          name: 'FCMService',
        );
      }
    } catch (e) {
      developer.log('Direct HTTP error: $e', name: 'FCMService', error: e);
    }
    return null;
  }

  /// Parse edge function response into token results
  static Map<String, bool> _parseEdgeFunctionResponse(
    Map<String, dynamic> responseData, 
    String method,
  ) {
    final results = responseData['results'] as List<dynamic>? ?? [];
    final tokenResults = <String, bool>{};
    
    for (final result in results) {
      final resultMap = result as Map<String, dynamic>;
      tokenResults[resultMap['token'] as String] = resultMap['success'] as bool;
    }

    if (kDebugMode) {
      developer.log(
        '$method batch completed: ${responseData['successful']} successful, ${responseData['failed']} failed',
        name: 'FCMService',
      );
    }

    return tokenResults;
  }

  /// Fallback to individual token processing
  static Future<Map<String, bool>> _fallbackToIndividualTokens(
    List<String> fcmTokens,
    String title,
    String message,
    Map<String, dynamic> data,
  ) {
    return sendNotificationsToTokens(
      fcmTokens: fcmTokens,
      title: title,
      message: message,
      data: data,
    );
  }

  /// Send notifications to multiple FCM tokens
  static Future<Map<String, bool>> sendNotificationsToTokens({
    required List<String> fcmTokens,
    required String title,
    required String message,
    required Map<String, dynamic> data,
  }) async {
    final results = <String, bool>{};

    // Send notifications in batches to avoid overwhelming the server
    for (int i = 0; i < fcmTokens.length; i += FCMConfig.maxBatchSize) {
      final batch = fcmTokens.skip(i).take(FCMConfig.maxBatchSize).toList();
      final futures = batch.map(
        (token) => sendNotificationToToken(
          fcmToken: token,
          title: title,
          message: message,
          data: data,
        ),
      );

      final batchResults = await Future.wait(futures);
      for (int j = 0; j < batch.length; j++) {
        results[batch[j]] = batchResults[j];
      }

      // Add a small delay between batches
      if (i + FCMConfig.maxBatchSize < fcmTokens.length) {
        await Future.delayed(Duration(milliseconds: FCMConfig.batchDelayMs));
      }
    }

    return results;
  }

  /// Generate a Google Maps link for an incident
  static String generateMapsLink(double latitude, double longitude) {
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }

  /// Generate predefined notification messages
  static List<String> getPredefinedMessages(Incident incident) {
    return [
      'Incident signalé à proximité de votre position.',
      'Attention: Incident sur votre route, ${_getDistanceText()} à ${_getDirectionText()}.',
      'Incident en cours dans votre zone. Restez vigilant.',
      'Évitez la zone: Incident signalé près de votre position.',
      'Info trafic: Incident à proximité, ralentissements possibles.',
    ];
  }

  /// Generate custom notification message with incident details
  static String generateIncidentMessage({
    required Incident incident,
    String? customMessage,
    double? distanceKm,
  }) {
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }

    final distanceText = distanceKm != null
        ? '${distanceKm.toStringAsFixed(1)}km'
        : 'proximité';
    final statusText = _getStatusText(incident.statut);

    if (incident.description != null && incident.description!.isNotEmpty) {
      return 'Incident $statusText à $distanceText: ${incident.description}';
    }

    return 'Incident $statusText signalé à $distanceText de votre position.';
  }

  static String _getStatusText(IncidentStatut status) {
    switch (status) {
      case IncidentStatut.EN_ATTENTE:
        return 'en attente';
      case IncidentStatut.EN_COURS:
        return 'en cours';
      case IncidentStatut.TRAITE:
        return 'traité';
    }
  }

  static String _getDistanceText() {
    return '1.2km'; // This would be calculated based on actual distance
  }

  static String _getDirectionText() {
    return 'devant vous'; // This would be calculated based on user direction
  }
}

/// Model for nearby user data
class NearbyUser {
  final String userId;
  final String fcmToken;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String? userName;
  final String? userEmail;

  NearbyUser({
    required this.userId,
    required this.fcmToken,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.userName,
    this.userEmail,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    return NearbyUser(
      userId: json['id'] ?? '',
      fcmToken: json['fcm_token'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      userName: '${json['nom'] ?? ''} ${json['prenom'] ?? ''}'.trim(),
      userEmail: json['email'],
    );
  }
}

/// Result of a notification sending operation
class NotificationResult {
  final int totalUsers;
  final int successCount;
  final int failureCount;
  final List<String> failedTokens;
  final Duration duration;

  NotificationResult({
    required this.totalUsers,
    required this.successCount,
    required this.failureCount,
    required this.failedTokens,
    required this.duration,
  });

  bool get hasFailures => failureCount > 0;
  double get successRate => totalUsers > 0 ? successCount / totalUsers : 0.0;
}
