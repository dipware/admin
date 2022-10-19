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
  final _nameController = TextEditingController();
  final _pwUnlockController = TextEditingController();
  bool _init = false;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
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
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    autofocus: true,
                                    controller: _pwUnlockController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    obscureText: true,
                                    obscuringCharacter: '*',
                                    onSubmitted: (password) {
                                      final walletString =
                                          file.readAsStringSync();
                                      try {
                                        final wallet = Wallet.fromJson(
                                            walletString, password);
                                        _pwUnlockController.clear();
                                        Navigator.pushReplacementNamed(
                                          context,
                                          WalletHome.routeName,
                                          arguments: WalletArguments(
                                              title, address, wallet),
                                        );
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
                                      labelText: 'PIN',
                                      floatingLabelAlignment:
                                          FloatingLabelAlignment.center,
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    _pwUnlockController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          )),
                    );
                  },
                );
              },
              title: Text(title),
              subtitle: Consumer<BlockChain>(
                builder: (context, value, child) {
                  if (value.balances[address] == null) {
                    return Row(
                      children: const [
                        CircularProgressIndicator(),
                      ],
                    );
                  }
                  return Text('${value.balances[address]}');
                },
              ),
            ),
          );
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pwUnlockController.dispose();
    _nameController.dispose();
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
                var _pin = '';
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
                                    controller: _nameController,
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
                                      SizedBox(
                                        width: 50,
                                        child: TextFormField(
                                          focusNode: focus,
                                          onChanged: (val) {
                                            if (val != '') focus.nextFocus();
                                          },
                                          onSaved: (value) {
                                            _pin += value!;
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
                                      const SizedBox(
                                        width: 11,
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: TextFormField(
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          onChanged: (val) {
                                            if (val != '') focus.nextFocus();
                                          },
                                          onSaved: (value) {
                                            _pin += value!;
                                          },
                                          obscureText: true,
                                          obscuringCharacter: '*',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder()),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 11,
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: TextFormField(
                                          onChanged: (val) {
                                            if (val != '') focus.nextFocus();
                                          },
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          onSaved: (value) {
                                            _pin += value!;
                                          },
                                          obscureText: true,
                                          obscuringCharacter: '*',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 11,
                                      ),
                                      SizedBox(
                                        width: 50,
                                        child: TextFormField(
                                          onEditingComplete: () {
                                            _formKey.currentState!.save();
                                            widget.walletStorage.writeWallet(
                                                _nameController.text, _pin);
                                            fetchWalletTiles();
                                            _formKey.currentState!.reset();
                                            Navigator.pop(context);
                                          },
                                          onSaved: (value) {
                                            _pin += value!;
                                          },
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(1),
                                          ],
                                          obscureText: true,
                                          obscuringCharacter: '*',
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _nameController.clear();
                                    _formKey.currentState!.reset();
                                    // _pw_controller.clear();
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
