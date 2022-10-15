import 'package:admin/providers/blockchain.dart';
import 'package:admin/routes/wallet_home.dart';
import 'package:admin/utils/wallet_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class WalletsListPage extends StatefulWidget {
  const WalletsListPage({Key? key, required this.walletStorage})
      : super(key: key);
  final WalletStorage walletStorage;
  static const routeName = '/walletsList';
  @override
  State<WalletsListPage> createState() => _WalletsListPageState();
}

class _WalletsListPageState
    extends State<WalletsListPage> /*with WidgetsBindingObserver*/ {
  List<Card> _wallets = [];
  late TextEditingController _pw_controller;
  late TextEditingController _name_controller;
  final pwUnlockController = TextEditingController();
  bool _init = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    _pw_controller = TextEditingController();
    _name_controller = TextEditingController();
    // fetchWalletTiles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      fetchWalletTiles();
      _init = true;
    }
  }

  // @override
  // void didChangeAppLifecycleState()
  void fetchWalletTiles() {
    widget.walletStorage.wallets.then((wallets) {
      setState(() {
        _wallets = wallets.map((file) {
          final filename = file.uri.pathSegments.last;
          final title = filename.split('{').first;
          final addressRe = RegExp(r'0x[a-fA-F0-9]{40}');
          final address = addressRe.firstMatch(filename)![0];
          final blockchain = Provider.of<BlockChain>(context, listen: false);
          blockchain.add(address!);
          // final balance = Web3Client(url, httpClient)
          return Card(
            child: ListTile(
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Container(
                          height: 200,
                          color: Theme.of(context)
                              .bottomSheetTheme
                              .backgroundColor,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: TextField(
                                    autofocus: true,
                                    controller: pwUnlockController,
                                    onSubmitted: (password) async {
                                      final walletString =
                                          await file.readAsString();
                                      try {
                                        final wallet = Wallet.fromJson(
                                            walletString, password);
                                        pwUnlockController.clear();
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    WalletHome(
                                                      name: title,
                                                      address: address,
                                                      wallet: wallet,
                                                    )));
                                      } on ArgumentError {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return const AlertDialog(
                                                title: Text("Wrong Password."),
                                              );
                                            });
                                      }
                                    },
                                    decoration: const InputDecoration(
                                        hintText: "Enter Wallet Password"),
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    pwUnlockController.clear();
                                    Navigator.pop(context);
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
                title: Text(title),
                subtitle: Consumer<BlockChain>(
                  builder: (context, value, child) {
                    if (value.balances[address] == null) {
                      return Row(
                        children: [
                          CircularProgressIndicator(),
                        ],
                      );
                    }
                    return Text('${value.balances[address]}');
                  },
                ) // child: Text('${blockchain.balances[address]}')),
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
    // final blockchain = Provider.of<BlockChain>(context, listen: false);

    pwUnlockController.dispose();
    _pw_controller.dispose();
    _name_controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallets"),
      ),
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
                final focus = FocusNode();
                final focus2 = FocusNode();
                final focus3 = FocusNode();
                final focus4 = FocusNode();
                final _formKey = GlobalKey<FormState>();
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11.0),
                                  child: TextField(
                                    // obscureText: true,
                                    autofocus: true,
                                    textInputAction: TextInputAction.next,
                                    controller: _name_controller,
                                    decoration: const InputDecoration(
                                        hintText: "Name Your Wallet"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 11.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // onSubmitted: (value) {
                                      //   widget.walletStorage.writeWallet(
                                      //       _name_controller.text,
                                      //       _pw_controller.text);
                                      //   fetchWalletTiles();
                                      //   _pw_controller.clear();
                                      //   // Navigator.pop(context);
                                      // },
                                      Container(
                                        width: 50,
                                        child: TextFormField(
                                          focusNode: focus,
                                          onChanged: (val) {
                                            if (val != '') focus.nextFocus();
                                          },
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          obscureText: true,
                                          obscuringCharacter: '*',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 11,
                                      ),
                                      Container(
                                        width: 50,
                                        child: TextField(
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          onChanged: (val) {
                                            if (val != '') focus.nextFocus();
                                          },
                                          obscureText: true,
                                          obscuringCharacter: '*',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 11,
                                      ),
                                      Container(
                                        width: 50,
                                        child: TextField(
                                          onChanged: (val) {
                                            if (val != '') focus.nextFocus();
                                          },
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          obscureText: true,
                                          obscuringCharacter: '*',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 11,
                                      ),
                                      Container(
                                        width: 50,
                                        child: TextField(
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          obscureText: true,
                                          obscuringCharacter: '*',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                    ],
                                  ),
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
