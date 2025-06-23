import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showStatus;

  const TaskCard({super.key, required this.task, this.onTap, this.onLongPress, this.showStatus = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(task.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  if (showStatus) _buildStatusChip(),
                  if (task.isDailyRecurring) const Icon(Icons.repeat, size: 16, color: Colors.blue),
                ],
              ),

              if (task.details != null) ...[
                const SizedBox(height: 8),
                Text(
                  task.details!,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatCreationTime(),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),

                  if (task.completionTimestamp != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      task.status == TaskStatus.completed ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: task.status == TaskStatus.completed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCompletionTime(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: task.status == TaskStatus.completed ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),

              if (onLongPress != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Tap to start • Long press for options',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha((0.7 * 255).round()),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (task.status) {
      case TaskStatus.completed:
        chipColor = Colors.green;
        statusText = 'Completed';
        break;
      case TaskStatus.cancelled:
        chipColor = Colors.red;
        statusText = 'Cancelled';
        break;
      case TaskStatus.active:
        chipColor = Colors.blue;
        statusText = 'Active';
        break;
      case TaskStatus.paused:
        chipColor = Colors.orange;
        statusText = 'Paused';
        break;
      case TaskStatus.backlog:
        chipColor = Colors.grey;
        statusText = 'Backlog';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withAlpha((0.3 * 255).round())),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatCreationTime() {
    final now = DateTime.now();
    final difference = now.difference(task.creationTimestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatCompletionTime() {
    if (task.completionTimestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(task.completionTimestamp!);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
