import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;
import '../models/user_profile.dart';
import '../models/incident.dart';

class AdminSupabaseService {
  static AdminSupabaseService? _instance;
  static AdminSupabaseService get instance =>
      _instance ??= AdminSupabaseService._();

  AdminSupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sign in with email and password (admin login)
  Future<UserProfile?> signInWithEmailPassword(String email, String password) async {
    try {
      developer.log('Attempting login for email: $email', name: 'SupabaseService');

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      developer.log(
          'Auth response received - User: ${response.user?.id ?? "null"}',
          name: 'SupabaseService');
      developer.log('Session: ${response.session != null}', name: 'SupabaseService');

      if (response.user == null) {
        throw Exception('Authentication failed - no user returned');
      }

      if (response.session == null) {
        throw Exception('Authentication failed - no session created');
      }

      developer.log('Checking user profile for admin access', name: 'SupabaseService');
      final userProfile = await getUserProfile(response.user!.id);
      
      if (userProfile == null) {
        await client.auth.signOut();
        throw Exception('User profile not found in system');
      }
      
      if (userProfile.role != RoleUtilisateur.ADMIN) {
        await client.auth.signOut();
        throw Exception('Access denied: Admin privileges required');
      }
      
      if (userProfile.status != StatutUtilisateur.ACTIVE) {
        await client.auth.signOut();
        throw Exception('Account is deactivated. Please contact support.');
      }
      
      developer.log('Admin login successful', name: 'SupabaseService');
      return userProfile;
      
    } on AuthException catch (e) {
      developer.log('Auth error: ${e.message}', name: 'SupabaseService', error: e);
      switch (e.message) {
        case 'Invalid login credentials':
          throw Exception('Invalid email or password');
        case 'Email not confirmed':
          throw Exception('Please verify your email address');
        case 'Too many requests':
          throw Exception('Too many login attempts. Please try again later');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      developer.log('Login error: $e', name: 'SupabaseService', error: e);
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Unexpected error during login: $e');
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      developer.log('Fetching user profile for userId: $userId', name: 'SupabaseService');
      final response = await client
          .from('utilisateurs')
          .select()
          .eq('id', userId)
          .maybeSingle();

      debugPrint('SupabaseService: Profile query response: $response');
      if (response == null) {
        developer.log('No profile found for user $userId', name: 'SupabaseService');
        return null;
      }
      
      final profile = UserProfile.fromJson(response);
      developer.log('Profile parsed - role: ${profile.role}, status: ${profile.status}', name: 'SupabaseService');
      return profile;
    } catch (e) {
      developer.log('Error fetching user profile: $e', name: 'SupabaseService', error: e);
      rethrow;
    }
  }

  /// Check if user exists by email
  Future<bool> checkUserExistsByEmail(String email) async {
    try {
      final response = await client
          .from('utilisateurs')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      return response != null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all incidents with pagination and filtering
  Future<List<Incident>> getIncidents({
    int limit = 50,
    int offset = 0,
    DateTime? fromDate,
    DateTime? toDate,
    IncidentStatut? statutFilter,
  }) async {
    try {
      var query = client.from('incident').select('*');

      if (fromDate != null) {
        query = query.gte('created_at', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('created_at', toDate.toIso8601String());
      }

      if (statutFilter != null) {
        query = query.eq('statut', statutFilter.name);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      List<Incident> incidents = [];
      for (var incidentData in response) {
        final photoUrls = await getIncidentPhotoUrls(
          incidentData['id'] as String,
        );

        String? userName;
        String? userEmail;
        if (incidentData['utilisateur_id'] != null) {
          final userData = await client
              .from('utilisateurs')
              .select('nom, prenom, email')
              .eq('id', incidentData['utilisateur_id'])
              .maybeSingle();

          if (userData != null) {
            userName = userData['nom'] != null && userData['prenom'] != null
                ? '${userData['prenom']} ${userData['nom']}'
                : null;
            userEmail = userData['email'];
          }
        }

        String? incidentTypeName;
        String? categoryName;
        if (incidentData['type_incident'] != null) {
          final typeData = await client
              .from('type_incident')
              .select('title, categorie_id')
              .eq('id', incidentData['type_incident'])
              .maybeSingle();

          if (typeData != null) {
            incidentTypeName = typeData['title'];

            if (typeData['categorie_id'] != null) {
              final categoryData = await client
                  .from('categorie_incident')
                  .select('title')
                  .eq('id', typeData['categorie_id'])
                  .maybeSingle();

              if (categoryData != null) {
                categoryName = categoryData['title'];
              }
            }
          }
        }

        String? vehicleTypeName;
        if (incidentData['type_vehicule'] != null) {
          final vehicleData = await client
              .from('type_vehicule')
              .select('title')
              .eq('id', incidentData['type_vehicule'])
              .maybeSingle();

          if (vehicleData != null) {
            vehicleTypeName = vehicleData['title'];
          }
        }

        final incident = Incident.fromJson({
          ...incidentData,
          'photo_urls': photoUrls,
          'user_name': userName,
          'user_email': userEmail,
          'incident_type_name': incidentTypeName,
          'vehicle_type_name': vehicleTypeName,
          'category_name': categoryName,
        });
        incidents.add(incident);
      }

      return incidents;
    } catch (e) {
      rethrow;
    }
  }

  /// Get incident photo URLs
  Future<List<String>> getIncidentPhotoUrls(String incidentId) async {
    try {
      final response = await client
          .from('incident_img')
          .select('url')
          .eq('incident_id', incidentId);

      return response.map((item) => item['url'] as String).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get incident statistics
  Future<Map<String, int>> getIncidentStatistics() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = now.subtract(const Duration(days: 7));
      final thisMonth = DateTime(now.year, now.month, 1);

      // Get total incidents
      final totalResponse = await client.from('incident').select('id');

      final todayResponse = await client
          .from('incident')
          .select('id')
          .gte('created_at', today.toIso8601String());

      final weekResponse = await client
          .from('incident')
          .select('id')
          .gte('created_at', thisWeek.toIso8601String());

      final monthResponse = await client
          .from('incident')
          .select('id')
          .gte('created_at', thisMonth.toIso8601String());

      return {
        'total': totalResponse.length,
        'today': todayResponse.length,
        'week': weekResponse.length,
        'month': monthResponse.length,
        'pending': totalResponse.length,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get recent incidents (for dashboard)
  Future<List<Incident>> getRecentIncidents({int limit = 10}) async {
    return getIncidents(limit: limit, offset: 0);
  }

  // Get incidents by location (for map)
  Future<List<Incident>> getIncidentsByBounds({
    required double northEastLat,
    required double northEastLng,
    required double southWestLat,
    required double southWestLng,
  }) async {
    try {
      final response = await client
          .from('incident')
          .select('*')
          .gte('latitude', southWestLat)
          .lte('latitude', northEastLat)
          .gte('longitude', southWestLng)
          .lte('longitude', northEastLng);

      List<Incident> incidents = [];
      for (var incidentData in response) {
        // Get photo URLs
        final photoUrls = await getIncidentPhotoUrls(
          incidentData['id'] as String,
        );

        // Get user data
        String? userName;
        String? userEmail;
        if (incidentData['utilisateur_id'] != null) {
          final userData = await client
              .from('utilisateurs')
              .select('nom, prenom, email')
              .eq('id', incidentData['utilisateur_id'])
              .maybeSingle();

          if (userData != null) {
            userName = userData['nom'] != null && userData['prenom'] != null
                ? '${userData['prenom']} ${userData['nom']}'
                : null;
            userEmail = userData['email'];
          }
        }

        // Get incident type data
        String? incidentTypeName;
        if (incidentData['type_incident'] != null) {
          final typeData = await client
              .from('type_incident')
              .select('title')
              .eq('id', incidentData['type_incident'])
              .maybeSingle();

          if (typeData != null) {
            incidentTypeName = typeData['title'];
          }
        }

        // Get vehicle type data
        String? vehicleTypeName;
        if (incidentData['type_vehicule'] != null) {
          final vehicleData = await client
              .from('type_vehicule')
              .select('title')
              .eq('id', incidentData['type_vehicule'])
              .maybeSingle();

          if (vehicleData != null) {
            vehicleTypeName = vehicleData['title'];
          }
        }

        final incident = Incident.fromJson({
          ...incidentData,
          'photo_urls': photoUrls,
          'user_name': userName,
          'user_email': userEmail,
          'incident_type_name': incidentTypeName,
          'vehicle_type_name': vehicleTypeName,
        });
        incidents.add(incident);
      }

      return incidents;
    } catch (e) {
      rethrow;
    }
  }

  // Get all users (for user management)
  Future<List<UserProfile>> getAllUsers({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('utilisateurs')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((userData) => UserProfile.fromJson(userData))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get total count of users
  Future<int> getUsersCount() async {
    try {
      final response = await client
          .from('utilisateurs')
          .select('id')
          .count();

      return response.count;
    } catch (e) {
      rethrow;
    }
  }

  // Update incident status
  Future<bool> updateIncidentStatus(
    String incidentId,
    IncidentStatut newStatus, {
    String? commentaire,
  }) async {
    try {
      // First, get the current incident to check current status
      final currentIncident = await client
          .from('incident')
          .select('statut, utilisateur_id')
          .eq('id', incidentId)
          .single();

      final oldStatus = _parseStatut(currentIncident['statut']);

      // Update the incident status
      await client
          .from('incident')
          .update({
            'statut': newStatus.name,
          })
          .eq('id', incidentId);

      // Create historique_statut entry for audit trail
      await _createHistoriqueStatut(
        incidentId: incidentId,
        ancienStatut: oldStatus,
        nouveauStatut: newStatus,
        commentaire: commentaire,
      );

      return true;
    } catch (e) {
      developer.log('Error updating incident status: $e', name: 'SupabaseService', error: e);
      return false;
    }
  }

  // Create historique_statut entry for audit trail
  Future<void> _createHistoriqueStatut({
    required String incidentId,
    required IncidentStatut ancienStatut,
    required IncidentStatut nouveauStatut,
    String? commentaire,
  }) async {
    try {
      await client.from('historique_statut').insert({
        'incident_id': incidentId,
        'ancien_statut': ancienStatut.name,
        'nouveau_statut': nouveauStatut.name,
        'details': commentaire,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('Error creating historique_statut: $e', name: 'SupabaseService', error: e);
      rethrow;
    }
  }

  // Get status history for an incident
  Future<List<Map<String, dynamic>>> getStatusHistory(String incidentId) async {
    try {
      final response = await client
          .from('historique_statut')
          .select('*')
          .eq('incident_id', incidentId)
          .order('updated_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      developer.log('Error fetching status history: $e', name: 'SupabaseService', error: e);
      return [];
    }
  }

  // Save driving advice to conseils_securite table
  Future<bool> saveSecurityAdvice({
    required String titre,
    required String contenu,
  }) async {
    try {
      if (kDebugMode) {
        developer.log('Saving security advice to database', name: 'SupabaseService');
      }
      
      await client.from('conseils_securite').insert({
        'titre': titre,
        'contenu': contenu,
      });
      
      if (kDebugMode) {
        developer.log('Security advice saved successfully', name: 'SupabaseService');
      }
      return true;
    } catch (e) {
      developer.log('Error saving security advice: $e', name: 'SupabaseService', error: e);
      return false;
    }
  }

  // Parse statut value from database
  IncidentStatut _parseStatut(dynamic statutValue) {
    if (statutValue == null) return IncidentStatut.EN_ATTENTE;

    final statutStr = statutValue.toString().toUpperCase();
    return IncidentStatut.values.firstWhere(
      (status) => status.name == statutStr,
      orElse: () => IncidentStatut.EN_ATTENTE,
    );
  }

  /// Find users within a specified radius of a location
  Future<List<Map<String, dynamic>>> findNearbyUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    try {
      // Using Haversine formula for distance calculation
      // Note: This is a simplified approach. For production, consider using PostGIS
      final response = await client
          .from('utilisateurs')
          .select('id, fcm_token, latitude, longitude, nom, prenom')
          .not('fcm_token', 'is', null)
          .not('latitude', 'is', null)
          .not('longitude', 'is', null);

      if (response.isEmpty) return [];

      // Filter users within radius using Haversine formula
      final nearbyUsers = <Map<String, dynamic>>[];
      for (final user in response) {
        final userLat = user['latitude'] as double;
        final userLng = user['longitude'] as double;
        
        final distance = _calculateDistance(
          latitude, longitude, 
          userLat, userLng
        );
        
        if (distance <= radiusKm) {
          nearbyUsers.add({
            ...user,
            'distance_km': distance,
          });
        }
      }

      return nearbyUsers;
    } catch (e) {
      developer.log('Error finding nearby users: $e', name: 'SupabaseService', error: e);
      return [];
    }
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Log notification sending activity
  Future<void> logNotificationSent({
    required String incidentId,
    required int recipientCount,
    required int successCount,
    required int failureCount,
    required String message,
    String? adminUserId,
  }) async {
    try {
      // Since there's no notification_logs table in the schema,
      // we'll create an alert record for tracking purposes
      await client.from('alerte').insert({
        'incident_id': incidentId,
        'message': 'Admin notification sent: $message (Recipients: $recipientCount, Success: $successCount, Failed: $failureCount)',
      });
      
      if (kDebugMode) {
        developer.log('Logged notification sending activity', name: 'SupabaseService');
      }
    } catch (e) {
      developer.log('Error logging notification: $e', name: 'SupabaseService', error: e);
      // Don't rethrow - logging failure shouldn't break the notification flow
    }
  }

  // Get all users with FCM tokens for broadcast notifications
  Future<List<BroadcastUser>> getAllUsersWithFCMTokens() async {
    try {
      if (kDebugMode) {
        developer.log('Fetching all users with FCM tokens', name: 'SupabaseService');
      }
      
      final response = await client
          .from('utilisateurs')
          .select('id, nom, prenom, fcm_token')
          .not('fcm_token', 'is', null)
          .neq('fcm_token', '');
      
      if (kDebugMode) {
        developer.log('Found ${response.length} users with FCM tokens', name: 'SupabaseService');
      }
      
      return response.map((userData) => BroadcastUser.fromJson(userData)).toList();
    } catch (e) {
      developer.log('Error fetching users with FCM tokens: $e', name: 'SupabaseService', error: e);
      return [];
    }
  }
}

/// Simple user model for broadcast notifications
class BroadcastUser {
  final String userId;
  final String fcmToken;
  final String? userName;

  BroadcastUser({
    required this.userId,
    required this.fcmToken,
    this.userName,
  });

  factory BroadcastUser.fromJson(Map<String, dynamic> json) {
    return BroadcastUser(
      userId: json['id'] ?? '',
      fcmToken: json['fcm_token'] ?? '',
      userName: '${json['nom'] ?? ''} ${json['prenom'] ?? ''}'.trim(),
    );
  }
}
