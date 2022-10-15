import 'package:admin/widgets/account_card.dart';
import 'package:admin/widgets/create_ballot_form.dart';
import 'package:admin/widgets/history.dart';
import 'package:flutter/material.dart';
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
  int _selectedIndex = 1;
  @override
  void initState() {
    super.initState();
    // rootBundle.loadString('assets/democracy.json').then((json) async {
    //   final String obj = jsonDecode(json)['object'];
    //   final data = intToBytes(hexToInt(obj));
    //   final blockchain = Provider.of<BlockChain>(context, listen: false);
    //   final tx = await blockchain.client.sendTransaction(
    //     widget.wallet.privateKey,
    //     Transaction(
    //       data: data,
    //       // maxGas: 840241,
    //     ),
    //     chainId: 5,
    //   );
    //   print(tx);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.address;
    List<Widget> _widgetOptions = <Widget>[
      AccountCard(address: address),
      const CreateBallotForm(),
      History(address: address),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
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
