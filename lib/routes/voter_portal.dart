import 'dart:async';
import 'dart:developer';

import 'package:admin/providers/blockchain.dart';
import 'package:admin/routes/voter_history.dart';
import 'package:admin/routes/voter_home.dart';
import 'package:admin/widgets/account_card.dart';
import 'package:admin/widgets/create_ballot_form.dart';
import 'package:admin/widgets/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/web3dart.dart';

// class WalletArguments {
//   final String name;
//   final String address;
//   final Wallet wallet;
//   WalletArguments(this.name, this.address, this.wallet);
// }

class VoterPortal extends StatefulWidget {
  static const routeName = '/voterPortal';
  const VoterPortal({
    Key? key,
  }) : super(key: key);
  @override
  State<VoterPortal> createState() => _VoterPortalState();
}

class _VoterPortalState extends State<VoterPortal> {
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      const VoterHomePage(),
      const VoterHistory(),
    ];
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.ballot), label: 'Vote'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).toggleableActiveColor,
        onTap: (index) {
          if (mounted) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
    );
  }
}
