import 'dart:async';
import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeepLinkHandler {
  static DeepLinkHandler? _instance;
  static DeepLinkHandler get instance => _instance ??= DeepLinkHandler._();
  
  DeepLinkHandler._();
  
  StreamSubscription<AuthState>? _authSubscription;
  String? _pendingAction;
  
  void initialize() {
    // Listen to auth state changes to handle deep links after authentication
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        _handleAuthStateChange(data);
      },
    );
  }
  
  void _handleAuthStateChange(AuthState data) {
    if (data.session != null) {
      // User is authenticated, check for pending actions
      _checkForPendingActions();
    }
  }
  
  void _checkForPendingActions() {
    if (_pendingAction == 'delete-account') {
      log('Executing pending delete account action');
      _pendingAction = null;
      // This will be handled by the app's navigation logic
    }
  }
  
  String? handleIncomingLink(Uri uri) {
    log('Handling incoming link: $uri');
    
    // Check query parameters
    final action = uri.queryParameters['action'];
    if (action != null) {
      log('Found action parameter: $action');
      return action;
    }
    
    // Check path for delete-account
    if (uri.path.contains('delete-account')) {
      log('Found delete-account in path');
      return 'delete-account';
    }
    
    // Check fragment
    if (uri.fragment.contains('delete-account')) {
      log('Found delete-account in fragment');
      return 'delete-account';
    }
    
    return null;
  }
  
  void setPendingAction(String action) {
    _pendingAction = action;
    log('Set pending action: $action');
  }
  
  void dispose() {
    _authSubscription?.cancel();
  }
}
