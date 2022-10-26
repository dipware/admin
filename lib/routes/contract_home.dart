import 'dart:developer';

import 'package:admin/providers/blockchain.dart';
import 'package:admin/providers/current_vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class ContractHome extends StatefulWidget {
  const ContractHome({Key? key, required this.tx, required this.wallet})
      : super(key: key);
  final String tx;
  // final List<String> voters;
  final Wallet wallet;
  @override
  State<ContractHome> createState() => _ContractHomeState();
}

class _ContractHomeState extends State<ContractHome> {
  bool _init = false;
  @override
  Widget build(BuildContext context) {
    final contract =
        Provider.of<BlockChain>(context).contracts.singleWhere((element) {
      return element['tx'] == widget.tx;
    }, orElse: (() => {}));
    if (contract.isNotEmpty) {
      _init = true;
    }
    final currentVote = Provider.of<CurrentVoteProvider>(context)
        .query('getResults2', ["Who is your daddy?", BigInt.one]).then(
            (value) => log(value.toString()));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('tx: ${widget.tx}', overflow: TextOverflow.visible),
            Text('address: ${contract['address']}'),
            Text('wallet: ${widget.wallet}'),
          ],
        ),
      ),
    );
  }
}
