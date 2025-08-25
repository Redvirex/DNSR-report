import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback? onPermissionGranted;
  final VoidCallback? onPermissionDenied;

  const LocationPermissionDialog({
    super.key,
    this.onPermissionGranted,
    this.onPermissionDenied,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.location_on, color: Colors.blue, size: 48),
      title: const Text(
        'Partager votre position',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Cette application a besoin d'accéder à votre position pour vous aider à signaler des incidents routiers plus précisément.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.security, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vos données de localisation sont sécurisées et utilisées uniquement pour améliorer le service.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPermissionDenied?.call();
          },
          child: Text(AppLocalizations.of(context)!.later),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            final locationService = LocationService.instance;
            final status = await locationService.requestLocationPermission();

            if (status == LocationPermissionStatus.granted) {
              onPermissionGranted?.call();
            } else {
              onPermissionDenied?.call();

              if (status == LocationPermissionStatus.deniedForever &&
                  context.mounted) {
                _showSettingsDialog(context);
              }
            }
          },
          child: Text(AppLocalizations.of(context)!.allow),
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.permissionRequired),
        content: const Text(
          "Pour partager votre position, veuillez activer la permission de localisation dans les paramètres de l'application.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await LocationService.instance.openAppSettings();
            },
            child: Text(AppLocalizations.of(context)!.settings),
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onPermissionGranted,
    VoidCallback? onPermissionDenied,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onPermissionGranted: onPermissionGranted,
        onPermissionDenied: onPermissionDenied,
      ),
    );
  }
}
