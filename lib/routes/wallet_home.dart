import 'package:admin/providers/blockchain.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';

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
