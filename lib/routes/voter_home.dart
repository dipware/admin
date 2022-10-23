import 'dart:math';

import 'package:admin/providers/blockchain.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';

class VoterHomePage extends StatefulWidget {
  const VoterHomePage({Key? key}) : super(key: key);
  static const routeName = '/voter-home';

  @override
  State<VoterHomePage> createState() => _VoterHomePageState();
}

class _VoterHomePageState extends State<VoterHomePage> {
  bool _init = false;
  final _credentials = EthPrivateKey.createRandom(Random.secure());
  late String _address;
  late BlockChain _blockchain;
  @override
  void initState() {
    super.initState();
    _blockchain = Provider.of<BlockChain>(context, listen: false);
    _credentials.extractAddress().then((address) async {
      _blockchain.add(address.hex);
      setState(() {
        _address = address.hex;
        _init = true;
      });
    });
  }

  @override
  void dispose() {
    _blockchain.disposeAddress(_address);
    super.dispose();
  }

  void _showQR() {
    showDialog(
      context: context,
      builder: (_) {
        const size = 280.0;
        return Dialog(
          child: CustomPaint(
            size: const Size.square(size),
            painter: QrPainter(
              data: _address,
              version: QrVersions.auto,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _blockchain = Provider.of<BlockChain>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: _init
            ? Card(
                // color: Theme.of(context).cardTheme.color,
                child: Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_address),
                      Text(_blockchain.balances[_address].toString()),
                      const Text(
                        "To register, click \"Show QR\" and have the voting administrator scan the code that appears.",
                        overflow: TextOverflow.visible,
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            _showQR();
                          },
                          icon: Icon(Icons.qr_code),
                          label: Text('Show QR'))
                    ],
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
