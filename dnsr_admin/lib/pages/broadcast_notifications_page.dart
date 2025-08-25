import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../services/broadcast_notification_service.dart';

class BroadcastNotificationsPage extends StatefulWidget {
  const BroadcastNotificationsPage({super.key});

  @override
  State<BroadcastNotificationsPage> createState() => _BroadcastNotificationsPageState();
}

class _BroadcastNotificationsPageState extends State<BroadcastNotificationsPage> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  String? _lastResult;

  final List<Map<String, String>> _predefinedMessages = [
    {
      'title': '🚦 Respectez le code de la route',
      'message': 'Rappelez-vous de toujours respecter les panneaux de signalisation et les limitations de vitesse pour votre sécurité et celle des autres.',
    },
    {
      'title': '⚡ Prudence sur la route',
      'message': 'Conduisez prudemment et gardez vos distances de sécurité. Votre vigilance peut sauver des vies.',
    },
    {
      'title': '📱 Évitez les distractions',
      'message': 'Ne utilisez pas votre téléphone en conduisant. Votre attention doit être entièrement focalisée sur la route.',
    },
    {
      'title': '🌧️ Adaptez votre conduite',
      'message': 'Par temps de pluie ou conditions difficiles, réduisez votre vitesse et augmentez les distances de sécurité.',
    },
    {
      'title': '🛣️ Respectez les autres usagers',
      'message': 'Piétons, cyclistes, motards : partageons la route dans le respect mutuel et la courtoisie.',
    },
    {
      'title': '⛽ Vérifiez votre véhicule',
      'message': 'Un véhicule bien entretenu est un véhicule sûr. Pensez à vérifier régulièrement vos pneus, freins et éclairages.',
    },
    {
      'title': '🚨 En cas d\'urgence',
      'message': 'Si vous êtes témoin d\'un accident, appelez immédiatement les secours et signalez l\'incident via l\'application.',
    },
    {
      'title': '🎯 Conduite défensive',
      'message': 'Anticipez les réactions des autres conducteurs et restez toujours prêt à réagir face aux imprévus.',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminAuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(
                    Icons.campaign,
                    size: 32,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications de sensibilisation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Envoyez des conseils de conduite à tous les utilisateurs',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Message composer
                    Expanded(
                      flex: 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Composer un message',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Title field
                              TextField(
                                controller: _titleController,
                                onChanged: (value) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Titre de la notification',
                                  hintText: 'Ex: Respectez le code de la route',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.title),
                                ),
                                maxLength: 100,
                              ),
                              const SizedBox(height: 16),

                              // Message field
                              TextField(
                                controller: _messageController,
                                onChanged: (value) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Message',
                                  hintText: 'Votre conseil de conduite...',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.message),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: 4,
                                maxLength: 500,
                              ),
                              const SizedBox(height: 24),

                              // Send button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isSending || 
                                           _titleController.text.isEmpty || 
                                           _messageController.text.isEmpty
                                      ? null
                                      : _sendBroadcastNotification,
                                  icon: _isSending
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.send),
                                  label: Text(_isSending 
                                      ? 'Envoi en cours...' 
                                      : 'Envoyer à tous les utilisateurs'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),

                              // Result display
                              if (_lastResult != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _lastResult!.contains('succès') 
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: _lastResult!.contains('succès') 
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _lastResult!,
                                    style: TextStyle(
                                      color: _lastResult!.contains('succès') 
                                          ? Colors.green[800]
                                          : Colors.orange[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Right column: Predefined messages
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Messages prédéfinis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Cliquez sur un message pour l\'utiliser',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 16),

                              Expanded(
                                child: ListView.builder(
                                  itemCount: _predefinedMessages.length,
                                  itemBuilder: (context, index) {
                                    final message = _predefinedMessages[index];
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        onTap: () => _selectPredefinedMessage(message),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message['title']!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                message['message']!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectPredefinedMessage(Map<String, String> message) {
    setState(() {
      _titleController.text = message['title']!;
      _messageController.text = message['message']!;
    });
  }

  Future<void> _sendBroadcastNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      return;
    }

    setState(() {
      _isSending = true;
      _lastResult = null;
    });

    try {
      final result = await BroadcastNotificationService.sendToAllUsers(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
      );

      setState(() {
        if (result.successCount > 0) {
          _lastResult = '✅ Notification envoyée avec succès à ${result.successCount} utilisateur(s)';
          if (result.hasFailures) {
            _lastResult = '${_lastResult!} (${result.failureCount} échec(s))';
          }
          // Clear form after successful send
          _titleController.clear();
          _messageController.clear();
        } else {
          _lastResult = '⚠️ Aucune notification n\'a pu être envoyée. Vérifiez que des utilisateurs ont des tokens FCM valides.';
        }
      });
    } catch (e) {
      setState(() {
        _lastResult = '❌ Erreur lors de l\'envoi: $e';
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
}
