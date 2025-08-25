import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initializes Firebase Cloud Messaging service
  /// Sets up message handling for notifications
  static Future<void> initialize() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, badge: true, sound: true);

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        log('FCM: User granted permission');
      } else {
        log('FCM: User declined or has not accepted permission');
      }

      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }
    } catch (e) {
      log('FCM: Initialization failed: $e');
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    final String? mapsLink = message.data['maps_link'];

    if (mapsLink != null && mapsLink.isNotEmpty) {
      _openMapsLink(mapsLink);
    }
  }

  static Future<void> _openMapsLink(String mapsLink) async {
    try {
      final Uri uri = Uri.parse(mapsLink);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          log('FCM: Alternative launch also failed: $e');
        }
      }
    } catch (e) {
      log('FCM: Error opening maps link: $e');
      log('FCM: Error type: ${e.runtimeType}');
    }
  }

  static Future<String?> getToken() async {
    try {
      log('FCM: Requesting token...');
      String? token = await _firebaseMessaging.getToken();

      return token;
    } catch (e) {
      log('FCM: Error getting token: $e');

      return null;
    }
  }

  static void onTokenRefresh(Function(String) onNewToken) {
    _firebaseMessaging.onTokenRefresh.listen(onNewToken);
  }
}
