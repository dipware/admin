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
          _started = await _currentVote.started;
          if (_started) setState(() {});
        } else {
          final List<int> newResults = await _currentVote.results;
          log('results: $results');
          log('newResults: $newResults');
          if (!listEquals(results, newResults)) {
            setState(() {
              log('newResults == results: ${listEquals(results, newResults)}');
              results = newResults;
            });
          }
        }
        if (!_ended) {
          _ended = await _currentVote.ended;
          if (_ended) setState(() {});
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

  void _beginVote(Map<String, String> contract) async {
    log(contract.toString());
    _currentVote = CurrentVote(contract['address']!);
    await _currentVote.update();
    topic = _currentVote.topic;
    _started = await _currentVote.started;
    log('started: $_started');
    if (!_started) {
      final tx = await _currentVote.beginVote(widget.wallet.privateKey,
          widget.question, widget.choices, widget.voters);
      // final receipt = await _ethClient.getTransactionReceipt(tx);
      // print(receipt!.blockNumber.toString());
      // log('beginVote: $value');
      setState(() {
        _init = true;
      });
    }
  }

  bool _init = false;
  bool _started = false;
  bool _funded = false;
  bool _ended = false;
  late String topic;
  List<int> results = [];
  late CurrentVote _currentVote;
  @override
  Widget build(BuildContext context) {
    if (_ended) Navigator.of(context).pop();
    _broadcastContract();
    final contract = _getContractMap();
    if (contract.isNotEmpty && !_init) {
      _beginVote(contract);
    }
    // _currentVote.results.then((value) => print(value));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (contract.isEmpty) const Text('Transaction Broadcasting...'),
            if (contract.isNotEmpty)
              ListTile(
                title: const Text('Contract Address'),
                subtitle: Text(contract['address']!),
              ),
            if (!_started) const Text('The vote will begin shortly'),
            if (_started && !_ended) const Text('Voting in Progress...'),
            if (_ended) const Text('Voting Complete'),
            // Text('tx: ${widget.tx}', overflow: TextOverflow.visible),
            // if (contract.isNotEmpty) ...[
            //   Text('In Progress: $_started'),
            //   Text('Topic: ${widget.question}'),
            //   const Text('Results'),
            //   Text('${widget.choices[0]}: ${results[0]}'),
            //   Text('${widget.choices[1]}: ${results[1]}'),
            //   Text(
            //     'address: ${contract['address']}',
            //     overflow: TextOverflow.visible,
            //   ),
            // ],
          ],
        ),
      ),
    );
  }
}
