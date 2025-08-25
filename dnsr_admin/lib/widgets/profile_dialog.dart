import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/admin_auth_provider.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, authProvider, child) {
        final userProfile = authProvider.userProfile;
        
        if (userProfile == null) {
          return const AlertDialog(
            title: Text('Erreur'),
            content: Text('Impossible de charger les informations du profil'),
          );
        }

        return Dialog(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    // Large avatar
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      radius: 30,
                      child: Text(
                        userProfile.fullName.isNotEmpty
                            ? userProfile.fullName[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Profile info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Administrateur',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(userProfile.role).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getRoleColor(userProfile.role)),
                            ),
                            child: Text(
                              _getRoleLabel(userProfile.role),
                              style: TextStyle(
                                color: _getRoleColor(userProfile.role),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Close button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 20),

                // Profile details
                _buildProfileSection(
                  'Informations personnelles',
                  Icons.person,
                  [
                    _buildInfoRow('Nom complet', userProfile.fullName),
                    _buildInfoRow('Email', userProfile.email),
                    if (userProfile.numeroTelephone?.isNotEmpty == true)
                      _buildInfoRow('Téléphone', userProfile.numeroTelephone!),
                  ],
                ),

                const SizedBox(height: 20),

                _buildProfileSection(
                  'Informations du compte',
                  Icons.admin_panel_settings,
                  [
                    _buildInfoRow('Rôle', _getRoleLabel(userProfile.role)),
                    _buildInfoRow('Statut', _getStatusLabel(userProfile.status)),
                    if (userProfile.createdAt != null)
                      _buildInfoRow('Membre depuis', _formatDate(userProfile.createdAt!)),
                    if (userProfile.updatedAt != null)
                      _buildInfoRow('Dernière mise à jour', _formatDate(userProfile.updatedAt!)),
                  ],
                ),

                const SizedBox(height: 24),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(RoleUtilisateur role) {
    switch (role) {
      case RoleUtilisateur.ADMIN:
        return 'Administrateur';
      case RoleUtilisateur.CITOYEN:
        return 'Citoyen';
    }
  }

  Color _getRoleColor(RoleUtilisateur role) {
    switch (role) {
      case RoleUtilisateur.ADMIN:
        return Colors.blue;
      case RoleUtilisateur.CITOYEN:
        return Colors.green;
    }
  }

  String _getStatusLabel(StatutUtilisateur status) {
    switch (status) {
      case StatutUtilisateur.ACTIVE:
        return 'Actif';
      case StatutUtilisateur.DEACTIVATED:
        return 'Désactivé';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
