import 'dart:convert';

import 'package:admin/models/ballot.dart';
import 'package:admin/models/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../providers/blockchain.dart';

class CreateBallotForm extends StatefulWidget {
  const CreateBallotForm({Key? key, required this.wallet}) : super(key: key);
  final Wallet wallet;
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

  final Map<int, int> _qAndA = {1: 2};
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
                          items: [1, 2, 3, 4, 5]
                              .map((e) => DropdownMenuItem<int>(
                                  value: e, child: Text(e.toString())))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              for (int i = 1; i <= value!; i++) {
                                if (!_qAndA.containsKey(i)) {
                                  _qAndA[i] = 2;
                                }
                              }
                              for (int i = value + 1; i <= 5; i++) {
                                if (_qAndA.containsKey(i)) {
                                  _qAndA.remove(i);
                                }
                              }
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
                                    actionsAlignment: MainAxisAlignment.center,
                                    actions: [
                                      ElevatedButton.icon(
                                          onPressed: () {
                                            rootBundle
                                                .loadString(
                                                    'assets/democracy.json')
                                                .then((json) async {
                                              final String obj =
                                                  jsonDecode(json)['object'];
                                              final data =
                                                  intToBytes(hexToInt(obj));
                                              final blockchain =
                                                  Provider.of<BlockChain>(
                                                      context,
                                                      listen: false);
                                              final tx = await blockchain.client
                                                  .sendTransaction(
                                                widget.wallet.privateKey,
                                                Transaction(
                                                  data: data,
                                                  // maxGas: 840241,
                                                ),
                                                chainId: 5,
                                              );
                                              print(tx);
                                            });
                                          },
                                          icon: Icon(Icons.thumb_up_sharp),
                                          label: Text('Confirm'))
                                    ],
                                    content: SingleChildScrollView(
                                      child: Center(
                                        child: Column(
                                          children: [
                                            ..._ballot.questions.keys
                                                .map((i) => Column(children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.question_mark,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .background,
                                                          ),
                                                          const SizedBox(
                                                            width: 11,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                                '${_ballot.questions[i]!.text}',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .titleLarge),
                                                          ),
                                                        ],
                                                      ),
                                                      Divider(),
                                                      ..._ballot.questions[i]!
                                                          .choices.keys
                                                          .map((j) => Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .circle_outlined,
                                                                        size:
                                                                            14,
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .background,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            11,
                                                                      ),
                                                                      Expanded(
                                                                          child: Text(_ballot
                                                                              .questions[i]!
                                                                              .choices[j]!)),
                                                                    ],
                                                                  ),
                                                                  if (j !=
                                                                      _ballot
                                                                          .questions[
                                                                              i]!
                                                                          .choices
                                                                          .length)
                                                                    SizedBox(
                                                                      height: 8,
                                                                    )
                                                                ],
                                                              ))
                                                          .toList(),
                                                      SizedBox(
                                                        height: 11,
                                                      ),
                                                      const Divider(
                                                        height: 7,
                                                        thickness: 4,
                                                      ),
                                                      SizedBox(
                                                        height: 11,
                                                      ),
                                                    ]))
                                                .toList(),
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
