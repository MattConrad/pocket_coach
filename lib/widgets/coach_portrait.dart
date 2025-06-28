import 'package:flutter/material.dart';
import '../models/coach_persona.dart';
import '../models/chat_message.dart';

class CoachPortrait extends StatelessWidget {
  final CoachPersonaId personaId;
  final CoachExpression expression;
  final double size;

  const CoachPortrait({super.key, required this.personaId, required this.expression, this.size = 100});

  String get _imagePath {
    final expressionName = switch (expression) {
      CoachExpression.defaultExpression => 'default',
      CoachExpression.happy => 'happy',
      CoachExpression.disappointed => 'disappointed',
      CoachExpression.surprised => 'surprised',
    };

    return 'assets/images/${personaId.name}_$expressionName.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).primaryColor, width: 3),
      ),
      child: ClipOval(
        child: Image.asset(
          _imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback when image is not found
            return Container(
              width: size,
              height: size,
              color: Colors.grey[300],
              child: Icon(Icons.person, size: size * 0.6, color: Colors.grey[600]),
            );
          },
        ),
      ),
    );
  }
}
