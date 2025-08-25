import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/twilio_service.dart';
import '../l10n/app_localizations.dart';

class NewEditProfilePage extends StatefulWidget {
  const NewEditProfilePage({super.key});

  @override
  State<NewEditProfilePage> createState() => _NewEditProfilePageState();
}

class _NewEditProfilePageState extends State<NewEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController =
      TextEditingController(); // Will hold only the digits after +213
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // Phone verification states
  bool _showPhoneVerification = false;
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _originalPhoneNumber;
  bool _otpSent = false;
  Timer? _timer;
  int _timerSeconds = 60;
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.userProfile;

      if (userProfile != null) {
        _fullNameController.text =
            '${userProfile.prenom ?? ''} ${userProfile.nom ?? ''}'.trim();

        // Store original phone number and extract digits for the editable field
        _originalPhoneNumber = userProfile.numeroTelephone;
        String phoneNumber = userProfile.numeroTelephone ?? '';
        if (phoneNumber.startsWith('+213')) {
          _phoneController.text = phoneNumber.substring(
            4,
          ); // Remove +213 prefix
        } else if (phoneNumber.startsWith('213')) {
          _phoneController.text = phoneNumber.substring(3); // Remove 213 prefix
        } else {
          _phoneController.text = phoneNumber; // Use as is if no prefix
        }

        // If user has existing phone number, consider it verified
        if (phoneNumber.isNotEmpty) {
          _isVerified = true;
        }

        _emailController.text = userProfile.email;
      }

      // Add listener to detect phone number changes
      _phoneController.addListener(_checkPhoneNumberChange);

      // Add listener for OTP field changes
      _otpController.addListener(() {
        setState(() {}); // Rebuild to enable/disable verify button
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _checkPhoneNumberChange() {
    if (_originalPhoneNumber != null) {
      String phoneDigits = _phoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      String currentFormattedPhone = phoneDigits.isNotEmpty
          ? '+213$phoneDigits'
          : '';

      bool phoneChanged = _originalPhoneNumber != currentFormattedPhone;

      if (mounted) {
        setState(() {
          if (phoneChanged) {
            _isVerified = false;
          } else {
            _isVerified = true;
          }
        });
      }
    }
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isVerifying = true;
    });

    String phoneDigits = _phoneController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    String formattedPhone = '+213$phoneDigits';

    final success = await TwilioService.instance.sendOTP(formattedPhone);

    setState(() {
      _isVerifying = false;
    });

    if (success) {
      _startOTPTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.otpSentSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToSendOTP),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startOTPTimer() {
    _timer?.cancel();
    _otpSent = true;
    _timerSeconds = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        if (mounted) setState(() {});
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _otpSent = false;
          });
        }
      }
    });
  }

  Future<void> _verifyOTP() async {
    String phoneDigits = _phoneController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    String formattedPhone = '+213$phoneDigits';

    final isValid = await TwilioService.instance.verifyOTP(
      formattedPhone,
      _otpController.text,
    );

    if (isValid) {
      setState(() {
        _isVerified = true;
        _showPhoneVerification = false;
        _otpSent = false;
      });
      _timer?.cancel();
      _otpController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.phoneVerifiedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        // Automatically update profile after successful OTP verification
        await _updateProfileAfterVerification();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.invalidOTP),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfileAfterVerification() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fullName = _fullNameController.text.trim().split(' ');
      final prenom = fullName.isNotEmpty ? fullName.first : '';
      final nom = fullName.length > 1 ? fullName.skip(1).join(' ') : '';

      String phoneDigits = _phoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      String formattedPhone = phoneDigits.isNotEmpty ? '+213$phoneDigits' : '';

      // Validate that we have phone digits
      if (phoneDigits.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseEnterValidPhoneNumber),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // First update the basic profile information
      final profileUpdateSuccess = await authProvider.updateProfile(
        prenom: prenom,
        nom: nom,
        numeroTelephone: formattedPhone,
      );

      if (profileUpdateSuccess) {
        // Then complete phone verification which will activate user if profile is complete
        final verificationSuccess = await authProvider
            .completePhoneVerification(phoneNumber: formattedPhone);

        setState(() {
          _isLoading = false;
        });

        if (mounted) {
        if (mounted) {
          if (verificationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.profileUpdatedAndVerified),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back to profile page after successful update
            Navigator.of(context).pop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context)!.profileUpdatedButVerificationFailed,
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
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

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Check if phone number has changed and needs verification
      String phoneDigits = _phoneController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      String formattedPhone = phoneDigits.isNotEmpty ? '+213$phoneDigits' : '';
      bool phoneChanged = _originalPhoneNumber != formattedPhone;

      if (phoneChanged && !_isVerified) {
        setState(() {
          _showPhoneVerification = true;
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fullName = _fullNameController.text.trim().split(' ');
      final prenom = fullName.isNotEmpty ? fullName.first : '';
      final nom = fullName.length > 1 ? fullName.skip(1).join(' ') : '';

      // Validate that we have phone digits
      if (phoneDigits.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.pleaseEnterValidPhoneNumber),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await authProvider.updateProfile(
        prenom: prenom,
        nom: nom,
        numeroTelephone: formattedPhone,
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

                                      // Phone Field
                                      Text(
                                        AppLocalizations.of(context)!.phone,
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
                                          ).withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Non-editable +213 prefix
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 26,
                                                    vertical: 12,
                                                  ),
                                              child: const Text(
                                                "+213",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            // Thin vertical divider
                                            Container(
                                              width: 1,
                                              height: 20,
                                              color: Colors.black26,
                                            ),
                                            // Editable phone number field
                                            Expanded(
                                              child: TextFormField(
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                textDirection:
                                                    TextDirection.ltr,
                                                controller: _phoneController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                decoration:
                                                    InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 12,
                                                          ),
                                                      hintText:
                                                          AppLocalizations.of(context)!.enterPhoneNumber,
                                                    ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return AppLocalizations.of(context)!.pleaseEnterPhoneNumber;
                                                  }

                                                  // Remove any non-digit characters
                                                  String digits = value
                                                      .replaceAll(
                                                        RegExp(r'[^0-9]'),
                                                        '',
                                                      );

                                                  // Check if we have exactly 9 digits and starts with 5, 6, or 7
                                                  final phoneRegex = RegExp(
                                                    r'^[5-7]\d{8}$',
                                                  );
                                                  if (!phoneRegex.hasMatch(
                                                    digits,
                                                  )) {
                                                    return AppLocalizations.of(context)!.pleaseEnterValidAlgerianPhone;
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
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

          // Phone verification floating widget
          _showPhoneVerification
              ? _buildPhoneVerificationWidget()
              : Container(),
        ],
      ),
    );
  }

  Widget _buildPhoneVerificationWidget() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.phoneVerificationRequired,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.phoneNumberChanged,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              if (!_otpSent) ...[
                // Send OTP button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context)!.sendOTP,
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ] else ...[
                // OTP input field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),

                // Verify OTP button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _otpController.text.length == 6
                        ? _verifyOTP
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.verifyOTP,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Resend OTP button
                TextButton(
                  onPressed: _timerSeconds == 0 ? _sendOTP : null,
                  child: Text(
                    _timerSeconds > 0
                        ? '${AppLocalizations.of(context)!.resendOTP} ($_timerSeconds s)'
                        : AppLocalizations.of(context)!.resendOTP,
                    style: TextStyle(
                      color: _timerSeconds > 0
                          ? Colors.grey
                          : const Color(0xFFD4A017),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Cancel button
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPhoneVerification = false;
                    _otpSent = false;
                  });
                  _timer?.cancel();
                  _otpController.clear();
                },
                child: Text(
                  AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
