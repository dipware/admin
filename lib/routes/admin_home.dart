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
  AdminHome({
    Key? key,
    // required this.tx,
    required this.wallet,
    required this.voters,
    required this.ballot,
    required this.tx,
  }) : super(key: key) {
    question = ballot.questions[1]!.text;
    choices = ballot.questions[1]!.choices.values.toList();
    results = List.filled(choices.length, 0);
  }
  final String tx;
  final List<EthereumAddress> voters;
  final Ballot ballot;
  final Wallet wallet;
  late String question;
  late List<String> choices;
  late List<int> results;
  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());
  @override
  void initState() {
    super.initState();
    results = widget.results;
    _ethClient.addedBlocks().listen((event) async {
      if (_init) {
        if (_started == false) {
          _currentVote.query('started', []).then((value) {
            setState(() {
              _started = value[0];
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

  void _broadcastContract() {
    if (!_funded && _started) {
      final hexContract = _currentVote.contractAddress;
      final u8list = intToBytes(hexToInt(hexContract));
      for (var voter in widget.voters) {
        final tx = Transaction(
          to: voter,
          data: u8list,
        );
        _ethClient.sendTransaction(
          widget.wallet.privateKey,
          tx,
          chainId: int.parse(dotenv.env['CHAIN_ID']!),
        );
      }
      _funded = true;
      setState(() {});
    }
  }

  Map<String, String> _getContractMap() {
    return Provider.of<BlockChain>(context).contracts.singleWhere((element) {
      return element['tx'] == widget.tx;
    }, orElse: (() => {}));
  }

  void _beginVote(Map<String, String> contract) {
    log(contract.toString());
    if (contract.isNotEmpty && _init == false) {
      _currentVote = CurrentVote(contract['address']!);
      _currentVote.query('topic', []).then((value) {
        topic = value[0];
        _currentVote.query('started', []).then((value) {
          log('started: ${value[0]}');
          _started = value[0];
          if (value[0] == false) {
            _currentVote.submit('beginVote', widget.wallet.privateKey,
                [widget.question, widget.choices, widget.voters]).then((value) {
              log('beginVote: $value');
              setState(() {
                _init = true;
              });
            });
          }
        });
      });
    }
  }

  bool _init = false;
  bool _started = false;
  bool _funded = false;
  late String topic;
  List<int> results = [];
  late CurrentVote _currentVote;
  @override
  Widget build(BuildContext context) {
    _broadcastContract();
    final contract = _getContractMap();
    _beginVote(contract);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text('tx: ${widget.tx}', overflow: TextOverflow.visible),
            if (contract.isNotEmpty) ...[
              Text('In Progress: $_started'),
              Text('Topic: ${widget.question}'),
              const Text('Results'),
              Text('${widget.choices[0]}: ${results[0]}'),
              Text('${widget.choices[1]}: ${results[1]}'),
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
