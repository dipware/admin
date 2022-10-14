import 'package:admin/models/ballot.dart';
import 'package:admin/models/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';

class CreateBallotForm extends StatefulWidget {
  const CreateBallotForm({Key? key}) : super(key: key);

  @override
  State<CreateBallotForm> createState() => _CreateBallotFormState();
}

class _CreateBallotFormState extends State<CreateBallotForm> {
  Ballot _ballot = Ballot();
  final _formKey = GlobalKey<FormState>();
  List<Widget> _buildForm() {
    final List<Widget> widgets = [];
    for (var i = 1; i <= _qAndA.length; i++) {
      widgets.add(TextFormField(
        minLines: 1,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Question $i",
          icon: const Icon(Icons.question_mark),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'A question or statement is required.';
          }
          return null;
        },
        onSaved: (value) {
          if (_formKey.currentState!.validate()) {
            _ballot.questions[i] = Question(value!);
          }
        },
      ));
      widgets.add(const SizedBox(
        height: 11,
      ));
      widgets.add(
        Row(
          children: [
            Expanded(
              child: Text(
                "Number of Choices:",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            SizedBox(
              width: 50,
              child: DropdownButtonFormField<int>(
                value: _qAndA[i],
                items: [1, 2, 3, 4, 5]
                    .map((e) => DropdownMenuItem<int>(
                        value: e, child: Text(e.toString())))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _qAndA[i] = value!;
                  });
                },
              ),
            ),
          ],
        ),
      );
      widgets.addAll(_choiceFields(i, _qAndA[i]!));
    }
    return widgets;
  }

  List<TextFormField> _choiceFields(int qNumber, int numberofChoices) {
    final List<TextFormField> choiceFields = [];
    for (var i = 1; i <= numberofChoices; i++) {
      choiceFields.add(TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Choice text is required.';
          }
          return null;
        },
        onSaved: (choice) {
          _ballot.questions[qNumber]!.choices[i] = choice!;
        },
        decoration: InputDecoration(hintText: 'Choice $i'),
      ));
    }
    return choiceFields;
  }

  final Map<int, int> _qAndA = {1: 1};
  // int _numQuestions = 1;
  // int _numChoices = 1;
  @override
  Widget build(BuildContext context) {
    final questions = _buildForm();
    return Form(
      key: _formKey,
      child: Center(
        child: Card(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(11.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'New Ballot',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Number of Questions:",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: DropdownButtonFormField<int>(
                          value: 1,
                          // value: _numQuestions,
                          items: [1, 2, 3, 4, 5]
                              .map((e) => DropdownMenuItem<int>(
                                  value: e, child: Text(e.toString())))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              for (int i = 1; i <= value!; i++) {
                                if (!_qAndA.containsKey(i)) {
                                  _qAndA[i] = 1;
                                }
                              }
                              for (int i = value + 1; i <= 5; i++) {
                                if (_qAndA.containsKey(i)) {
                                  _qAndA.remove(i);
                                }
                              }
                              // _numQuestions = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  ...questions,
                  const SizedBox(
                    height: 11,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          _formKey.currentState!.reset();
                          // New ballot?
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        content: SingleChildScrollView(
                                      child: Center(
                                        child: Column(
                                          children: [
                                            ..._ballot.questions.keys
                                                .map((i) => Column(children: [
                                                      Row(
                                                        children: [
                                                          const Icon(Icons
                                                              .question_mark),
                                                          const SizedBox(
                                                            width: 11,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                                '${i + 1}. ${_ballot.questions[i]!.text}'),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(),
                                                      ..._ballot.questions[i]!
                                                          .choices.keys
                                                          .map((j) => Row(
                                                                children: [
                                                                  const Icon(Icons
                                                                      .circle_outlined),
                                                                  const SizedBox(
                                                                    width: 11,
                                                                  ),
                                                                  Expanded(
                                                                      child: Text(_ballot
                                                                          .questions[
                                                                              i]!
                                                                          .choices[j]!)),
                                                                ],
                                                              ))
                                                          .toList(),
                                                    ]))
                                                .toList(),
                                            const Divider(
                                              height: 7,
                                              thickness: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )));
                            _ballot = Ballot();
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('OK'),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
