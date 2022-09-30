import 'package:admin/utils/wallet_storage.dart';
import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key, required this.walletStorage}) : super(key: key);

  final WalletStorage walletStorage;
  static const routeName = '/wallet';
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  List<Card> _wallets = [];
  late TextEditingController _pw_controller;
  late TextEditingController _name_controller;

  @override
  void initState() {
    super.initState();
    _pw_controller = TextEditingController();
    _name_controller = TextEditingController();
    fetchWallets();
  }

  void fetchWallets() {
    widget.walletStorage.wallets.then((wallets) {
      setState(() {
        _wallets = wallets.map((file) {
          return Card(
            child: ListTile(
              title: Text(file.uri.pathSegments.last),
            ),
          );
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pw_controller.dispose();
    _name_controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                reverse: true,
                children: _wallets,
              ),
            ),
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
                        color:
                            Theme.of(context).bottomSheetTheme.backgroundColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextField(
                                autofocus: true,
                                textInputAction: TextInputAction.next,
                                controller: _name_controller,
                                decoration: const InputDecoration(
                                    hintText: "Name Your Vote"),
                              ),
                              TextField(
                                controller: _pw_controller,
                                onSubmitted: (value) {
                                  widget.walletStorage.writeWallet(
                                      _name_controller.text,
                                      _pw_controller.text);
                                  fetchWallets();
                                  _pw_controller.clear();
                                  Navigator.pop(context);
                                },
                                decoration: const InputDecoration(
                                    hintText: "Choose A Password"),
                              ),
                              ElevatedButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _name_controller.clear();
                                  _pw_controller.clear();
                                },
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
      ),
    );

    // return FutureBuilder(builder: builder);
  }
}
