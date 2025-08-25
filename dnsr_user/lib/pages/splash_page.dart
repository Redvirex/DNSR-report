import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/deep_link_handler.dart';
import 'auth_page.dart';
import 'main_navigation_wrapper.dart';
import 'delete_account_confirmation_page.dart';
import 'dart:developer';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasCheckedDeepLink = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialLink();
    });
  }

  void _handleInitialLink() async {
    if (_hasCheckedDeepLink) return;
    _hasCheckedDeepLink = true;

    try {
      // Check if the app was opened via a deep link
      final uri = Uri.base;
      log('Current URI: $uri');
      
      // Use the deep link handler to process the incoming link
      final action = DeepLinkHandler.instance.handleIncomingLink(uri);
      
      if (action == 'delete-account') {
        log('Delete account deep link detected');
        
        // Wait a moment for auth to initialize
        await Future.delayed(const Duration(milliseconds: 1000));
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const DeleteAccountConfirmationPage(),
            ),
          );
        }
      }
    } catch (e) {
      log('Error handling deep link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.status == AuthStatus.unknown) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        }

        switch (authProvider.status) {
          case AuthStatus.unauthenticated:
            return const AuthPage();
          case AuthStatus.profileIncomplete:
            return const MainNavigationWrapper();
          case AuthStatus.authenticated:
            final userProfile = authProvider.userProfile;
            if (userProfile != null && userProfile.isProfileComplete) {
              return const MainNavigationWrapper();
            } else {
              return const MainNavigationWrapper();
            }
          default:
            return const AuthPage();
        }
      },
    );
  }
}
