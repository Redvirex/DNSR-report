import 'package:flutter/material.dart';
import 'package:flutter_auth_app/pages/new_edit_profile_page.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/shared_bottom_nav_bar.dart';
import '../services/language_service.dart';
import '../l10n/app_localizations.dart';

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({super.key});

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {
  bool _isLoggingOut = false;

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.logout),
          content: Text(AppLocalizations.of(context)!.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.logout, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      // Show success message briefly before navigation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.loggedOutSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // Show error message if logout fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.logoutFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Consumer<LanguageService>(
            builder: (context, languageService, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: LanguageService.supportedLocales.map((locale) {
                  String flagEmoji;
                  String displayName;
                  
                  switch (locale.languageCode) {
                    case 'en':
                      flagEmoji = '🇺🇸';
                      displayName = 'English';
                      break;
                    case 'fr':
                      flagEmoji = '🇫🇷';
                      displayName = 'Français';
                      break;
                    case 'ar':
                      flagEmoji = '🇩🇿';
                      displayName = 'العربية';
                      break;
                    default:
                      flagEmoji = '🌐';
                      displayName = locale.languageCode;
                  }
                  
                  final isSelected = languageService.currentLocale.languageCode == locale.languageCode;
                  
                  return ListTile(
                    leading: Text(flagEmoji, style: const TextStyle(fontSize: 24)),
                    title: Text(displayName),
                    trailing: isSelected 
                        ? const Icon(Icons.check, color: Color(0xFFD4A017))
                        : null,
                    onTap: () {
                      languageService.changeLanguage(locale);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFD4A017);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ===== Header Section =====
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      AppLocalizations.of(context)!.profile,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ===== White Rounded Container =====
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ===== White Rounded Container =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          80,
                          20,
                          20,
                        ), // <-- espace haut pour l'image
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9F8ED),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ===== Name =====
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                final userProfile = authProvider.userProfile;
                                final displayName = userProfile != null
                                    ? '${userProfile.prenom ?? ''} ${userProfile.nom ?? ''}'
                                          .trim()
                                    : 'User';
                                return Text(
                                  displayName.isNotEmpty ? displayName : 'User',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                );
                              },
                            ),

                            // ===== Profile Completion Indicator =====
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                final userProfile = authProvider.userProfile;
                                final isProfileComplete =
                                    userProfile?.isProfileComplete ?? false;

                                if (!isProfileComplete) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      top: 15,
                                      bottom: 25,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange.withValues(
                                          alpha: 0.3,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange[700],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!.completeProfileMessage,
                                            style: TextStyle(
                                              color: Colors.orange[700],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox(height: 40);
                              },
                            ),

                            // ===== Buttons Column =====
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // ===== Edit Profile Button =====
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      12,
                                      12,
                                      12,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: ElevatedButton(
                                      style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.transparent,
                                        ),
                                        elevation: WidgetStatePropertyAll(0),
                                      ),
                                      onPressed: () => {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NewEditProfilePage(),
                                          ),
                                        ),
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: bgColor,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(15),
                                              ),
                                            ),
                                            child: Image.asset(
                                              'assets/images/Profile_.png',
                                              color: Colors.white,
                                              width: 40,
                                              height: 40,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              AppLocalizations.of(context)!.editProfile,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ===== Language Button =====
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      12,
                                      12,
                                      12,
                                    ),
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Consumer<LanguageService>(
                                      builder: (context, languageService, child) {
                                        String currentFlag;
                                        String currentName;
                                        
                                        switch (languageService.currentLocale.languageCode) {
                                          case 'en':
                                            currentFlag = '🇺🇸';
                                            currentName = 'English';
                                            break;
                                          case 'fr':
                                            currentFlag = '🇫🇷';
                                            currentName = 'Français';
                                            break;
                                          case 'ar':
                                            currentFlag = '🇩🇿';
                                            currentName = 'العربية';
                                            break;
                                          default:
                                            currentFlag = '🌐';
                                            currentName = AppLocalizations.of(context)!.language;
                                        }
                                        
                                        return ElevatedButton(
                                          style: const ButtonStyle(
                                            backgroundColor: WidgetStatePropertyAll(
                                              Colors.transparent,
                                            ),
                                            elevation: WidgetStatePropertyAll(0),
                                          ),
                                          onPressed: () => _showLanguageDialog(context),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(
                                                  color: bgColor,
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(15),
                                                  ),
                                                ),
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    currentFlag,
                                                    style: const TextStyle(fontSize: 24),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  currentName,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  // ===== Logout Button =====
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      0,
                                      12,
                                      12,
                                      12,
                                    ),
                                    child: ElevatedButton(
                                      style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.transparent,
                                        ),
                                        elevation: WidgetStatePropertyAll(0),
                                      ),
                                      onPressed: _isLoggingOut
                                          ? null
                                          : () => _showLogoutConfirmation(
                                              context,
                                            ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: _isLoggingOut
                                                  ? Colors.grey.withValues(
                                                      alpha: 0.3,
                                                    )
                                                  : bgColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(15),
                                                  ),
                                            ),
                                            child: _isLoggingOut
                                                ? const SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: Padding(
                                                      padding: EdgeInsets.all(
                                                        10,
                                                      ),
                                                      child:
                                                          CircularProgressIndicator(
                                                            color: Colors.white,
                                                            strokeWidth: 2,
                                                          ),
                                                    ),
                                                  )
                                                : Image.asset(
                                                    'assets/images/logout.png',
                                                    color: Colors.white,
                                                    width: 40,
                                                    height: 40,
                                                  ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _isLoggingOut
                                                  ? AppLocalizations.of(context)!.loggingOut
                                                  : AppLocalizations.of(context)!.logout,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _isLoggingOut
                                                    ? Colors.grey
                                                    : Colors.black,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -50, // moitié de la hauteur du CircleAvatar
                        left: 0,
                        right: 0,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: const DecorationImage(
                              image: AssetImage("assets/images/profile.png"),
                              fit: BoxFit
                                  .contain, // This ensures the image covers the entire circle
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width:
                                  3, // Optional: adds a white border around the profile image
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Floating navigation bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: const SharedBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }
}
