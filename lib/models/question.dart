class Question {
  final String text;
  final List<String> choices = [];
  Question(this.text);
  set addChoice(String choice) {
    choices.add(choice);
  }
}
