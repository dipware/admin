import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';

class WalletHome extends StatefulWidget {
  const WalletHome({Key? key, required this.name, required this.wallet})
      : super(key: key);
  final Wallet wallet;
  final String name;
  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Center(child: Text(widget.wallet.privateKey.toString())),
    );
  }
}
