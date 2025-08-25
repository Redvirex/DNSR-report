import 'package:flutter/material.dart';
import '../models/incident.dart';

class IncidentStatsCards extends StatelessWidget {
  final List<Incident> incidents;
  final bool isLoading;

  const IncidentStatsCards({
    super.key,
    required this.incidents,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Row(
        children: [
          Expanded(child: _LoadingCard()),
          SizedBox(width: 16),
          Expanded(child: _LoadingCard()),
          SizedBox(width: 16),
          Expanded(child: _LoadingCard()),
          SizedBox(width: 16),
          Expanded(child: _LoadingCard()),
          SizedBox(width: 16),
          Expanded(child: _LoadingCard()),
        ],
      );
    }

    // Calculate time-based statistics
    final stats = _calculateStats();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Incidents',
            value: stats['total'].toString(),
            icon: Icons.report,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Today',
            value: stats['today'].toString(),
            icon: Icons.today,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'This Week',
            value: stats['week'].toString(),
            icon: Icons.date_range,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'This Month',
            value: stats['month'].toString(),
            icon: Icons.calendar_month,
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Pending Review',
            value: stats['pending'].toString(),
            icon: Icons.pending_actions,
            color: Colors.amber,
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeek = now.subtract(const Duration(days: 7));
    final thisMonth = DateTime(now.year, now.month, 1);

    final stats = {
      'total': incidents.length,
      'today': 0,
      'week': 0,
      'month': 0,
      'pending': 0,
    };

    for (final incident in incidents) {
      // Today's incidents
      if (incident.createdAt.isAfter(today)) {
        stats['today'] = stats['today']! + 1;
      }
      
      // This week's incidents
      if (incident.createdAt.isAfter(thisWeek)) {
        stats['week'] = stats['week']! + 1;
      }
      
      // This month's incidents
      if (incident.createdAt.isAfter(thisMonth)) {
        stats['month'] = stats['month']! + 1;
      }

      // Pending incidents (EN_ATTENTE status)
      if (incident.statut == IncidentStatut.EN_ATTENTE) {
        stats['pending'] = stats['pending']! + 1;
      }
    }

    return stats;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 40,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
