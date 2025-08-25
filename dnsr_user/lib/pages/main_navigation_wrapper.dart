import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/navigation_controller.dart';
import '../providers/auth_provider.dart';
import '../pages/new_home_page.dart';
import '../pages/new_profile_page.dart';

/// Main navigation wrapper that handles page transitions
/// between home and profile pages with shared bottom navigation
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_hasInitialized) {
      // Use post frame callback to ensure the navigation happens after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeNavigation();
      });
      _hasInitialized = true;
    }
  }

  void _initializeNavigation() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navController = Provider.of<NavigationController>(context, listen: false);
    
    // Check user profile status to determine initial page
    if (authProvider.userProfile != null) {
      final isProfileComplete = authProvider.userProfile!.isProfileComplete;
      
      if (isProfileComplete) {
        // ACTIVE user - go to home page
        navController.goToHome();
      } else {
        // DEACTIVATED user - go to profile page to complete profile
        navController.jumpToProfile(); // Use jumpToProfile for instant navigation
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        return Scaffold(
          body: PageView(
            controller: navController.pageController,
            onPageChanged: (index) {
              navController.updateIndex(index);
            },
            children: const [
              NewHomePage(),
              NewProfilePage(),
            ],
          ),
        );
      },
    );
  }
}
