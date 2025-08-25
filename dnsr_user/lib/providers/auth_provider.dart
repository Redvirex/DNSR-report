import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:developer';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../services/location_service.dart';
import '../services/fcm_service.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, profileIncomplete }

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final LocationService _locationService = LocationService.instance;

  AuthStatus _status = AuthStatus.unknown;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLocationSharing = false;
  bool _isFCMTokenSharing = false;

  Timer? _locationTimer;
  static const Duration _locationUpdateInterval = Duration(minutes: 5);
  bool _isPeriodicLocationEnabled = true;

  AuthStatus get status => _status;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isLocationSharing => _isLocationSharing;
  bool get isFCMTokenSharing => _isFCMTokenSharing;
  bool get isPeriodicLocationEnabled => _isPeriodicLocationEnabled;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get hasCompleteProfile => _userProfile?.isProfileComplete ?? false;

  AuthProvider() {
    _initialize();
  }

  /// Initializes the AuthProvider by setting up Supabase auth state listener
  /// and checking the current authentication status
  void _initialize() {
    _supabaseService.authStateChanges.listen((AuthState data) {
      _handleAuthStateChange(data);
    });

    final session = _supabaseService.currentUser;
    if (session != null) {
      _loadUserProfile(session.id);
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  /// Handles authentication state changes from Supabase
  /// Updates the provider's status and loads user profile when authenticated
  void _handleAuthStateChange(AuthState data) async {
    if (data.session != null) {
      await _loadUserProfile(data.session!.user.id);
    } else {
      _status = AuthStatus.unauthenticated;
      _userProfile = null;
      notifyListeners();
    }
  }

  /// Loads user profile from the database using the provided user ID
  /// Sets authentication status based on profile completeness
  Future<void> _loadUserProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final profile = await _supabaseService.getUserProfile(userId);

      if (profile != null) {
        _userProfile = profile;
        _status = profile.isProfileComplete
            ? AuthStatus.authenticated
            : AuthStatus.profileIncomplete;
      } else {
        final user = _supabaseService.currentUser!;
        _userProfile = await _supabaseService.createUserProfile(
          userId: user.id,
          email: user.email!,
          nom: "",
          prenom: "",
        );
        _status = AuthStatus.profileIncomplete;
      }
      _shareLocationAfterAuth();
      _initializeFCMAfterAuth();
      _startPeriodicLocationUpdates();
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeFCMAfterAuth() async {
    try {
      log('Starting FCM initialization...');

      final token = await FCMService.getToken();
      log('Retrieved FCM token: $token');

      if (token != null && _userProfile != null) {
        log('Updating FCM token for user: ${_userProfile!.id}');

        await _supabaseService.updateUserFCMToken(_userProfile!.id, token);

        _userProfile = _userProfile!.copyWith(fcmToken: token);
        notifyListeners();

        log('FCM token stored successfully');
      } else {
        log('FCM token is null or user profile is null');
        log('Token: $token');
        log('User profile: $_userProfile');
      }

      FCMService.onTokenRefresh((newToken) async {
        log('FCM token refreshed: $newToken');
        if (_userProfile != null) {
          await _updateFCMToken(newToken);
        }
      });
    } catch (e) {
      log('FCM initialization failed: $e');
    }
  }

  Future<void> _updateFCMToken(String newToken) async {
    if (_userProfile == null) return;

    try {
      log('Updating FCM token due to refresh: $newToken');

      _isFCMTokenSharing = true;
      notifyListeners();

      await _supabaseService.updateUserFCMToken(_userProfile!.id, newToken);

      _userProfile = _userProfile!.copyWith(fcmToken: newToken);

      _isFCMTokenSharing = false;
      notifyListeners();

      log('FCM token updated successfully: $newToken');
    } catch (e) {
      _isFCMTokenSharing = false;
      notifyListeners();
      log('FCM token update failed: $e');
    }
  }

  Future<void> _shareLocationAfterAuth() async {
    if (_userProfile == null) return;

    try {
      _isLocationSharing = true;
      notifyListeners();

      final permissionStatus = await _locationService
          .requestLocationPermission();

      if (permissionStatus == LocationPermissionStatus.granted) {
        final position = await _locationService.getCurrentLocation();

        if (position != null) {
          await _supabaseService.updateUserLocation(
            userId: _userProfile!.id,
            latitude: position.latitude,
            longitude: position.longitude,
          );

          _userProfile = _userProfile!.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      }
    } catch (e) {
      log('Location sharing failed: $e');
    } finally {
      _isLocationSharing = false;
      notifyListeners();
    }
  }

  /// Gets the current device location and shares it with the server
  /// Updates the user's location in the database and local profile
  /// Returns true if location sharing was successful
  Future<bool> shareLocation() async {
    if (_userProfile == null) return false;

    try {
      _isLocationSharing = true;
      notifyListeners();

      final permissionStatus = await _locationService
          .requestLocationPermission();

      if (permissionStatus == LocationPermissionStatus.granted) {
        final position = await _locationService.getCurrentLocation();

        if (position != null) {
          await _supabaseService.updateUserLocation(
            userId: _userProfile!.id,
            latitude: position.latitude,
            longitude: position.longitude,
          );

          _userProfile = _userProfile!.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
          );

          return true;
        }
      } else {
        _errorMessage = _getLocationPermissionMessage(permissionStatus);
      }

      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLocationSharing = false;
      notifyListeners();
    }
  }

  String _getLocationPermissionMessage(LocationPermissionStatus status) {
    switch (status) {
      case LocationPermissionStatus.denied:
        return "Permission de localisation refusée. Veuillez autoriser l'accès à votre position.";
      case LocationPermissionStatus.deniedForever:
        return "Permission de localisation définitivement refusée. Veuillez l'activer dans les paramètres de l'application.";
      case LocationPermissionStatus.serviceDisabled:
        return 'Services de localisation désactivés. Veuillez les activer dans les paramètres de votre appareil.';
      case LocationPermissionStatus.granted:
        return 'Permission accordée';
    }
  }

  Future<void> openLocationSettings() async {
    await _locationService.openAppSettings();
  }

  /// Sends a magic link authentication email to the specified address
  /// Returns true if the email was sent successfully
  Future<bool> signInWithMagicLink(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.signInWithMagicLink(email: email);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends a magic link for secure account deletion
  /// Returns true if the email was sent successfully
  Future<bool> sendDeleteAccountMagicLink() async {
    if (_userProfile?.email == null) {
      _errorMessage = "No email address found for the account";
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.sendDeleteAccountMagicLink(
        email: _userProfile!.email,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initiates Google Sign-In authentication flow
  /// Returns true if the sign-in was successful
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.signInWithGoogle();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkUserExists(String email) async {
    try {
      final exists = await _supabaseService.checkUserExistsByEmail(email);
      return exists;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Updates user profile information in the database
  /// Handles phone number verification if a new phone number is provided
  /// Returns true if the update was successful
  Future<bool> updateProfile({
    String? nom,
    String? prenom,
    String? numeroTelephone,
    bool verifyPhone = false,
  }) async {
    if (_userProfile == null) {
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (verifyPhone && numeroTelephone != null) {
        _userProfile = await _supabaseService.updateUserProfile(
          userId: _userProfile!.id,
          nom: nom,
          prenom: prenom,
          numeroTelephone: numeroTelephone,
          verifyPhone: false,
        );

        _userProfile = await _supabaseService.verifyPhoneNumber(
          userId: _userProfile!.id,
          phoneNumber: numeroTelephone,
        );
      } else {
        _userProfile = await _supabaseService.updateUserProfile(
          userId: _userProfile!.id,
          nom: nom,
          prenom: prenom,
          numeroTelephone: numeroTelephone,
          verifyPhone: verifyPhone,
        );
      }

      _status = _userProfile!.isProfileComplete
          ? AuthStatus.authenticated
          : AuthStatus.profileIncomplete;

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Completes phone verification and activates user if profile is complete
  /// This method should be called after OTP verification is successful
  Future<bool> completePhoneVerification({
    required String phoneNumber,
  }) async {
    if (_userProfile == null) {
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if user has complete profile (full name + phone)
      final hasFullName = _userProfile!.nom != null && 
                         _userProfile!.nom!.isNotEmpty &&
                         _userProfile!.prenom != null && 
                         _userProfile!.prenom!.isNotEmpty;

      if (hasFullName) {
        // Activate user and deactivate others with same phone number
        _userProfile = await _supabaseService.activateUserWithPhoneVerification(
          userId: _userProfile!.id,
          phoneNumber: phoneNumber,
        );
      } else {
        // Just update the phone number without activation
        _userProfile = await _supabaseService.updateUserProfile(
          userId: _userProfile!.id,
          numeroTelephone: phoneNumber,
        );
      }

      _status = _userProfile!.isProfileComplete
          ? AuthStatus.authenticated
          : AuthStatus.profileIncomplete;

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      _stopPeriodicLocationUpdates();
      await _supabaseService.signOut();

      _status = AuthStatus.unauthenticated;
      _userProfile = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void refreshProfile() {
    if (_userProfile != null) {
      _loadUserProfile(_userProfile!.id);
    }
  }

  void _startPeriodicLocationUpdates() {
    if (!_isPeriodicLocationEnabled || _locationTimer != null) {
      return;
    }

    log(
      'Starting periodic location updates every ${_locationUpdateInterval.inMinutes} minutes',
    );

    _locationTimer = Timer.periodic(_locationUpdateInterval, (timer) async {
      if (_status == AuthStatus.authenticated && _userProfile != null) {
        await _updateLocationPeriodically();
      } else {
        _stopPeriodicLocationUpdates();
      }
    });
  }

  void _stopPeriodicLocationUpdates() {
    if (_locationTimer != null) {
      log('Stopping periodic location updates');
      _locationTimer?.cancel();
      _locationTimer = null;
    }
  }

  Future<void> _updateLocationPeriodically() async {
    try {
      log('Periodic location update triggered');

      final position = await _locationService.getCurrentLocation();
      if (position != null && _userProfile != null) {
        await _supabaseService.updateUserLocation(
          userId: _userProfile!.id,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        _userProfile = _userProfile!.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
        );

        log(
          'Periodic location updated: ${position.latitude}, ${position.longitude}',
        );
        notifyListeners();
      }
    } catch (e) {
      log('Error during periodic location update: $e');
    }
  }

  void setPeriodicLocationEnabled(bool enabled) {
    _isPeriodicLocationEnabled = enabled;

    if (enabled && _status == AuthStatus.authenticated) {
      _startPeriodicLocationUpdates();
    } else {
      _stopPeriodicLocationUpdates();
    }

    notifyListeners();
  }

  /// Deletes the user account and all associated data
  Future<bool> deleteAccount() async {
    if (_userProfile == null) {
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabaseService.deleteUserAccount(_userProfile!.id);
      
      // Sign out and reset state
      await signOut();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopPeriodicLocationUpdates();
    super.dispose();
  }
}
