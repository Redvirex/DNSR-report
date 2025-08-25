import 'package:flutter/foundation.dart';
import '../models/incident.dart';
import '../services/supabase_service.dart';
import '../services/fcm_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  /// Send proximity notifications for an incident
  Future<NotificationResult> sendProximityNotifications({
    required Incident incident,
    required String message,
    double radiusKm = 2.0,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      debugPrint('NotificationService: Starting proximity notification for incident ${incident.id}');
      
      // Step 1: Find nearby users
      final nearbyUsersData = await AdminSupabaseService.instance.findNearbyUsers(
        latitude: incident.latitude,
        longitude: incident.longitude,
        radiusKm: radiusKm,
      );

      if (nearbyUsersData.isEmpty) {
        debugPrint('NotificationService: No nearby users found');
        return NotificationResult(
          totalUsers: 0,
          successCount: 0,
          failureCount: 0,
          failedTokens: [],
          duration: stopwatch.elapsed,
        );
      }

      // Step 2: Prepare notification data
      final nearbyUsers = nearbyUsersData.map((data) => NearbyUser.fromJson(data)).toList();
      final fcmTokens = nearbyUsers.map((user) => user.fcmToken).where((token) => token.isNotEmpty).toList();
      
      debugPrint('NotificationService: Found ${nearbyUsers.length} nearby users, ${fcmTokens.length} with valid FCM tokens');

      // Step 3: Prepare notification content
      final title = 'Incident à proximité';
      final mapsLink = FCMService.generateMapsLink(incident.latitude, incident.longitude);
      final notificationData = {
        'maps_link': mapsLink,
      };

      // Step 4: Send notifications using batch processing
      final results = await FCMService.sendNotificationsToTokensBatch(
        fcmTokens: fcmTokens,
        title: title,
        message: message,
        data: notificationData,
      );

      // Step 5: Calculate results
      final successCount = results.values.where((success) => success).length;
      final failureCount = results.length - successCount;
      final failedTokens = results.entries
          .where((entry) => !entry.value)
          .map((entry) => entry.key)
          .toList();

      // Step 6: Log the notification activity
      await AdminSupabaseService.instance.logNotificationSent(
        incidentId: incident.id,
        recipientCount: fcmTokens.length,
        successCount: successCount,
        failureCount: failureCount,
        message: message,
      );

      stopwatch.stop();
      
      debugPrint('NotificationService: Sent notifications to $successCount/${fcmTokens.length} users in ${stopwatch.elapsedMilliseconds}ms');

      return NotificationResult(
        totalUsers: fcmTokens.length,
        successCount: successCount,
        failureCount: failureCount,
        failedTokens: failedTokens,
        duration: stopwatch.elapsed,
      );

    } catch (e) {
      stopwatch.stop();
      debugPrint('NotificationService: Error sending proximity notifications: $e');
      
      return NotificationResult(
        totalUsers: 0,
        successCount: 0,
        failureCount: 1,
        failedTokens: [],
        duration: stopwatch.elapsed,
      );
    }
  }

  /// Get predefined message templates for incidents
  List<String> getMessageTemplates(Incident incident) {
    return [
      'Incident signalé à proximité de votre position.',
      'Attention: Incident sur votre route, restez vigilant.',
      'Évitez la zone: Incident en cours près de votre position.',
      'Info trafic: Incident à proximité, ralentissements possibles.',
      'Incident ${_getStatusText(incident.statut)} dans votre secteur.',
    ];
  }

  /// Generate a contextual message based on incident details
  String generateContextualMessage(Incident incident, {double? distanceKm}) {
    final distanceText = distanceKm != null ? '${distanceKm.toStringAsFixed(1)}km' : 'proximité';
    final statusText = _getStatusText(incident.statut);
    
    if (incident.description != null && incident.description!.isNotEmpty) {
      // Truncate description if too long
      final description = incident.description!.length > 50 
          ? '${incident.description!.substring(0, 50)}...'
          : incident.description!;
      return 'Incident $statusText à $distanceText: $description';
    }
    
    return 'Incident $statusText signalé à $distanceText de votre position.';
  }

  String _getStatusText(IncidentStatut status) {
    switch (status) {
      case IncidentStatut.EN_ATTENTE:
        return 'en attente';
      case IncidentStatut.EN_COURS:
        return 'en cours';
      case IncidentStatut.TRAITE:
        return 'résolu';
    }
  }
}

/// Extension to add notification-related methods to Incident
extension IncidentNotification on Incident {
  String get mapsLink => FCMService.generateMapsLink(latitude, longitude);
  
  String getContextualMessage({double? distanceKm}) {
    return NotificationService.instance.generateContextualMessage(this, distanceKm: distanceKm);
  }
}
