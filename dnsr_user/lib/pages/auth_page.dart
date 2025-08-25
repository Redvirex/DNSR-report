import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _linkSent = false;
  bool _isCheckingEmail = false;
  bool? _userExists;

  Timer? _resendCountdownTimer;
  int _resendCountdownSeconds = 0;

  final Color _goldColor = const Color(0xFFD4A017);

  @override
  void dispose() {
    _emailController.dispose();
    _resendCountdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkUserExists() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isCheckingEmail = true;
      _userExists = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final exists = await authProvider.checkUserExists(
      _emailController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isCheckingEmail = false;
        _userExists = exists;
      });
    }
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithMagicLink(
      _emailController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _linkSent = success;
      });

      if (success) {
        _startResendCountdown();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'Failed to send magic link',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    final success = await authProvider.signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Google sign-in failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _userExists = null;
      _linkSent = false;
    });
  }

  void _closeModal() {
    setState(() => _linkSent = false);
  }

  void _startResendCountdown() {
    setState(() {
      _resendCountdownSeconds = 60;
    });

    _resendCountdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _resendCountdownSeconds--;
      });

      if (_resendCountdownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  void _resendMagicLink() async {
    if (_resendCountdownSeconds > 0) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    _startResendCountdown();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithMagicLink(email);

    if (mounted) {
      if (!success) {
        _resendCountdownTimer?.cancel();
        setState(() {
          _resendCountdownSeconds = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec du renvoi du lien magique"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String get _buttonText {
    if (_userExists == null) return AppLocalizations.of(context)!.continueButton;
    if (_userExists == true) {
      return AppLocalizations.of(context)!.accountFound;
    }
    return AppLocalizations.of(context)!.newUser;
  }

  String get _modalMessage {
    if (_userExists == true) {
      return AppLocalizations.of(context)!.signInLinkSent;
    }
    return AppLocalizations.of(context)!.createAccountLinkSent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.welcome,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.bySigningIn,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              AppLocalizations.of(context)!.privacyStatement,
                              style: TextStyle(fontSize: 14, color: _goldColor),
                            ),
                          ),
                          Text(AppLocalizations.of(context)!.and),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              AppLocalizations.of(context)!.termsOfService,
                              style: TextStyle(fontSize: 14, color: _goldColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        enabled: !_isLoading && !_isCheckingEmail,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppLocalizations.of(context)!.pleaseEnterEmail;
                          }
                          if (!EmailValidator.validate(value)) {
                            return AppLocalizations.of(context)!.pleaseEnterValidEmail;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.yourEmailAddress,
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          if (_userExists != null) _resetForm();
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isCheckingEmail)
                              ? () {
                                  return;
                                }
                              : (_userExists == null
                                    ? _checkUserExists
                                    : _sendMagicLink),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _userExists == null
                                ? _goldColor
                                : Colors.white,
                            foregroundColor: _userExists == null
                                ? Colors.black
                                : _goldColor,
                            side: BorderSide(color: _goldColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: (_isLoading || _isCheckingEmail)
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  _buttonText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "ou",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: (_isLoading || _isCheckingEmail)
                              ? null
                              : _signInWithGoogle,
                          icon: Image.asset(
                            "assets/images/google_logo.png",
                            height: 20,
                          ),
                          label: Text(
                            AppLocalizations.of(context)!.continueWithGoogle,
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_linkSent)
            Positioned.fill(
              child: GestureDetector(
                onTap: _resendCountdownSeconds <= 0 ? _closeModal : null,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            size: 48,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.checkYourInbox,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _modalMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: _resendCountdownSeconds > 0
                                ? null
                                : _resendMagicLink,
                            child: Text(
                              _resendCountdownSeconds > 0
                                  ? "Re-send link (${_resendCountdownSeconds}s)"
                                  : AppLocalizations.of(context)!.resendLink,
                              style: TextStyle(
                                color: _resendCountdownSeconds > 0
                                    ? Colors.grey
                                    : _goldColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset("assets/images/dnsr_logo.png", height: 40),
            ),
          ),
        ],
      ),
    );
  }
}
