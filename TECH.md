## Document 2: Technical Specification - Pocket Coach

This document details the technical implementation, data structures, and API interactions for the Pocket Coach Flutter application. It is intended as a blueprint for code generation and development.

### 1. Architecture & Tech Stack

*   **Framework:** Flutter (latest stable version)
*   **Language:** Dart
*   **State Management:** **Riverpod**. This allows for a clean separation of UI, business logic, and data layers.
*   **Persistence:**
    *   **`shared_preferences`:** For storing simple, non-relational key-value data like settings and API keys.
    *   **`Isar`:** A fast, local NoSQL database for storing structured application data like tasks and chat messages.
*   **Architecture:** The application will be **local-first**. All user data is stored exclusively on the device. There is no backend server or user authentication.

### 2. Data Models

#### 2.1. Isar Schemas

**`Task` Model:**
```dart
@collection
class Task {
  Id id = Isar.autoIncrement; // Auto-incrementing primary key
  late String title;
  String? details; // Optional additional details for the task
  late String status; // Enum-like: "backlog", "active", "paused", "completed", "cancelled"
  late bool isDailyRecurring;
  late DateTime creationTimestamp;
  DateTime? completionTimestamp;
  int? checkInIntervalOverride; // In minutes. Null if using default.
}
```

**`ChatMessage` Model:**
```dart
@collection
class ChatMessage {
  Id id = Isar.autoIncrement;
  @Index() // Index for faster lookups
  int? taskId; // Nullable. Links to a Task if the message is part of a task context.
  late String sender; // Enum-like: "user", "coach"
  late String text;
  late DateTime timestamp;
  late String coachPersonaId; // e.g., "sterling", "willow"
  String? coachExpression; // Enum-like: "default", "happy", "disappointed", "surprised". Null for user messages.
}
```

#### 2.2. `shared_preferences` Keys

*   `llmApiKey` (String)
*   `ttsApiKey` (String)
*   `defaultCoachPersonaId` (String, e.g., "willow")
*   `defaultCheckInMinutes` (int, e.g., 20)
*   `appTheme` (String, "light", "dark", "system")

### 3. Screen & UI Logic

#### 3.1. Chat Screen (`chat_screen.dart`)
*   **Stateful Logic:** The screen's UI must react to the current application context, managed by a `Riverpod` provider. The primary states are:
    1.  **`General` state:** No active task. The "Pep Talk" button is visible. The text input is enabled for general chat or task creation intent.
    2.  **`ActiveTask` state:** An active task is in progress. Contextual buttons `[Pause]`, `[Cancel]` are visible. The "Pep Talk" button is also visible to allow for mode switching.
    3.  **`PepTalk` state:** User has initiated a pep talk. The chat is sandboxed from the active task context. A "Return to Task" button is visible if an active task was paused to enter this mode.
    4.  **`AwaitingResolution` state:** A check-in has occurred. Input is temporarily replaced by resolution buttons: `[ I did it! ]`, `[ I couldn't do it ]`, `[ I need more time ]`.
*   **UI Components:**
    *   **Coach Portrait:** An `Image` widget that displays `assets/images/{coach_persona_id}_{expression}.png`. The image path is determined by the latest `ChatMessage` from the coach.
    *   **Mute Button:** A floating action button or icon button to toggle TTS playback for coach messages.
    *   **Chat List:** A `ListView` displaying `ChatMessage` objects, styled differently for "user" and "coach" senders.

#### 3.2. Dashboard Screen (`dashboard_screen.dart`)
*   **UI Structure:** A `Scaffold` with a `TabBar` for switching between "Backlog" and "History".
*   **Backlog Tab:**
    *   Displays a `ListView` of all `Task` objects where `status == 'backlog'`.
    *   Each list item is wrapped in a `GestureDetector`.
    *   **`onTap`:** Sets the task status to `active`, uses default settings, and navigates to the Chat Screen.
    *   **`onLongPress`:** Opens a modal dialog (`showDialog`) allowing the user to edit `checkInIntervalOverride` and the coach for the task before starting.
*   **History & Metrics Tab:**
    *   Fetches all `Task` objects with `status == 'completed'` or `status == 'cancelled'`.
    *   Contains widgets to display calculated statistics. Logic for these calculations will reside in the corresponding `Riverpod` provider.

#### 3.3. Settings Screen (`settings_screen.dart`)
*   A form with `TextField` controllers linked to `shared_preferences` for API keys and default duration.
*   A `DropdownButton` or segmented control to select the `defaultCoachPersonaId` and `appTheme`.

### 4. API & Service Integration

#### 4.1. LLM API Call
*   **Trigger:** When the user sends a message.
*   **Prompt Construction:** The prompt sent to the LLM must be carefully structured.
    ```
    SYSTEM PROMPT:
    You are {coachPersonaDefinition}.
    The current app state is: {appState}.
    The active task is: {taskTitle}.
    Your current expression is: {currentExpression}.

    CONVERSATION HISTORY:
    {last_5_messages}

    USER MESSAGE:
    {user_message}

    INSTRUCTIONS:
    Respond in character. Your response must be a single JSON object with two keys: "reply" (your text response as a string) and "new_expression" (a string matching one of: "default", "happy", "disappointed", "surprised").
    ```
*   **State Injection Examples:**
    *   `coachPersonaDefinition`: "Coach Sterling, a tough-love drill sergeant. You are direct and focus on results."
    *   `appState`: "AWAITING_RESOLUTION" or "IN_ACTIVE_TASK" or "GENERAL_CHAT"
*   **Response Handling:** The app must parse the JSON response to get the `reply` text to display and the `new_expression` to update the coach's portrait.

#### 4.2. TTS API Call
*   **Trigger:** After receiving a valid response from the LLM.
*   **Logic:**
    1.  Check if a `ttsApiKey` is present and the mute toggle is off.
    2.  If yes, make an API call to the premium TTS service with the `reply` text and persona-specific voice prompt.
    3.  If no, use a platform-native TTS package (e.g., `flutter_tts`) to speak the `reply` text as a fallback.

#### 4.3. Local Notifications
*   **Dependency:** A package like `flutter_local_notifications`.
*   **Scheduling:** When a `Task`'s status becomes `active`, schedule a notification:
    *   `schedule(duration: checkInInterval, title: 'Coach {Name}: Checking in', body: '{Task Title}', payload: '{taskId}')`
*   **Cancellation:** The pending notification must be cancelled if the task status changes to `paused`, `completed`, or `cancelled`.
*   **Handling Tap:** When a user taps a notification, the app's `onNotificationTap` handler should read the `taskId` from the payload, find the corresponding task, set it as the active context, and navigate the user directly to the Chat Screen.
