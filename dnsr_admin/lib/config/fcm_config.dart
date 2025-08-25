class FCMConfig {
  static const String projectId = 'dnsr-project';

  static String get sendNotificationUrl =>
      'https://uqbgptfslaumojuvgyub.supabase.co/functions/v1/sendNotification';

  static const int maxBatchSize = 10;
  static const int batchDelayMs = 100;
  static const double maxRadiusKm = 5.0;
  static const double defaultRadiusKm = 2.0;

  static const String highPriority = 'HIGH';
  static const String normalPriority = 'NORMAL';
}
