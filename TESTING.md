# Testing Plan for Pocket Coach

This document outlines the testing strategy for the Pocket Coach Flutter application, including specific test cases that should be implemented and obstacles to testing certain components.

## Overview

The Pocket Coach app follows a clean architecture with:
- **State Management**: Flutter Riverpod
- **Database**: Isar (NoSQL) for local persistence  
- **External APIs**: OpenAI GPT-3.5-turbo for coach responses
- **Platform Services**: Local notifications, TTS, shared preferences

## 1. Recommended Tests to Implement

### 1.1 Model Tests (Unit Tests)

#### CoachPersona Tests
**File**: `test/models/coach_persona_test.dart`

**High Priority Tests:**
```dart
// Test persona retrieval by ID
testGetPersonaById() // Verify each persona returns correct properties
testGetPersonaByInvalidId() // Should handle gracefully or throw

// Test persona retrieval by string name  
testGetPersonaByString() // Verify string-to-persona mapping
testGetPersonaByInvalidString() // Should return default or throw

// Test persona properties
testPersonaProperties() // Verify name, description, avatarPath for each persona
```

**Why These Tests**: CoachPersona contains core business logic with no external dependencies. These tests verify the fundamental persona system works correctly.

#### Task Model Tests
**File**: `test/models/task_test.dart`

**High Priority Tests:**
```dart
// Test task lifecycle status transitions
testTaskStatusTransitions() // backlog -> active -> completed/cancelled
testInvalidStatusTransitions() // Should prevent invalid state changes

// Test task properties
testTaskCreation() // Verify all properties set correctly
testTaskSerialization() // Test JSON serialization/deserialization
testTaskTimestamps() // Verify createdAt, updatedAt, completedAt logic

// Test daily recurring logic
testDailyRecurringBehavior() // Verify recurring task properties
```

**Why These Tests**: Task is the core domain model. Status transitions and properties need to be bulletproof.

### 1.2 Service Tests (Unit Tests with Mocks)

#### DatabaseService Tests
**File**: `test/services/database_service_test.dart`

**High Priority Tests:**
```dart
// Task CRUD operations
testCreateTask() // Verify task creation and ID assignment
testGetTasksByStatus() // Test filtering by status
testUpdateTaskStatus() // Test status transitions persist correctly
testDeleteTask() // Verify deletion and cleanup

// Chat message operations
testCreateChatMessage() // Verify message creation with proper foreign keys
testGetChatMessagesByTask() // Test filtering by taskId
testDeleteChatMessage() // Verify deletion

// Statistics calculations
testCalculateSuccessRate() // Verify success rate calculation logic
testCalculateCurrentStreak() // Verify streak calculation logic
testGetTaskStatistics() // Integration of all statistics
```

**Why These Tests**: DatabaseService contains critical business logic for statistics and data integrity. Needs thorough testing with mocked Isar database.

#### PreferencesService Tests  
**File**: `test/services/preferences_service_test.dart`

**High Priority Tests:**
```dart
// API key management
testSetGetLlmApiKey() // Verify secure storage and retrieval
testSetGetTtsApiKey() // Verify optional TTS key handling

// Coach preferences
testSetGetDefaultCoach() // Verify coach selection persistence
testInvalidCoachHandling() // Handle invalid coach IDs gracefully

// App settings
testSetGetNotificationPreferences() // Verify notification settings
testSetGetThemePreferences() // Verify theme selection
testSetGetCheckInDuration() // Verify duration setting boundaries
```

**Why These Tests**: User preferences are critical for app functionality. Need to verify all settings persist correctly.

#### LLMService Tests
**File**: `test/services/llm_service_test.dart`

**High Priority Tests:**
```dart
// Prompt building
testBuildPromptForState() // Verify prompts built correctly for each app state
testBuildPromptWithTaskContext() // Verify task information included properly
testBuildPromptWithCoachPersona() // Verify coach persona affects prompt

// Response handling
testParseValidResponse() // Parse successful API responses
testHandleApiError() // Handle various API error scenarios
testHandleNetworkError() // Handle network connectivity issues
testHandleInvalidApiKey() // Handle authentication failures

// Message processing
testProcessUserMessage() // Verify message processing pipeline
testExtractCoachResponse() // Verify response extraction logic
```

**Why These Tests**: LLM integration is complex with many failure modes. Need to test prompt building logic and error handling thoroughly.

### 1.3 Provider Tests (Unit Tests with Mocks)

#### TaskProvider Tests
**File**: `test/providers/task_provider_test.dart`

**High Priority Tests:**
```dart
// Task lifecycle management
testCreateTask() // Verify task creation updates state
testActivateTask() // Verify only one active task allowed
testCompleteTask() // Verify completion updates state and statistics
testCancelTask() // Verify cancellation handling

// Task filtering and querying
testBacklogTasks() // Verify backlog filtering
testActiveTask() // Verify active task retrieval
testCompletedTasks() // Verify completed task filtering

// State invalidation
testStateInvalidationOnChanges() // Verify Riverpod invalidation works
```

**Why These Tests**: TaskProvider manages the core task lifecycle. Critical to verify state management and business rules.

#### ChatProvider Tests
**File**: `test/providers/chat_provider_test.dart`

**High Priority Tests:**
```dart
// Message management
testLoadMessages() // Verify message loading from database
testAddUserMessage() // Verify user message creation and state update
testAddCoachMessage() // Verify coach message creation with expression
testClearMessages() // Verify message clearing functionality

// State management
testInitialLoadingState() // Verify starts in loading state
testErrorHandling() // Verify error states handled properly
testStateUpdatesOnMessageAdd() // Verify state updates correctly
```

**Why These Tests**: Chat functionality is core to user experience. Need to verify message state management works correctly.

### 1.4 Widget Tests

#### TaskCard Tests
**File**: `test/widgets/task_card_test.dart`

**High Priority Tests:**
```dart
// Display tests
testDisplaysTaskInformation() // Verify title, status, timestamps shown
testDisplaysCorrectStatusIcon() // Verify status-specific icons
testDisplaysTaskDetails() // Verify optional details shown when present

// Interaction tests
testTapCallback() // Verify onTap callback fires
testLongPressCallback() // Verify onLongPress callback fires
testStatusBasedDisplay() // Verify different display for different statuses
```

**Why These Tests**: TaskCard is the primary task display component. Need to verify information display and interactions.

#### ChatBubble Tests
**File**: `test/widgets/chat_bubble_test.dart`

**High Priority Tests:**
```dart
// Message display
testDisplaysUserMessage() // Verify user message formatting
testDisplaysCoachMessage() // Verify coach message formatting
testDisplaysTimestamp() // Verify timestamp formatting

// Layout tests
testUserMessageAlignment() // Verify right alignment for user messages
testCoachMessageAlignment() // Verify left alignment for coach messages
testMessageBubbleColors() // Verify different colors for different senders
```

**Why These Tests**: ChatBubble is core to chat experience. Need to verify proper message display and formatting.

### 1.5 Integration Tests

#### Task Lifecycle Integration Tests
**File**: `test/integration/task_lifecycle_test.dart`

**High Priority Tests:**
```dart
// End-to-end task flow
testCompleteTaskFlow() // Create -> Activate -> Complete full flow
testCancelTaskFlow() // Create -> Activate -> Cancel full flow
testTaskStatisticsUpdate() // Verify statistics update after task completion

// Multi-task scenarios
testMultipleTaskManagement() // Verify multiple tasks in backlog
testActiveTaskEnforcement() // Verify only one active task allowed
```

**Why These Tests**: Verify the complete task management system works end-to-end.

#### Chat Integration Tests
**File**: `test/integration/chat_integration_test.dart`

**High Priority Tests:**
```dart
// Chat flow integration
testSendUserMessage() // Verify message sending updates UI
testChatMessagePersistence() // Verify messages persist across sessions
testChatWithTaskContext() // Verify task context affects chat
```

**Why These Tests**: Verify chat system integrates properly with database and UI.

## 2. Testing Obstacles and Challenges

### 2.1 Database Testing Obstacles

**Challenge**: Isar Database Integration
- **Issue**: Isar requires platform-specific setup and may not work in pure Dart test environment
- **Impact**: Affects all DatabaseService tests and dependent provider tests
- **Mitigation Strategy**: 
  - Create abstract database interface to enable mocking
  - Use Isar's in-memory database for integration tests
  - Mock DatabaseService for unit tests of dependent components

**Challenge**: Database Schema Evolution
- **Issue**: Isar migrations and schema changes may break existing tests
- **Impact**: Tests become brittle when model definitions change
- **Mitigation Strategy**:
  - Create test data builders that isolate schema changes
  - Use factory patterns for test data creation
  - Separate database integration tests from unit tests

### 2.2 External API Testing Obstacles

**Challenge**: OpenAI API Integration
- **Issue**: LLMService depends on external API with:
  - Network connectivity requirements
  - API key authentication
  - Rate limiting and quotas
  - Non-deterministic responses
- **Impact**: Tests become flaky and expensive to run
- **Mitigation Strategy**:
  - Mock HTTP client for unit tests
  - Create canned response fixtures for common scenarios
  - Test prompt building logic separately from API calls
  - Use integration tests sparingly for API validation

**Challenge**: API Response Variability
- **Issue**: LLM responses are non-deterministic, making assertions difficult
- **Impact**: Cannot test exact response content
- **Mitigation Strategy**:
  - Test response parsing logic with fixed inputs
  - Test error handling with controlled error scenarios
  - Focus on prompt building and response structure validation

### 2.3 Platform-Specific Testing Obstacles

**Challenge**: Local Notifications
- **Issue**: NotificationService depends on platform-specific APIs
- **Impact**: Tests require Android/iOS environment or simulator
- **Mitigation Strategy**:
  - Mock flutter_local_notifications plugin
  - Test notification scheduling logic separately
  - Create platform-specific test suites for integration testing

**Challenge**: Text-to-Speech
- **Issue**: TTSService depends on platform-specific voice synthesis
- **Impact**: Tests cannot verify actual speech output
- **Mitigation Strategy**:
  - Mock flutter_tts plugin
  - Test voice configuration and error handling
  - Manual testing required for actual TTS functionality

**Challenge**: File System Dependencies
- **Issue**: Path provider and file system operations
- **Impact**: Tests may have different behavior on different platforms
- **Mitigation Strategy**:
  - Mock path_provider for consistent test paths
  - Use temporary directories for test isolation
  - Clean up test files after test execution

### 2.4 State Management Testing Obstacles

**Challenge**: Riverpod Provider Dependencies
- **Issue**: Providers often depend on other providers, creating complex dependency chains
- **Impact**: Tests become complex to set up and maintain
- **Mitigation Strategy**:
  - Use ProviderContainer for isolated provider testing
  - Override dependencies with mocks using Riverpod's override system
  - Create provider test utilities for common setup patterns

**Challenge**: Async State Management
- **Issue**: Many providers use AsyncValue with complex loading/error states
- **Impact**: Tests need to handle async state transitions properly
- **Mitigation Strategy**:
  - Use proper async test patterns with expectLater
  - Test all async state transitions (loading -> data -> error)
  - Create async test utilities for common patterns

### 2.5 UI Testing Obstacles

**Challenge**: Complex Widget Dependencies
- **Issue**: Screens depend on multiple providers and external services
- **Impact**: Widget tests require extensive mocking setup
- **Mitigation Strategy**:
  - Focus on unit testing individual widgets
  - Use golden file tests for complex UI layouts
  - Mock provider dependencies for widget tests

**Challenge**: Platform-Specific UI Behavior
- **Issue**: Different behavior on Android vs iOS
- **Impact**: Tests may pass on one platform but fail on another
- **Mitigation Strategy**:
  - Run tests on both platforms in CI/CD
  - Use platform-specific test expectations where needed
  - Focus on cross-platform widget behavior

### 2.6 Test Data Management Obstacles

**Challenge**: Test Data Consistency
- **Issue**: Tests may interfere with each other through shared state
- **Impact**: Tests become flaky and order-dependent
- **Mitigation Strategy**:
  - Use isolated test databases for each test
  - Create data builders for consistent test data
  - Clean up test data after each test

**Challenge**: Realistic Test Data
- **Issue**: Creating realistic test data for complex scenarios
- **Impact**: Tests may not catch real-world edge cases
- **Mitigation Strategy**:
  - Create comprehensive test data factories
  - Use property-based testing for edge cases
  - Include real-world data patterns in test scenarios

## 3. Testing Infrastructure Requirements

### 3.1 Mock Factories Needed
- **DatabaseService** mock with in-memory data
- **HTTP client** mock for API calls
- **SharedPreferences** mock for settings
- **Notification plugin** mock for platform services
- **TTS plugin** mock for speech services

### 3.2 Test Utilities
- **Provider test container** setup helpers
- **Test data builders** for models
- **Async test helpers** for state management
- **Widget test helpers** for common UI patterns

### 3.3 CI/CD Considerations
- **Platform testing** on both Android and iOS
- **Database migration testing** for schema changes
- **API contract testing** for external dependencies
- **Performance testing** for large datasets

This testing plan provides a comprehensive foundation for implementing robust testing for the Pocket Coach application while acknowledging the real-world obstacles that need to be addressed.