import 'dart:async';

import 'package:admin/providers/blockchain.dart';
import 'package:admin/widgets/account_card.dart';
import 'package:admin/widgets/create_ballot_form.dart';
import 'package:admin/widgets/history.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

class WalletArguments {
  final String name;
  final String address;
  final Wallet wallet;
  WalletArguments(this.name, this.address, this.wallet);
}

class WalletHome extends StatefulWidget {
  static const routeName = '/walletHome';
  const WalletHome({
    Key? key,
    // required this.name,
    // required this.address,
    // required this.wallet
  }) : super(key: key);
  // final Wallet wallet;
  // final String name;
  // final String address;
  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  int _selectedIndex = 1;
  late StreamSubscription<String> _historyListener;
  bool _init = false;
  @override
  void initState() {
    super.initState();
    // _historyListener = Provider.of<BlockChain>(context, listen: false)
    //     .addContracts(_args.address);
  }

  @override
  void dispose() {
    super.dispose();
    _historyListener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final _args = ModalRoute.of(context)!.settings.arguments as WalletArguments;
    if (!_init) {
      _historyListener = Provider.of<BlockChain>(context, listen: false)
          .addContracts(_args.address);
      _init = true;
    }
    final address = _args.address;
    List<Widget> _widgetOptions = <Widget>[
      AccountCard(address: address),
      CreateBallotForm(
        wallet: _args.wallet,
      ),
      History(
        wallet: _args.wallet,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_args.name),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Account'),
          BottomNavigationBarItem(
              icon: Icon(Icons.ballot), label: 'New Ballot'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).toggleableActiveColor,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
