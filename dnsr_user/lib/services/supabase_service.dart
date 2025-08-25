import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/user_profile.dart';
import 'package:flutter_auth_app/config/app_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  /// Initializes Supabase client with the provided URL and anonymous key
  /// Must be called before using any other Supabase functionality
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  User? get currentUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Sends a magic link for account deletion confirmation
  Future<void> sendDeleteAccountMagicLink({required String email}) async {
    try {
      await client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb 
            ? null 
            : '${AppConfig.redirectTo}?action=delete-account',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithMagicLink({required String email}) async {
    try {
      await client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : AppConfig.redirectTo,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : AppConfig.redirectTo,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a new user profile in the database
  /// Returns the created UserProfile object with generated ID
  Future<UserProfile> createUserProfile({
    required String userId,
    required String email,
    String? nom,
    String? prenom,
    String? numeroTelephone,
  }) async {
    try {
      final data = {
        'id': userId,
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'numero_telephone': numeroTelephone,
        'role': 'CITOYEN',
        'status': 'DEACTIVATED',
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await client
          .from('utilisateurs')
          .insert(data)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieves user profile from database by user ID
  /// Returns null if profile doesn't exist
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('utilisateurs')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing user profile in the database
  /// Returns the updated UserProfile object
  Future<UserProfile> updateUserProfile({
    required String userId,
    String? nom,
    String? prenom,
    String? numeroTelephone,
    double? latitude,
    double? longitude,
    bool verifyPhone = false,
  }) async {
    try {
      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nom != null) data['nom'] = nom;
      if (prenom != null) data['prenom'] = prenom;
      if (numeroTelephone != null) data['numero_telephone'] = numeroTelephone;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await client
          .from('utilisateurs')
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      final updatedProfile = UserProfile.fromJson(response);

      // Check if profile should be activated after this update
      if (verifyPhone && _shouldActivateProfile(updatedProfile)) {
        return await activateUserWithPhoneVerification(
          userId: userId,
          phoneNumber: numeroTelephone!,
        );
      }

      return updatedProfile;
    } catch (e) {
      rethrow;
    }
  }

  /// Checks if a user profile should be activated
  /// Profile is activated when user has full name and verified phone number
  bool _shouldActivateProfile(UserProfile profile) {
    return profile.nom != null &&
           profile.nom!.isNotEmpty &&
           profile.prenom != null &&
           profile.prenom!.isNotEmpty &&
           profile.numeroTelephone != null &&
           profile.numeroTelephone!.isNotEmpty;
  }

  Future<void> updateUserFCMToken(String userId, String fcmToken) async {
    try {
      await client
          .from('utilisateurs')
          .update({'fcm_token': fcmToken})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the user's location coordinates in the database
  /// Used for location tracking and incident reporting
  Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await client
          .from('utilisateurs')
          .update({
            'latitude': latitude,
            'longitude': longitude,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> profileExists(String userId) async {
    try {
      final response = await client
          .from('utilisateurs')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      rethrow;
    }
  }

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

  /// Activates a user with phone verification
  /// Deactivates any other users with the same phone number
  /// Returns the updated UserProfile object
  Future<UserProfile> activateUserWithPhoneVerification({
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      // First, deactivate all other users with the same phone number
      await client
          .from('utilisateurs')
          .update({
            'status': 'DEACTIVATED',
            'numero_telephone': null,
            'deactivated_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('numero_telephone', phoneNumber)
          .neq('id', userId)
          .neq('role', 'ADMIN'); // Don't deactivate admins

      // Then activate the current user
      final response = await client
          .from('utilisateurs')
          .update({
            'status': 'ACTIVE',
            'deactivated_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Legacy method for backward compatibility
  /// Use activateUserWithPhoneVerification instead
  Future<UserProfile> verifyPhoneNumber({
    required String userId,
    required String phoneNumber,
  }) async {
    return await activateUserWithPhoneVerification(
      userId: userId,
      phoneNumber: phoneNumber,
    );
  }

  Future<List<Map<String, dynamic>>> getIncidentCategories() async {
    try {
      final response = await client
          .from('categorie_incident')
          .select('*')
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getIncidentTypesByCategory(
    int categoryId,
  ) async {
    try {
      final response = await client
          .from('type_incident')
          .select('*')
          .eq('categorie_id', categoryId)
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getIncidentTypes() async {
    try {
      final response = await client
          .from('type_incident')
          .select('*')
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getVehicleTypes() async {
    try {
      final response = await client
          .from('type_vehicule')
          .select('*')
          .order('id', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Uploads an incident photo to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadIncidentPhoto(File imageFile, String fileName) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final filePath = 'incident_imgs/${user.id}/$fileName';

      await client.storage.from('incident-imgs').upload(filePath, imageFile);

      final String publicUrl = client.storage
          .from('incident-imgs')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Submits a new incident report to the database
  /// Returns the ID of the created incident report
  Future<String> submitIncidentReport({
    required String description,
    required double latitude,
    required double longitude,
    required int typeIncidentId,
    int? typeVehiculeId,
    required List<String> photoUrls,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final incidentResponse = await client
          .from('incident')
          .insert({
            'utilisateur_id': user.id,
            'description': description.isNotEmpty ? description : null,
            'latitude': latitude,
            'longitude': longitude,
            'type_incident': typeIncidentId,
            'type_vehicule': typeVehiculeId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      final incidentId = incidentResponse['id'] as String;

      if (photoUrls.isNotEmpty) {
        final photoInserts = photoUrls
            .map((url) => {'url': url, 'incident_id': incidentId})
            .toList();

        await client.from('incident_img').insert(photoInserts);
      }

      return incidentId;
    } catch (e) {
      rethrow;
    }
  }

  /// Deletes user account and all associated data
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Delete user profile data
      await client.from('utilisateurs').delete().eq('id', userId);
      
      // Delete the auth user account
      // Note: This requires admin privileges, so we'll use RPC function
      await client.rpc('delete_user', params: {'user_id': userId});
    } catch (e) {
      rethrow;
    }
  }
}
