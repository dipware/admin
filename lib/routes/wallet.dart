import 'package:admin/utils/wallet_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key, required this.walletStorage}) : super(key: key);

  final WalletStorage walletStorage;
  static const routeName = '/wallet';
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Text> _wallets = [];

  @override
  void initState() {
    super.initState();
    widget.walletStorage.wallets.then((wallets) {
      setState(() {
        _wallets = wallets.map((file) {
          return Text(file.path);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ..._wallets,
          TextButton(
            style: Theme.of(context).textButtonTheme.style,
            onPressed: () {
              // widget.walletStorage.writeWallet(password);
            },
            child: const Text(
              "New Wallet",
            ),
          ),
        ],
      ),
    );
    // return FutureBuilder(builder: builder);
  }
}
