import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../models/coach_persona.dart';
import '../services/preferences_service.dart';

enum AppState {
  general,
  activeTask,
  pepTalk,
  awaitingResolution,
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState.general);

  void setGeneral() => state = AppState.general;
  void setActiveTask() => state = AppState.activeTask;
  void setPepTalk() => state = AppState.pepTalk;
  void setAwaitingResolution() => state = AppState.awaitingResolution;
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class ActiveTaskNotifier extends StateNotifier<Task?> {
  ActiveTaskNotifier() : super(null);

  void setActiveTask(Task task) => state = task;
  void clearActiveTask() => state = null;
  
  void updateTask(Task updatedTask) {
    if (state?.id == updatedTask.id) {
      state = updatedTask;
    }
  }
}

final activeTaskProvider = StateNotifierProvider<ActiveTaskNotifier, Task?>((ref) {
  return ActiveTaskNotifier();
});

class CurrentCoachNotifier extends StateNotifier<CoachPersonaId> {
  // Use the value from shared preferences on initialization
  CurrentCoachNotifier() : super(PreferencesService.defaultCoachPersonaId);

  void setCoach(CoachPersonaId personaId) => state = personaId;
}

final currentCoachProvider = StateNotifierProvider<CurrentCoachNotifier, CoachPersonaId>((ref) {
  return CurrentCoachNotifier();
});

final isMutedProvider = StateProvider<bool>((ref) => false);

class AppThemeNotifier extends StateNotifier<String> {
  AppThemeNotifier() : super(PreferencesService.appTheme);

  Future<void> setTheme(String theme) async {
    await PreferencesService.setAppTheme(theme);
    state = theme;
  }
}

final appThemeProvider = StateNotifierProvider<AppThemeNotifier, String>((ref) {
  return AppThemeNotifier();
});