import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_coach/models/coach_persona.dart';

void main() {
  group('CoachPersona', () {
    group('getPersona', () {
      test('should return correct persona for Sterling ID', () {
        final persona = CoachPersona.getPersona(CoachPersonaId.sterling);
        
        expect(persona.id, CoachPersonaId.sterling);
        expect(persona.name, 'Coach Sterling');
        expect(persona.description, 'The Drill Sergeant - Tough-love, no-nonsense. Focuses on discipline and results.');
        expect(persona.successReaction, 'Good. That\'s what I expect. What\'s next?');
        expect(persona.failureReaction, 'Unacceptable. Excuses don\'t get the job done. We\'re going to learn from this failure so it doesn\'t happen again.');
        expect(persona.systemPrompt.contains('Coach Sterling'), true);
        expect(persona.systemPrompt.contains('drill sergeant'), true);
      });

      test('should return correct persona for Willow ID', () {
        final persona = CoachPersona.getPersona(CoachPersonaId.willow);
        
        expect(persona.id, CoachPersonaId.willow);
        expect(persona.name, 'Coach Willow');
        expect(persona.description, 'The Nurturing Mentor - Gentle, empathetic, and encouraging. Focuses on progress, not perfection.');
        expect(persona.successReaction, 'That\'s wonderful! I knew you could do it. You should be proud of that effort.');
        expect(persona.failureReaction, 'Hey, that\'s okay. Sometimes things don\'t go as planned. What can we learn from this, and how can I help you feel ready for the next challenge?');
        expect(persona.systemPrompt.contains('Coach Willow'), true);
        expect(persona.systemPrompt.contains('gentle'), true);
      });

      test('should return correct persona for John ID', () {
        final persona = CoachPersona.getPersona(CoachPersonaId.john);
        
        expect(persona.id, CoachPersonaId.john);
        expect(persona.name, 'Coach John');
        expect(persona.description, 'The Analytical Strategist - Data-driven, logical, and process-oriented. Focuses on breaking down problems and optimizing approach.');
        expect(persona.successReaction, 'Excellent. The plan was executed successfully. The outcome is a direct result of a solid process.');
        expect(persona.failureReaction, 'Okay, a deviation from the projected outcome. Let\'s analyze the variables. What was the point of failure in the process? We can adjust the strategy.');
        expect(persona.systemPrompt.contains('Coach John'), true);
        expect(persona.systemPrompt.contains('analytical'), true);
      });

      test('should return correct persona for Callum ID', () {
        final persona = CoachPersona.getPersona(CoachPersonaId.callum);
        
        expect(persona.id, CoachPersonaId.callum);
        expect(persona.name, 'Coach Callum');
        expect(persona.description, 'The Scottish Craftsman - Enthusiastic and optimistic. Focuses on the joy of accomplishment.');
        expect(persona.successReaction, 'There\'s nothing like the feeling of a job well done. Let\'s keep it rolling.');
        expect(persona.failureReaction, 'It won\'t get done unless we do it. Let\'s roll up our sleeves and get back to work.');
        expect(persona.systemPrompt.contains('Coach Callum'), true);
        expect(persona.systemPrompt.contains('Scottish'), true);
      });
    });

    group('getPersonaByString', () {
      test('should return Sterling persona for "sterling" string', () {
        final persona = CoachPersona.getPersonaByString('sterling');
        expect(persona.id, CoachPersonaId.sterling);
        expect(persona.name, 'Coach Sterling');
      });

      test('should return Willow persona for "willow" string', () {
        final persona = CoachPersona.getPersonaByString('willow');
        expect(persona.id, CoachPersonaId.willow);
        expect(persona.name, 'Coach Willow');
      });

      test('should return John persona for "john" string', () {
        final persona = CoachPersona.getPersonaByString('john');
        expect(persona.id, CoachPersonaId.john);
        expect(persona.name, 'Coach John');
      });

      test('should return Callum persona for "callum" string', () {
        final persona = CoachPersona.getPersonaByString('callum');
        expect(persona.id, CoachPersonaId.callum);
        expect(persona.name, 'Coach Callum');
      });

      test('should return default Willow persona for invalid string', () {
        final persona = CoachPersona.getPersonaByString('invalid_coach');
        expect(persona.id, CoachPersonaId.willow);
        expect(persona.name, 'Coach Willow');
      });

      test('should return default Willow persona for empty string', () {
        final persona = CoachPersona.getPersonaByString('');
        expect(persona.id, CoachPersonaId.willow);
        expect(persona.name, 'Coach Willow');
      });
    });

    group('persona properties validation', () {
      test('all personas should have non-empty required properties', () {
        for (final personaId in CoachPersonaId.values) {
          final persona = CoachPersona.getPersona(personaId);
          
          expect(persona.name.isNotEmpty, true, reason: 'Persona ${personaId.name} should have a non-empty name');
          expect(persona.description.isNotEmpty, true, reason: 'Persona ${personaId.name} should have a non-empty description');
          expect(persona.successReaction.isNotEmpty, true, reason: 'Persona ${personaId.name} should have a non-empty successReaction');
          expect(persona.failureReaction.isNotEmpty, true, reason: 'Persona ${personaId.name} should have a non-empty failureReaction');
          expect(persona.systemPrompt.isNotEmpty, true, reason: 'Persona ${personaId.name} should have a non-empty systemPrompt');
        }
      });

      test('all personas should have unique names', () {
        final names = <String>{};
        for (final personaId in CoachPersonaId.values) {
          final persona = CoachPersona.getPersona(personaId);
          expect(names.contains(persona.name), false, reason: 'Persona name "${persona.name}" should be unique');
          names.add(persona.name);
        }
      });

      test('persona map should contain all enum values', () {
        for (final personaId in CoachPersonaId.values) {
          expect(CoachPersona.personas.containsKey(personaId), true, reason: 'Personas map should contain entry for ${personaId.name}');
        }
      });

      test('persona map should have correct count', () {
        expect(CoachPersona.personas.length, CoachPersonaId.values.length);
      });
    });
  });
}