class MedicalPrompts {
  static const List<String> suggestionPrompts = [
    'What are the latest guidelines for treating hypertension?',
    'Explain the differential diagnosis for chest pain',
    'What are common drug interactions with warfarin?',
    'Current best practices for diabetes management',
    'Recent advances in oncology treatments',
  ];

  static String getRandomSuggestion() {
    return suggestionPrompts[
        DateTime.now().millisecond % suggestionPrompts.length];
  }
}
