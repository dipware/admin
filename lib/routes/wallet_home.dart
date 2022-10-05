import 'dart:convert';
import 'dart:typed_data';

import 'package:admin/providers/blockchain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class WalletHome extends StatefulWidget {
  const WalletHome(
      {Key? key,
      required this.name,
      required this.address,
      required this.wallet})
      : super(key: key);
  final Wallet wallet;
  final String name;
  final String address;
  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/democracy.json').then((json) async {
      final String obj = jsonDecode(json)['object'];
      final data = Uint8List.fromList(obj.codeUnits);
      final blockchain = Provider.of<BlockChain>(context, listen: false);
      final tx = await blockchain.client.sendTransaction(
        widget.wallet.privateKey,
        Transaction(
          data: data,
          gasPrice: EtherAmount.inWei(BigInt.from(1000)),
          maxGas: 1000000,
          value: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 1),
        ),
        chainId: 5,
      );
      print(tx);
      // Transaction(data: )
    });
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.address;
    print(address);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(address, maxLines: 2),
          Consumer<BlockChain>(
              builder: (context, blockchain, widget) =>
                  Text("${blockchain.balances[address]}")),
        ],
      )),
    );
  }
}
