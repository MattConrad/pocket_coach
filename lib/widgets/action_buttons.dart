import 'package:flutter/material.dart';
import '../models/task.dart';
import '../providers/app_state_provider.dart';

class ActionButtons extends StatelessWidget {
  final AppState appState;
  final Task? activeTask;
  final VoidCallback? onPepTalk;
  final VoidCallback? onReturnToTask;
  final VoidCallback? onTaskComplete;
  final VoidCallback? onTaskCancel;
  final VoidCallback? onNeedMoreTime;
  final VoidCallback? onPause;

  const ActionButtons({
    super.key,
    required this.appState,
    this.activeTask,
    this.onPepTalk,
    this.onReturnToTask,
    this.onTaskComplete,
    this.onTaskCancel,
    this.onNeedMoreTime,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // State-specific action buttons
          if (appState == AppState.general) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPepTalk,
                icon: const Icon(Icons.psychology),
                label: const Text('Get a Pep Talk'),
              ),
            ),
          ],
          
          if (appState == AppState.activeTask) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPepTalk,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Pep Talk'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPause,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                ),
              ],
            ),
          ],
          
          if (appState == AppState.pepTalk && activeTask != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onReturnToTask,
                icon: const Icon(Icons.arrow_back),
                label: Text('Return to: ${activeTask!.title}'),
              ),
            ),
          ],
          
          if (appState == AppState.awaitingResolution) ...[
            const Text(
              'How did it go?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTaskComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('I did it!'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onTaskCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.cancel),
                    label: const Text('I couldn\'t do it'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onNeedMoreTime,
                icon: const Icon(Icons.access_time),
                label: const Text('I need more time'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}