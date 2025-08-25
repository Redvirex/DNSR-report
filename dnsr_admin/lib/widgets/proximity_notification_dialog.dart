import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/notification_service.dart';
import '../services/fcm_service.dart';

class ProximityNotificationDialog extends StatefulWidget {
  final Incident incident;

  const ProximityNotificationDialog({super.key, required this.incident});

  @override
  State<ProximityNotificationDialog> createState() =>
      _ProximityNotificationDialogState();
}

class _ProximityNotificationDialogState
    extends State<ProximityNotificationDialog> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController(
    text: '2.0',
  );

  bool _isSending = false;
  bool _useCustomMessage = false;
  String? _selectedTemplate;
  List<String> _templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    _templates = NotificationService.instance.getMessageTemplates(
      widget.incident,
    );
    if (_templates.isNotEmpty) {
      _selectedTemplate = _templates.first;
      _messageController.text = _selectedTemplate!;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.notifications_active, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Envoyer notification de proximité',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Incident: #${widget.incident.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (widget.incident.description != null)
                      Text(
                        widget.incident.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      'Position: ${widget.incident.latitude.toStringAsFixed(4)}, ${widget.incident.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Radius selection
              Text(
                'Rayon de notification',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _radiusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Rayon (km)',
                        hintText: '2.0',
                        border: OutlineInputBorder(),
                        suffixText: 'km',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Max 5km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Message selection
              Text(
                'Message de notification',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // Template/Custom toggle
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Modèle prédéfini'),
                      value: false,
                      groupValue: _useCustomMessage,
                      onChanged: (value) {
                        setState(() {
                          _useCustomMessage = false;
                          if (_selectedTemplate != null) {
                            _messageController.text = _selectedTemplate!;
                          }
                        });
                      },
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Message personnalisé'),
                      value: true,
                      groupValue: _useCustomMessage,
                      onChanged: (value) {
                        setState(() {
                          _useCustomMessage = true;
                        });
                      },
                      dense: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (!_useCustomMessage) ...[
                // Template dropdown
                DropdownButtonFormField<String>(
                  value: _selectedTemplate,
                  decoration: const InputDecoration(
                    labelText: 'Choisir un modèle',
                    border: OutlineInputBorder(),
                  ),
                  items: _templates
                      .map(
                        (template) => DropdownMenuItem(
                          value: template,
                          child: Text(template),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTemplate = value;
                      _messageController.text = value ?? '';
                    });
                  },
                ),
              ] else ...[
                // Custom message input
                TextFormField(
                  controller: _messageController,
                  maxLines: 3,
                  maxLength: 160,
                  decoration: const InputDecoration(
                    labelText: 'Message personnalisé',
                    hintText: 'Entrez votre message...',
                    border: OutlineInputBorder(),
                    helperText:
                        'Le message sera accompagné d\'un lien Google Maps',
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Preview section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.preview,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Aperçu de la notification',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Incident à proximité',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _messageController.text.isEmpty
                          ? 'Aucun message'
                          : _messageController.text,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '📍 Voir sur Google Maps',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: _isSending || _messageController.text.isEmpty
              ? null
              : _sendNotifications,
          icon: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(_isSending ? 'Envoi...' : 'Envoyer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _sendNotifications() async {
    if (_messageController.text.isEmpty) {
      _showErrorSnackBar('Veuillez entrer un message');
      return;
    }

    final radius = double.tryParse(_radiusController.text);
    if (radius == null || radius <= 0 || radius > 5) {
      _showErrorSnackBar('Veuillez entrer un rayon valide (0.1 - 5.0 km)');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final result = await NotificationService.instance
          .sendProximityNotifications(
            incident: widget.incident,
            message: _messageController.text,
            radiusKm: radius,
          );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de l\'envoi: $e');
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

/// Dialog to show notification sending results
class NotificationResultDialog extends StatelessWidget {
  final NotificationResult result;
  final Incident incident;

  const NotificationResultDialog({
    super.key,
    required this.result,
    required this.incident,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasErrors = result.hasFailures;
    final Color primaryColor = hasErrors ? Colors.orange : Colors.green;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            hasErrors ? Icons.warning : Icons.check_circle,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            hasErrors
                ? 'Notifications envoyées avec erreurs'
                : 'Notifications envoyées',
            style: TextStyle(color: primaryColor),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${result.successCount} notifications envoyées',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        'Taux de réussite: ${(result.successRate * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (hasErrors) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${result.failureCount} notifications ont échoué',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Additional stats
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                'Durée: ${result.duration.inMilliseconds}ms',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const Spacer(),
              Icon(Icons.people, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${result.totalUsers} utilisateurs',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
