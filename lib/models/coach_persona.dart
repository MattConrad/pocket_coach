enum CoachPersonaId { sterling, willow, john, callum }

class CoachPersona {
  final CoachPersonaId id;
  final String name;
  final String description;
  final String successReaction;
  final String failureReaction;
  final String systemPrompt;

  const CoachPersona({
    required this.id,
    required this.name,
    required this.description,
    required this.successReaction,
    required this.failureReaction,
    required this.systemPrompt,
  });

  /*
"Overwatch character design style, portrait from chest up, [character details]. Character positioned center frame with head taking up 50% of image height, eyes at upper third line. Consistent portrait framing and proportions."
*/

  static const Map<CoachPersonaId, CoachPersona> personas = {
    CoachPersonaId.sterling: CoachPersona(
      id: CoachPersonaId.sterling,
      name: 'Coach Sterling',
      description: 'The Drill Sergeant - Tough-love, no-nonsense. Focuses on discipline and results.',
      successReaction: 'Good. That\'s what I expect. What\'s next?',
      failureReaction:
          'Unacceptable. Excuses don\'t get the job done. We\'re going to learn from this failure so it doesn\'t happen again.',
      systemPrompt:
          'You are Coach Sterling, a tough-love drill sergeant coach. You are direct, no-nonsense, and focus on discipline and results. You acknowledge success as expected and are harsh but constructive about failures.',
    ),

    /*
"Overwatch character design style, tight portrait from chest up, close framing, 30-year-old African-American man with black hair in military fade cut, clean-shaven, wearing thick black-rimmed glasses and olive green t-shirt. Stern expression with slight frown and focused gaze. Character positioned center frame with head taking up 50% of image height, eyes at upper third line. Background: twilight desert scrubland with weathered boulders and sparse leafless brown shrubs, dusky purple-orange sky, soft ambient lighting."
*/
    CoachPersonaId.willow: CoachPersona(
      id: CoachPersonaId.willow,
      name: 'Coach Willow',
      description: 'The Nurturing Mentor - Gentle, empathetic, and encouraging. Focuses on progress, not perfection.',
      successReaction: 'That\'s wonderful! I knew you could do it. You should be proud of that effort.',
      failureReaction:
          'Hey, that\'s okay. Sometimes things don\'t go as planned. What can we learn from this, and how can I help you feel ready for the next challenge?',
      systemPrompt:
          'You are Coach Willow, a gentle, empathetic, and encouraging mentor. You focus on progress over perfection, celebrate successes warmly, and are understanding and supportive about setbacks.',
    ),
    /*
"Overwatch character design style, tight portrait from chest up, close framing, middle-aged Asian woman, with graying hair pulled back with dark blue ribbon, wearing soft periwinkle blue sweater. Serene expression with gentle smile and empathetic eyes. Character positioned center frame with head taking up 50% of image height, eyes at upper third line. Background: wellness space with deep sapphire blue accent wall behind zen garden, flowing water feature, peaceful natural lighting."
*/
    CoachPersonaId.john: CoachPersona(
      id: CoachPersonaId.john,
      name: 'Coach John',
      description:
          'The Analytical Strategist - Data-driven, logical, and process-oriented. Focuses on breaking down problems and optimizing approach.',
      successReaction:
          'Excellent. The plan was executed successfully. The outcome is a direct result of a solid process.',
      failureReaction:
          'Okay, a deviation from the projected outcome. Let\'s analyze the variables. What was the point of failure in the process? We can adjust the strategy.',
      systemPrompt:
          'You are Coach John, an analytical strategist who is data-driven, logical, and process-oriented. You focus on breaking down problems, analyzing outcomes, and optimizing approaches through systematic thinking.',
    ),

    /*
"Overwatch character design style, tight portrait from chest up, close framing, middle-aged to elderly man with distinctive unruly white hair, neat and well trimmed white beard, professorial appearance with intelligent blue eyes. Serious, thoughtful expression, looking directly at the camera. Wearing light grey, almost white, button-down shirt. Character positioned center frame with head taking up 50% of image height, eyes at upper third line. Background: personal library with white walls, organized bookshelves, bright window with blue sky and white clouds, soft natural lighting."
*/
    CoachPersonaId.callum: CoachPersona(
      id: CoachPersonaId.callum,
      name: 'Coach Callum',
      description: 'The Scottish Craftsman - Enthusiastic and optimistic. Focuses on the joy of accomplishment.',
      successReaction: 'There\'s nothing like the feeling of a job well done. Let\'s keep it rolling.',
      failureReaction: 'It won\'t get done unless we do it. Let\'s roll up our sleeves and get back to work.',
      systemPrompt: 'You are Coach Callum, a Scottish craftsman . . .',
    ),

    /*
"Overwatch character design style, portrait from chest up, 40 year old man with bright red hair, full mustache and beard, wearing casual red polo shirt. Expression: smile, closed mouth, with one eyebrow slightly raised. Character positioned center frame with head taking up 50% of image height, eyes at upper third line. Background: makerspace workshop with 3D printer glowing orange on left side, electronic devices with warm orange/yellow LED indicators on right side. Soft yellow workshop lighting, slightly blurred background to keep focus on character."
*/
  };

  static CoachPersona getPersona(CoachPersonaId id) {
    return personas[id]!;
  }

  static CoachPersona getPersonaByString(String id) {
    final personaId = CoachPersonaId.values.firstWhere((p) => p.name == id, orElse: () => CoachPersonaId.willow);
    return getPersona(personaId);
  }
}
