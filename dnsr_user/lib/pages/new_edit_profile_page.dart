import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class NewEditProfilePage extends StatefulWidget {
  const NewEditProfilePage({super.key});

  @override
  State<NewEditProfilePage> createState() => _NewEditProfilePageState();
}

class _NewEditProfilePageState extends State<NewEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.userProfile;

      if (userProfile != null) {
        _fullNameController.text =
            '${userProfile.prenom ?? ''} ${userProfile.nom ?? ''}'.trim();
        _emailController.text = userProfile.email;
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fullName = _fullNameController.text.trim().split(' ');
      final prenom = fullName.isNotEmpty ? fullName.first : '';
      final nom = fullName.length > 1 ? fullName.skip(1).join(' ') : '';

      final success = await authProvider.updateProfile(
        prenom: prenom,
        nom: nom,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.profileUpdateFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteAccount),
          content: Text(
            AppLocalizations.of(context)!.deleteAccountConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                AppLocalizations.of(context)!.sendVerificationEmail,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendDeleteAccountMagicLink();

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.verificationEmailSent,
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ??
                    AppLocalizations.of(context)!.failedToSendVerificationEmail,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFD4A017);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // ===== Header Section =====
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                    child: Stack(
                      children: [
                        // === Centered Text ===
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.editMyProfile,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // === Icon at Top Right ===
                        Positioned(
                          top: 0,
                          left: 0,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
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
                          padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9F8ED),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ===== Name =====
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  final userProfile = authProvider.userProfile;
                                  final displayName = userProfile != null
                                      ? '${userProfile.prenom ?? ''} ${userProfile.nom ?? ''}'
                                            .trim()
                                      : '';
                                  return Center(
                                    child: Text(
                                      displayName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 40),
                              Text(
                                AppLocalizations.of(context)!.accountSettings,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 30),
                              // ===== Form Fields =====
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Full Name Field
                                      Text(
                                        AppLocalizations.of(context)!.fullName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4A017,
                                          ).withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: TextFormField(
                                          style: const TextStyle(fontSize: 14),
                                          textDirection: TextDirection.ltr,
                                          controller: _fullNameController,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 26,
                                                ),
                                            hintText:
                                                AppLocalizations.of(context)!.firstNameLastName,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return AppLocalizations.of(context)!.pleaseEnterFullName;
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Email Field
                                      Text(
                                        AppLocalizations.of(context)!.emailAddress,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4A017,
                                          ).withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: TextFormField(
                                          enabled: false,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textDirection: TextDirection.ltr,
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 26,
                                                  vertical: 12,
                                                ),
                                            hintText:
                                                AppLocalizations.of(context)!.enterEmailAddress,
                                          ),
                                          validator: null,
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      // Delete Account Option
                                      GestureDetector(
                                        onTap: _isLoading
                                            ? null
                                            : _deleteAccount,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                            horizontal: 20,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: _isLoading
                                                    ? Colors.grey.withValues(
                                                        alpha: 0.3,
                                                      )
                                                    : bgColor,
                                                child: _isLoading
                                                    ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .person_remove_outlined,
                                                        color: Colors.black87,
                                                        size: 24,
                                                      ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                _isLoading
                                                    ? AppLocalizations.of(context)!.sendingVerification
                                                    : AppLocalizations.of(context)!.deleteAccount,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: _isLoading
                                                      ? Colors.grey
                                                      : Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                color: _isLoading
                                                    ? Colors.grey
                                                    : Colors.black87,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      // Update Profile Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _updateProfile,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFD4A017,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Text(
                                                  AppLocalizations.of(context)!.updateProfile,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),

                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ===== Profile Picture =====
                        Positioned(
                          top: -50,
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
            ),
          ),
        ],
      ),
    );
  }
}
