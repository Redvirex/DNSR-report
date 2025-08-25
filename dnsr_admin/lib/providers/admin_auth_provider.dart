import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

enum AdminAuthStatus { unknown, unauthenticated, authenticated, notAdmin }

class AdminAuthProvider extends ChangeNotifier {
  final AdminSupabaseService _supabaseService = AdminSupabaseService.instance;

  AdminAuthStatus _status = AdminAuthStatus.unknown;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AdminAuthStatus get status => _status;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AdminAuthStatus.authenticated;
  bool get isAdmin => _userProfile?.isAdmin ?? false;

  AdminAuthProvider() {
    _initialize();
  }

  void _initialize() {
    // Listen to auth state changes
    _supabaseService.authStateChanges.listen((AuthState data) {
      _handleAuthStateChange(data);
    });

    // Check initial auth state
    final session = _supabaseService.currentUser;
    if (session != null) {
      _loadUserProfile(session.id);
    } else {
      _status = AdminAuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  void _handleAuthStateChange(AuthState data) async {
    developer.log('Auth state changed - session: ${data.session != null}', name: 'AdminAuthProvider');
    if (data.session != null) {
      await _loadUserProfile(data.session!.user.id);
    } else {
      _status = AdminAuthStatus.unauthenticated;
      _userProfile = null;
      developer.log('User signed out', name: 'AdminAuthProvider');
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      developer.log('Loading user profile for userId: $userId', name: 'AdminAuthProvider');
      final profile = await _supabaseService.getUserProfile(userId);

      if (profile != null) {
        if (kDebugMode) {
          developer.log('Profile loaded - role: ${profile.role}, status: ${profile.status}', name: 'AdminAuthProvider');
        }
        _userProfile = profile;
        // Check if user is admin and active
        if (profile.isAdmin && profile.status == StatutUtilisateur.ACTIVE) {
          _status = AdminAuthStatus.authenticated;
          if (kDebugMode) {
            developer.log('User authenticated as active admin', name: 'AdminAuthProvider');
          }
          _errorMessage = null; // Clear any previous errors
        } else if (!profile.isAdmin) {
          _status = AdminAuthStatus.notAdmin;
          _errorMessage = 'Access denied: Admin privileges required';
          developer.log('User is not admin - role: ${profile.role}', name: 'AdminAuthProvider');
        } else if (profile.status != StatutUtilisateur.ACTIVE) {
          _status = AdminAuthStatus.notAdmin;
          _errorMessage = 'Account is deactivated. Please contact support.';
          developer.log('User account is not active - status: ${profile.status}', name: 'AdminAuthProvider');
        }
      } else {
        developer.log('No profile found for user', name: 'AdminAuthProvider');
        _status = AdminAuthStatus.unauthenticated;
        _errorMessage = 'User profile not found in system';
      }
    } catch (e) {
      developer.log('Error loading user profile: $e', name: 'AdminAuthProvider', error: e);
      _errorMessage = 'Failed to load user profile: ${e.toString()}';
      _status = AdminAuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      developer.log('Starting login for email: $email', name: 'AdminAuthProvider');
      
      await _supabaseService.signInWithEmailPassword(
        email,
        password,
      );

      if (kDebugMode) {
        developer.log('Login successful, waiting for auth state change', name: 'AdminAuthProvider');
      }
      // Profile will be loaded automatically via auth state change
      return true;
    } catch (e) {
      developer.log('Login failed with error: $e', name: 'AdminAuthProvider', error: e);
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

      await _supabaseService.signOut();

      _status = AdminAuthStatus.unauthenticated;
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
}
