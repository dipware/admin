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
  late TextEditingController _pw_controller;

  @override
  void initState() {
    super.initState();
    _pw_controller = TextEditingController();
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
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      height: 200,
                      color: Theme.of(context).bottomSheetTheme.backgroundColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              controller: _pw_controller,
                              onSubmitted: (value) {
                                widget.walletStorage
                                    .writeWallet(_pw_controller.text);
                                Navigator.pop(context);
                                setState(() {});
                              },
                              decoration: const InputDecoration(
                                  hintText: "Choose A Wallet Password"),
                            ),
                            ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
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
