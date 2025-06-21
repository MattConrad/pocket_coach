## Document 1: Product Requirements Document (PRD) - Pocket Coach

This document outlines the vision, features, and user experience for the Pocket Coach application. It serves as the guiding "what" and "why" for the project.

### 1. Overview

#### 1.1. App Concept
Pocket Coach is a mobile application designed to act as a personal, AI-driven "pocket coach." It helps users stay motivated and on-track with their short-term tasks. Users choose from a selection of coach personas, define tasks, and receive encouragement, advice, and accountability checks from their chosen coach.

#### 1.2. Target Audience
The app is for individuals seeking a simple, lightweight tool for accountability, focus, and encouragement for daily or one-off tasks. This includes students, freelancers, professionals working from home, and anyone looking to build better habits or overcome procrastination on small-scale objectives.

### 2. Core Features & Functionality

#### 2.1. Task Management
*   **Tasks, not Goals:** The app focuses on short-term, actionable items called "tasks" (e.g., "write email to boss," "do 20 minutes of cleaning").
*   **Single Active Task:** To promote focus, users can only have one "active" task at a time. All other tasks reside in a backlog.
*   **Task Lifecycle:** Tasks progress through a clear lifecycle:
    1.  **Creation:** Users can create tasks from the Dashboard or via conversational intent in the chat.
    2.  **Backlog:** New tasks are added to a simple list.
    3.  **Activation:** A user makes a task active from the backlog. They can quick-start with defaults or long-press to customize the check-in duration or coach for that specific task.
    4.  **Pausing:** The active task can be paused, which cancels the upcoming check-in notification.
    5.  **Resolution:** The task is marked as `Completed` or `Cancelled` (equivalent to failed) by the user.
*   **Recurring Tasks:** Users can define tasks that recur daily. A completed daily task will automatically reappear in the backlog the next day.

#### 2.2. Coaching Interaction
*   **Conversational Interface:** The primary interaction model is a chat screen with an AI coach.
*   **TTS Audio:** Coach responses are accompanied by Text-to-Speech (TTS) audio output for a more personal experience. This can be muted by the user.
*   **Check-ins:** The coach will proactively check in on the user's progress for an active task via a local notification at a user-defined interval.
*   **Persona-driven Feedback:** The coach's responses, particularly to task success or failure, are determined by their defined persona.

#### 2.3. Pep Talks
*   A user can request a "Pep Talk" from their coach at any time via a dedicated button on the chat screen.
*   This initiates a conversation mode separate from any active task, allowing the user to get general encouragement. The user can then return to their active task context.

#### 2.4. Dashboard & History
The dashboard provides an at-a-glance overview of tasks and progress. It is divided into two main sections (Tabs):
*   **Task Backlog:** A list of all non-active tasks.
*   **History & Metrics:** A view of performance statistics, including:
    *   Overall task success percentage.
    *   Current success streak.
    *   Daily task completion streak.
    *   A calendar view indicating days with only successes vs. days with one or more failures.
    *   Metrics can be filtered by coach.

#### 2.5. Settings & Configuration
A dedicated screen allows the user to configure the app:
*   **API Keys:** Input fields for LLM and premium TTS service keys.
*   **Coach Selection:** Choose the default coach persona.
*   **Task Defaults:** Set the default check-in duration for new tasks.
*   **Theme:** Select Light, Dark, or System theme.
*   **Notifications:** Master toggle for enabling/disabling notifications.
*   **Data Management:** A section to edit/correct task history (intentionally less accessible to discourage casual use).

### 3. Coach Personas

There are four distinct coach personas. Each has a unique name, personality, visual portrait (with 4 expressions: `default`, `happy`, `disappointed`, `surprised`), and vocal style.

1.  **Coach Sterling (The Drill Sergeant)**
    *   **Description:** Tough-love, no-nonsense. Focuses on discipline and results.
    *   **Reaction to Success:** Acknowledges the success as the expected outcome. "Good. That's what I expect. What's next?"
    *   **Reaction to Failure/Cancel:** Harsh and direct, aimed at preventing a repeat. "Unacceptable. Excuses don't get the job done. We're going to learn from this failure so it doesn't happen again."

2.  **Coach Willow (The Nurturing Mentor)**
    *   **Description:** Gentle, empathetic, and encouraging. Focuses on progress, not perfection.
    *   **Reaction to Success:** Warm and celebratory. "That's wonderful! I knew you could do it. You should be proud of that effort."
    *   **Reaction to Failure/Cancel:** Understanding and supportive. "Hey, that's okay. Sometimes things don't go as planned. What can we learn from this, and how can I help you feel ready for the next challenge?"

3.  **Coach Kai (The Analytical Strategist)**
    *   **Description:** Data-driven, logical, and process-oriented. Focuses on breaking down problems and optimizing approach.
    *   **Reaction to Success:** Analytical praise. "Excellent. The plan was executed successfully. The outcome is a direct result of a solid process."
    *   **Reaction to Failure/Cancel:** A problem to be solved. "Okay, a deviation from the projected outcome. Let's analyze the variables. What was the point of failure in the process? We can adjust the strategy."

4.  **Coach Sparky (The Energetic Cheerleader)**
    *   **Description:** Quirky, high-energy, and fun-loving. Focuses on making tasks enjoyable and celebrating effort.
    *   **Reaction to Success:** Exuberant and over-the-top. "YES! You totally crushed it! That was AWESOME! Let's do a victory dance!"
    *   **Reaction to Failure/Cancel:** Reframes it positively. "Aww, bummer! But hey, you GAVE IT A SHOT! That's what matters! We'll get 'em next time, champ! Shake it off!"

### 4. Key User Flows

*   **User Story 1: First-Time Onboarding**
    1.  As a new user, I open the app for the first time.
    2.  I see a welcome screen with brief text instructions on what the app does.
    3.  After dismissing the instructions, I am taken to the Settings screen.
    4.  I see fields where I can enter my LLM and TTS API keys.
    5.  I see that a default coach (e.g., Willow) is pre-selected.
    6.  I navigate to the main chat screen and can begin interacting.

*   **User Story 2: The Lifecycle of a Task**
    1.  As a user, I go to the Dashboard screen and tap the "Add Task" button.
    2.  I enter the title "Organize my desktop" and save it. The task appears in my backlog.
    3.  I long-press the task in my backlog. A modal appears. I change the check-in duration from the default 20 minutes to 45 minutes and tap "Start Task."
    4.  I am navigated to the chat screen. Coach Kai says, "Beginning task: Organize my desktop. Objective confirmed. I will check on your progress in 45 minutes."
    5.  45 minutes later, I receive a notification: "Coach Kai: Checking in on 'Organize my desktop'."
    6.  I tap the notification, which opens the app to the chat screen. I see shortcut buttons `[ I did it! ]`, `[ I need more time ]`. I tap `[ I did it! ]`.
    7.  Coach Kai replies, "Excellent. The plan was executed successfully," and his portrait changes to the 'happy' expression. The task is now marked as complete in my history.

*   **User Story 3: Requesting a Pep Talk**
    1.  As a user, I am feeling unmotivated. I have no active task.
    2.  I open the app and go to the chat screen with my default coach, Sparky.
    3.  I tap the "Pep Talk" button on the screen.
    4.  Sparky's chat bubble appears: "You need a boost?! I'M YOUR BOOST! What's on your mind?"
    5.  I type, "I'm just feeling a bit overwhelmed today."
    6.  Sparky gives me an energetic, encouraging response. After our chat, the app remains in the general state, ready for me to start a task.

