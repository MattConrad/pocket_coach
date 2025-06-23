import 'package:flutter/material.dart';

class StatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalTasks = statistics['totalTasks'] as int;
    final completedTasks = statistics['completedTasks'] as int;
    final cancelledTasks = statistics['cancelledTasks'] as int;
    final successRate = statistics['successRate'] as double;
    final currentStreak = statistics['currentStreak'] as int;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Success Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Success Rate', style: theme.textTheme.titleMedium),
                Text(
                  '${(successRate * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: successRate >= 0.7 ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar
            LinearProgressIndicator(
              value: successRate,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(successRate >= 0.7 ? Colors.green : Colors.orange),
            ),

            const SizedBox(height: 20),

            // Statistics grid
            Row(
              children: [
                Expanded(child: _buildStatItem('Total Tasks', totalTasks.toString(), Icons.task_alt, Colors.blue)),
                Expanded(
                  child: _buildStatItem('Completed', completedTasks.toString(), Icons.check_circle, Colors.green),
                ),
                Expanded(child: _buildStatItem('Cancelled', cancelledTasks.toString(), Icons.cancel, Colors.red)),
              ],
            ),

            const SizedBox(height: 16),

            // Current streak
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentStreak > 0
                    ? Colors.orange.withAlpha((0.1 * 255).round())
                    : Colors.grey.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: currentStreak > 0
                      ? Colors.orange.withAlpha((0.3 * 255).round())
                      : Colors.grey.withAlpha((0.3 * 255).round()),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.local_fire_department, color: currentStreak > 0 ? Colors.orange : Colors.grey, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Current Streak',
                    style: theme.textTheme.bodyMedium?.copyWith(color: currentStreak > 0 ? Colors.orange : Colors.grey),
                  ),
                  Text(
                    '$currentStreak',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: currentStreak > 0 ? Colors.orange : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentStreak == 1 ? 'task' : 'tasks',
                    style: theme.textTheme.bodySmall?.copyWith(color: currentStreak > 0 ? Colors.orange : Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }
}
