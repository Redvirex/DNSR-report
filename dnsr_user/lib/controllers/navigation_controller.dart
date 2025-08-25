import 'package:flutter/material.dart';

/// Global navigation controller to manage bottom navigation state
/// and page transitions between home and profile pages
class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  late PageController _pageController;

  NavigationController() {
    _pageController = PageController(initialPage: _selectedIndex);
  }

  /// Current selected index (0 = Home, 1 = Profile)
  int get selectedIndex => _selectedIndex;

  /// Page controller for smooth transitions
  PageController get pageController => _pageController;

  /// Update selected index and animate to page
  void updateIndex(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  /// Navigate to home page
  void goToHome() {
    updateIndex(0);
  }

  /// Navigate to profile page
  void goToProfile() {
    updateIndex(1);
  }

  /// Jump to profile page instantly (without animation)
  void jumpToProfile() {
    _selectedIndex = 1;
    _pageController.jumpToPage(1);
    notifyListeners();
  }

  /// Jump to home page instantly (without animation)
  void jumpToHome() {
    _selectedIndex = 0;
    _pageController.jumpToPage(0);
    notifyListeners();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
