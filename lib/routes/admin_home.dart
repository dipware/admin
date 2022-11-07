import 'dart:developer';
import 'package:admin/providers/blockchain.dart';
import 'package:admin/providers/current_vote.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../models/ballot.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({
    Key? key,
    // required this.tx,
    required this.wallet,
    required this.voters,
    required this.ballot,
    required this.tx,
  }) : super(key: key);
  final String tx;
  final List<EthereumAddress> voters;
  final Ballot ballot;
  final Wallet wallet;
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());

  @override
  void initState() {
    super.initState();
    _ethClient.addedBlocks().listen((event) async {
      if (_init) {
        if (_inProgress == false) {
          _currentVote.query('inProgress', []).then((value) {
            setState(() {
              _inProgress = value[0];
            });
          });
        } else {
          final List<int> newResults = [...results];
          for (var i = 0; i < newResults.length; i++) {
            final resultsList =
                await _currentVote.query('results', [BigInt.from(i)]);
            log('Results for choice $i: $resultsList');
            newResults[i] = (resultsList.first as BigInt).toInt();
          }

          log('results: $results');
          log('newResults: $newResults');
          if (!listEquals(results, newResults)) {
            setState(() {
              log('newResults == results: ${listEquals(results, newResults)}');
              results = newResults;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ethClient.dispose();
  }

  bool _init = false;
  bool _inProgress = false;
  bool _funded = false;
  late String topic;
  late List<String> choices;
  late List<int> results;
  late CurrentVote _currentVote;
  int test = 1;
  @override
  Widget build(BuildContext context) {
    // if (test == 1) {
    //   for (var voter in widget.voters) {
    //     final tx = Transaction(
    //       to: voter,
    //       value: EtherAmount.fromUnitAndValue(EtherUnit.finney, 8),
    //     );
    //     _ethClient.sendTransaction(widget.wallet.privateKey, tx, chainId: 5);
    //   }
    //   print("OK");
    //   test++;
    // }
    if (!_funded && _inProgress) {
      print(widget.voters);
      final hexContract = _currentVote.contractAddress;
      final u8list = intToBytes(hexToInt(hexContract));
      print(u8list);
      for (var voter in widget.voters) {
        final tx = Transaction(
          to: voter,
          data: u8list,
        );
        _ethClient.sendTransaction(widget.wallet.privateKey, tx, chainId: 5);
      }
      _funded = true;
      setState(() {});
      // final tx = Transaction()

    }
    final question = widget.ballot.questions[1]!.text;
    final choices = widget.ballot.questions[1]!.choices.values.toList();
    results = List.filled(choices.length, 0);
    // log(widget.ballot.questions[1]!.text.toString());
    final contract =
        Provider.of<BlockChain>(context).contracts.singleWhere((element) {
      return element['tx'] == widget.tx;
    }, orElse: (() => {}));
    log(contract.toString());
    if (contract.isNotEmpty && _init == false) {
      _currentVote = CurrentVote(contract['address']!);
      _currentVote.query('topic', []).then((value) {
        topic = value[0];
        _currentVote.query('inProgress', []).then((value) {
          log('inProgress: ${value[0]}');
          _inProgress = value[0];
          if (value[0] == false) {
            _currentVote.submit('beginVote', widget.wallet.privateKey,
                [question, choices, widget.voters]).then((value) {
              log('beginVote: $value');
              setState(() {
                _init = true;
              });
            });
          }
        });
      });
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('tx: ${widget.tx}', overflow: TextOverflow.visible),
            if (contract.isNotEmpty) ...[
              Text('In Progress: $_inProgress'),
              Text('Topic: $question'),
              const Text('Results'),
              Text('${choices[0]}: ${results[0]}'),
              Text('${choices[0]}: ${results[1]}'),
              Text(
                'address: ${contract['address']}',
                overflow: TextOverflow.visible,
              ),
            ],
            Text('wallet: ${widget.wallet}'),
          ],
        ),
      ),
    );
  }
}
