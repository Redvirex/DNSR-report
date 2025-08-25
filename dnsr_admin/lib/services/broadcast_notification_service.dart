import 'dart:developer' as developer;
import '../services/supabase_service.dart';
import '../services/fcm_service.dart';

class BroadcastNotificationService {
  /// Send a broadcast notification to all users with FCM tokens
  static Future<NotificationResult> sendToAllUsers({
    required String title,
    required String message,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      developer.log('Starting broadcast notification to all users', name: 'BroadcastNotification');
      
      // Step 1: Save advice to database
      developer.log('Saving security advice to database', name: 'BroadcastNotification');
      final adviceSaved = await AdminSupabaseService.instance.saveSecurityAdvice(
        titre: title,
        contenu: message,
      );
      
      if (!adviceSaved) {
        developer.log('Warning: Failed to save advice to database, but continuing with notification', name: 'BroadcastNotification');
      } else {
        developer.log('Security advice saved to database successfully', name: 'BroadcastNotification');
      }
      
      // Step 2: Get all users with FCM tokens
      final users = await AdminSupabaseService.instance.getAllUsersWithFCMTokens();
      developer.log('Found ${users.length} users with FCM tokens', name: 'BroadcastNotification');
      
      if (users.isEmpty) {
        return NotificationResult(
          totalUsers: 0,
          successCount: 0,
          failureCount: 0,
          failedTokens: [],
          duration: stopwatch.elapsed,
        );
      }
      
      // Step 3: Extract FCM tokens
      final tokens = users.map((user) => user.fcmToken).toList();
      
      // Step 3.5: Test authentication before sending
      developer.log('Testing edge function authentication...', name: 'BroadcastNotification');
      final authTest = await FCMService.testEdgeFunctionAuth();
      developer.log('Auth test result: $authTest', name: 'BroadcastNotification');
      
      // Step 4: Send notifications using batch processing (no maps_link for broadcast messages)
      final results = await FCMService.sendNotificationsToTokensBatch(
        fcmTokens: tokens,
        title: title,
        message: message,
        data: {}, // Empty data for broadcast messages
      );
      
      // Step 5: Process results
      final successCount = results.values.where((success) => success).length;
      final failureCount = results.values.where((success) => !success).length;
      final failedTokens = results.entries
          .where((entry) => !entry.value)
          .map((entry) => entry.key)
          .toList();
      
      stopwatch.stop();
      
      developer.log('Broadcast notification results:', name: 'BroadcastNotification');
      developer.log('Total users: ${users.length}', name: 'BroadcastNotification');
      developer.log('Successful: $successCount', name: 'BroadcastNotification');
      developer.log('Failed: $failureCount', name: 'BroadcastNotification');
      developer.log('Duration: ${stopwatch.elapsed.inSeconds}s', name: 'BroadcastNotification');
      
      return NotificationResult(
        totalUsers: users.length,
        successCount: successCount,
        failureCount: failureCount,
        failedTokens: failedTokens,
        duration: stopwatch.elapsed,
      );
      
    } catch (e) {
      stopwatch.stop();
      developer.log('Error in broadcast notification service: $e', name: 'BroadcastNotification', error: e);
      
      return NotificationResult(
        totalUsers: 0,
        successCount: 0,
        failureCount: 1,
        failedTokens: ['error'],
        duration: stopwatch.elapsed,
      );
    }
  }
}
