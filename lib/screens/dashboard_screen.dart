import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/coach_persona.dart';
import '../providers/task_provider.dart';
import '../providers/app_state_provider.dart';
import '../services/preferences_service.dart';
import '../widgets/task_card.dart';
import '../widgets/statistics_card.dart';
import 'chat_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _taskTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskTitleController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _taskTitleController,
                  decoration: const InputDecoration(
                    hintText: 'Enter task title...',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _taskTitleController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                if (_taskTitleController.text.trim().isNotEmpty) {
                  final taskNotifier = ref.read(taskNotifierProvider.notifier);
                  await taskNotifier.createTask(_taskTitleController.text.trim());
                  Navigator.of(context).pop();
                  _taskTitleController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTaskOptionsDialog(Task task) async {
    int checkInMinutes = task.checkInIntervalOverride ?? PreferencesService.defaultCheckInMinutes;
    CoachPersonaId selectedCoach = task.coachPersonaOverride != null
        ? CoachPersona.getPersonaByString(task.coachPersonaOverride!).id
        : PreferencesService.defaultCoachPersonaId;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Start: ${task.title}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Check-in time (minutes)'),
                    subtitle: Slider(
                      value: checkInMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '$checkInMinutes min',
                      onChanged: (value) {
                        setState(() {
                          checkInMinutes = value.round();
                        });
                      },
                    ),
                  ),
                  DropdownButtonFormField<CoachPersonaId>(
                    value: selectedCoach,
                    decoration: const InputDecoration(
                      labelText: 'Coach',
                      border: OutlineInputBorder(),
                    ),
                    items: CoachPersonaId.values.map((coach) {
                      final persona = CoachPersona.getPersona(coach);
                      return DropdownMenuItem(
                        value: coach,
                        child: Text(persona.name),
                      );
                    }).toList(),
                    onChanged: (CoachPersonaId? value) {
                      if (value != null) {
                        setState(() {
                          selectedCoach = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Start Task'),
                  onPressed: () async {
                    final taskNotifier = ref.read(taskNotifierProvider.notifier);
                    await taskNotifier.activateTask(
                      task,
                      checkInInterval: checkInMinutes,
                      coachOverride: selectedCoach.name,
                    );
                    
                    ref.read(appStateProvider.notifier).setActiveTask();
                    ref.read(currentCoachProvider.notifier).setCoach(selectedCoach);
                    
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Coach'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Backlog', icon: Icon(Icons.list)),
            Tab(text: 'History', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Backlog Tab
          Consumer(
            builder: (context, ref, child) {
              final backlogTasks = ref.watch(backlogTasksProvider);
              
              return backlogTasks.when(
                data: (tasks) => tasks.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No tasks yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              'Tap + to add your first task',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                            task: task,
                            onTap: () async {
                              final taskNotifier = ref.read(taskNotifierProvider.notifier);
                              await taskNotifier.activateTask(task);
                              
                              ref.read(appStateProvider.notifier).setActiveTask();
                              
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const ChatScreen()),
                              );
                            },
                            onLongPress: () => _showTaskOptionsDialog(task),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading tasks: $error'),
                ),
              );
            },
          ),
          
          // History & Metrics Tab
          Consumer(
            builder: (context, ref, child) {
              final statistics = ref.watch(taskStatisticsProvider);
              
              return statistics.when(
                data: (stats) => SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      StatisticsCard(statistics: stats),
                      const SizedBox(height: 24),
                      const Text(
                        'Completed Tasks',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final completedTasks = ref.watch(completedTasksProvider);
                          
                          return completedTasks.when(
                            data: (tasks) => tasks.isEmpty
                                ? const Text('No completed tasks yet')
                                : Column(
                                    children: tasks.map((task) => TaskCard(
                                      task: task,
                                      showStatus: true,
                                    )).toList(),
                                  ),
                            loading: () => const CircularProgressIndicator(),
                            error: (error, stack) => Text('Error: $error'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error loading statistics: $error'),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _showAddTaskDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}