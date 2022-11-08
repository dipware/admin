import 'dart:developer';
import 'dart:math' show Random;

import 'package:admin/providers/blockchain.dart';
import 'package:admin/providers/current_vote.dart';
import 'package:admin/providers/voter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';

class VoterHomePage extends StatefulWidget {
  const VoterHomePage({Key? key}) : super(key: key);
  static const routeName = '/voter-home';
  static final debugWallets = {
    'abec252391ad66da': BigInt.parse(
        '15043717695140332682558097238266635970346397516495910877169895166854773207782'),
    '37183e5a5dbc3a79': BigInt.parse(
        '76555029709533789746331995381358346089419595512787248939815650549795856978026'),
  };

  @override
  State<VoterHomePage> createState() => _VoterHomePageState();
}

class _VoterHomePageState extends State<VoterHomePage> {
  bool _init = false;
  late EthPrivateKey _credentials;
  late String _address;
  late BlockChain _blockchain;
  late VoterProvider _voter;
  @override
  void initState() {
    super.initState();
    // _generateDebugWallet();
    _initDebugWallet();
  }

  Future<void> _initDebugWallet() async {
    final deviceId = await PlatformDeviceId.getDeviceId;
    _blockchain = Provider.of<BlockChain>(context, listen: false);
    _credentials = EthPrivateKey.fromInt(VoterHomePage.debugWallets[deviceId]!);
    _voter = VoterProvider(_credentials);
    _voter.addListener(() async {
      if (_voter.currentVote != null && !_started) {
        _started = true;
        setState(() {});
      }
    });
    _address = (await _credentials.extractAddress()).hex;
    log('Voter address: $_address');
    _blockchain.add(_address);
    _init = true;
    setState(() {});
  }
  // Uncomment to make a static wallet
  // Future<void> _generateDebugWallet() async {
  //   final deviceId = await PlatformDeviceId.getDeviceId;
  //   log(deviceId!);
  //   _credentials = EthPrivateKey.createRandom(Random.secure());
  //   log(_credentials.privateKeyInt.toString());
  // }

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

  bool _started = false;
  @override
  Widget build(BuildContext context) {
    if (_started) {
      print(_voter.currentVote!.choices);
      // _voter.currentVote!.query('locked', []).then((value) => print(value));
    }
    // if (_started) print(_voter.currentVote!.topic);
    final _blockchain = Provider.of<BlockChain>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: _init
            ? Card(
                child: Padding(
                  padding: const EdgeInsets.all(11.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: !_started
                        ? ([
                            Text(_address),
                            Text(
                                '${_blockchain.balances[_address]?.getValueInUnit(EtherUnit.ether)}'),
                            const Text(
                              "To register, click \"Show QR\" and have the voting administrator scan the code that appears.",
                              overflow: TextOverflow.visible,
                            ),
                            ElevatedButton.icon(
                                onPressed: _showQR,
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Show QR'))
                          ])
                        : ([
                            Text(_voter.currentVote!.contractAddress),
                            // Text(_voter.currentVote!.started.toString()),
                            Text(_voter.currentVote!.topic),
                            ..._voter.currentVote!.choices
                                .map((e) => Text(e))
                                .toList(),
                            ElevatedButton(
                              child: Text('Vote'),
                              onPressed: () {
                                _voter.currentVote!.submit(
                                    'sendBallot',
                                    _credentials,
                                    [BigInt.one]).then((value) => print(value));
                              },
                            )
                          ]),
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
