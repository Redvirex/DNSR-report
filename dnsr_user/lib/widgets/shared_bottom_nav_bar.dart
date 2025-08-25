import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/navigation_controller.dart';
import '../providers/auth_provider.dart';

/// Shared bottom navigation bar widget
/// Used consistently across home and profile pages
class SharedBottomNavBar extends StatelessWidget {
  const SharedBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFD4A017);
    
    return Consumer<NavigationController>(
      builder: (context, navController, child) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
            ),
            color: Color(0xfff7f6df),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Home Icon
                Container(
                  decoration: BoxDecoration(
                    color: navController.selectedIndex == 0
                        ? bgColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: () => navController.goToHome(),
                    icon: Image.asset(
                      'assets/images/home.png',
                      color: navController.selectedIndex == 0
                          ? Colors.white
                          : Colors.black,
                    ), 
                  ),
                ),

                const SizedBox(width: 20),

                // Profile Icon
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final isProfileComplete = authProvider.userProfile?.isProfileComplete ?? true;
                    
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: navController.selectedIndex == 1
                                ? bgColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            onPressed: () => navController.goToProfile(),
                            icon: Image.asset(
                              'assets/images/Profile_.png',
                              color: navController.selectedIndex == 1
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        // Profile incomplete indicator
                        if (!isProfileComplete)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.orange[600],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
