import 'question.dart';

class Ballot {
  final List<Question> questions = [];
  set addQuestion(Question question) {
    questions.add(question);
  }
}
