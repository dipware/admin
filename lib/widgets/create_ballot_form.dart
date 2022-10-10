import 'package:admin/models/ballot.dart';
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
  final ballot = Ballot();
  String _question = '';
  final _formKey = GlobalKey<FormState>();
  List<TextFormField> _choiceFields(int numberofChoices) {
    final List<TextFormField> choiceFields = [];
    for (var i = 1; i <= numberofChoices; i++) {
      choiceFields.add(TextFormField(
        onSaved: (value) {},
        decoration: InputDecoration(hintText: 'Choice $i'),
        onEditingComplete: i == numberofChoices
            ? () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                }
              }
            : null,
      ));
    }
    return choiceFields;
  }

  int _numChoices = 1;
  @override
  Widget build(BuildContext context) {
    final choiceFields = _choiceFields(_numChoices);
    return Form(
      key: _formKey,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(11.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'New Ballot',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                TextFormField(
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      hintText: "Enter A Question",
                      icon: Icon(Icons.question_mark)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    if (_formKey.currentState!.validate()) {
                      _question = value;
                    }
                  },
                ),
                SizedBox(
                  height: 11,
                ),
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
                        value: _numChoices,
                        items: [1, 2, 3, 4, 5]
                            .map((e) => DropdownMenuItem<int>(
                                value: e, child: Text(e.toString())))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _numChoices = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                ...choiceFields
              ],
            ),
          ),
        ),
      ),
    );
  }
}
