import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class DeleteAccountConfirmationPage extends StatefulWidget {
  const DeleteAccountConfirmationPage({super.key});

  @override
  State<DeleteAccountConfirmationPage> createState() => _DeleteAccountConfirmationPageState();
}

class _DeleteAccountConfirmationPageState extends State<DeleteAccountConfirmationPage> {
  bool _isDeleting = false;

  Future<void> _confirmDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Final Confirmation'),
          content: const Text(
            'This is your final chance to cancel.\n\n'
            'Are you absolutely sure you want to permanently delete your account?\n\n'
            'This action cannot be undone and will remove all your data.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Yes, Delete My Account',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isDeleting = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.deleteAccount();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been permanently deleted'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigation will be handled by the auth state change
        } else {
          setState(() {
            _isDeleting = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to delete account'),
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
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Stack(
                children: [
                  // Centered Text
                  const Center(
                    child: Text(
                      "Delete Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Back button
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      onPressed: _isDeleting 
                          ? null 
                          : () => Navigator.of(context).pop(),
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

            // White Rounded Container
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9F8ED),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Warning Icon
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 80,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 30),

                    // Title
                    const Text(
                      'Account Deletion Verification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        final userProfile = authProvider.userProfile;
                        final email = userProfile?.email ?? 'your email';
                        
                        return Text(
                          'You\'ve accessed this page through the magic link sent to $email.\n\n'
                          'By proceeding, you will permanently delete your account and all associated data. This action cannot be undone.\n\n'
                          'Are you sure you want to continue?',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Action Buttons
                    if (_isDeleting) ...[
                      const SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4A017),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Deleting your account...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ] else ...[
                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFFD4A017)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel - Keep My Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4A017),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Delete Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _confirmDeletion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Yes, Delete My Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
