import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_state_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/coach_portrait.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/action_buttons.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeTask = ref.read(activeTaskFromDbProvider).value;
      ref.read(chatNotifierProvider.notifier).loadMessages(taskId: activeTask?.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final activeTask = ref.read(activeTaskFromDbProvider).value;
    final currentCoach = ref.read(currentCoachProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    // Add user message
    await chatNotifier.addUserMessage(text, taskId: activeTask?.id, coachPersonaId: currentCoach.name);

    _messageController.clear();
    _scrollToBottom();

    // TODO: Send to LLM and get coach response
    // This will be implemented in the LLM integration task
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final activeTask = ref.watch(activeTaskFromDbProvider).value;
    final currentCoach = ref.watch(currentCoachProvider);
    final currentExpression = ref.watch(currentExpressionProvider);
    final isMuted = ref.watch(isMutedProvider);
    final chatMessages = ref.watch(chatNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(activeTask?.title ?? 'Pocket Coach'),
        actions: [
          IconButton(
            icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              ref.read(isMutedProvider.notifier).state = !isMuted;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Coach Portrait
          Container(
            padding: const EdgeInsets.all(8),
            child: CoachPortrait(personaId: currentCoach, expression: currentExpression, size: 120),
          ),

          // Chat Messages
          Expanded(
            child: chatMessages.when(
              data: (messages) => ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ChatBubble(message: message);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error loading messages: $error')),
            ),
          ),

          // Action Buttons based on app state
          ActionButtons(
            appState: appState,
            activeTask: activeTask,
            onPepTalk: () {
              ref.read(appStateProvider.notifier).setPepTalk();
            },
            onReturnToTask: () {
              ref.read(appStateProvider.notifier).setActiveTask();
            },
            onTaskComplete: () async {
              if (activeTask != null) {
                final taskNotifier = ref.read(taskNotifierProvider.notifier);
                await taskNotifier.completeTask(activeTask);
                ref.read(appStateProvider.notifier).setGeneral();
              }
            },
            onTaskCancel: () async {
              if (activeTask != null) {
                final taskNotifier = ref.read(taskNotifierProvider.notifier);
                await taskNotifier.cancelTask(activeTask);
                ref.read(appStateProvider.notifier).setGeneral();
              }
            },
            onNeedMoreTime: () {
              // TODO: Extend task time and reschedule notification
              ref.read(appStateProvider.notifier).setActiveTask();
            },
            onPause: () async {
              if (activeTask != null) {
                final taskNotifier = ref.read(taskNotifierProvider.notifier);
                await taskNotifier.pauseTask(activeTask);
                ref.read(appStateProvider.notifier).setGeneral();
              }
            },
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type a message...', border: OutlineInputBorder()),
                    onSubmitted: _sendMessage,
                    enabled: appState != AppState.awaitingResolution,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: appState != AppState.awaitingResolution
                      ? () => _sendMessage(_messageController.text)
                      : null,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
