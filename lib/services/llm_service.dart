import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/coach_persona.dart';
import '../models/task.dart';
import '../providers/app_state_provider.dart';
import 'preferences_service.dart';

class LLMService {
  static const String _openaiEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  Future<LLMResponse?> sendMessage({
    required String userMessage,
    required CoachPersonaId coachPersona,
    required AppState appState,
    Task? activeTask,
    List<ChatMessage>? recentMessages,
  }) async {
    final apiKey = PreferencesService.llmApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('LLM API key not configured');
    }

    try {
      final persona = CoachPersona.getPersona(coachPersona);
      final prompt = _buildPrompt(
        persona: persona,
        appState: appState,
        activeTask: activeTask,
        recentMessages: recentMessages ?? [],
        userMessage: userMessage,
      );

      final response = await http.post(
        Uri.parse(_openaiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': prompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Try to parse as JSON response with reply and new_expression
        try {
          final parsedResponse = jsonDecode(content);
          return LLMResponse(
            reply: parsedResponse['reply'] as String,
            newExpression: _parseExpression(parsedResponse['new_expression'] as String?),
          );
        } catch (e) {
          // If not JSON, treat as plain text response
          return LLMResponse(
            reply: content,
            newExpression: CoachExpression.defaultExpression,
          );
        }
      } else {
        throw Exception('LLM API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send message to LLM: $e');
    }
  }

  String _buildPrompt({
    required CoachPersona persona,
    required AppState appState,
    Task? activeTask,
    required List<ChatMessage> recentMessages,
    required String userMessage,
  }) {
    final buffer = StringBuffer();
    
    // System prompt with persona
    buffer.writeln('SYSTEM PROMPT:');
    buffer.writeln('You are ${persona.name}, ${persona.description}');
    buffer.writeln(persona.systemPrompt);
    buffer.writeln();
    
    // Current app state
    buffer.writeln('CURRENT APP STATE:');
    switch (appState) {
      case AppState.general:
        buffer.writeln('GENERAL_CHAT - No active task. User can request pep talks or create new tasks.');
        break;
      case AppState.activeTask:
        buffer.writeln('IN_ACTIVE_TASK - User has an active task in progress.');
        if (activeTask != null) {
          buffer.writeln('Active task: "${activeTask.title}"');
          if (activeTask.details != null) {
            buffer.writeln('Task details: "${activeTask.details}"');
          }
        }
        break;
      case AppState.pepTalk:
        buffer.writeln('PEP_TALK_MODE - User requested general encouragement/motivation.');
        break;
      case AppState.awaitingResolution:
        buffer.writeln('AWAITING_RESOLUTION - Checking in on task progress. User should respond with success/failure.');
        if (activeTask != null) {
          buffer.writeln('Task being checked: "${activeTask.title}"');
        }
        break;
    }
    buffer.writeln();
    
    // Recent conversation history
    if (recentMessages.isNotEmpty) {
      buffer.writeln('CONVERSATION HISTORY:');
      for (final message in recentMessages.take(5)) {
        final sender = message.sender == MessageSender.user ? 'USER' : 'COACH';
        buffer.writeln('$sender: ${message.text}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('USER MESSAGE:');
    buffer.writeln(userMessage);
    buffer.writeln();
    
    buffer.writeln('INSTRUCTIONS:');
    buffer.writeln('Respond in character as ${persona.name}. Your response must be a single JSON object with two keys:');
    buffer.writeln('- "reply": Your text response as a string (keep it conversational and under 200 words)');
    buffer.writeln('- "new_expression": One of "default", "happy", "disappointed", "surprised"');
    buffer.writeln();
    buffer.writeln('If the user indicates task completion, react according to your persona.');
    buffer.writeln('If the user indicates task failure, react according to your persona.');
    
    return buffer.toString();
  }

  CoachExpression _parseExpression(String? expressionString) {
    if (expressionString == null) return CoachExpression.defaultExpression;
    
    switch (expressionString.toLowerCase()) {
      case 'happy':
        return CoachExpression.happy;
      case 'disappointed':
        return CoachExpression.disappointed;
      case 'surprised':
        return CoachExpression.surprised;
      default:
        return CoachExpression.defaultExpression;
    }
  }
}

class LLMResponse {
  final String reply;
  final CoachExpression newExpression;

  LLMResponse({
    required this.reply,
    required this.newExpression,
  });
}