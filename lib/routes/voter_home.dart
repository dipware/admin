import 'dart:developer';
import 'dart:math' show Random;

import 'package:admin/providers/blockchain.dart';
import 'package:admin/providers/voter.dart';
import 'package:flutter/material.dart';
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
    '78e37e6ec356cd09': BigInt.parse(
        '11027627383034436861187369159197213432530852012610122801407531803512274524952'),
    '18734e0e47ca18c0': BigInt.parse(
        '53963810371553428652596819919610577118524208586402337969589826365253033231347'),
    '7d735c0acd91396f': BigInt.parse(
        '109733987977077361344826650447789494570733044674112098766831418219859585067880'),
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
  bool _disableButtons = false;
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
      if (_voter.currentVote != null) {
        _inProgress = true;
      } else {
        _inProgress = false;
      }
      if (mounted) setState(() {});
    });
    _address = (await _credentials.extractAddress()).hex;
    log('Voter address: $_address');
    _blockchain.add(_address);
    _init = true;

    if (mounted) setState(() {});
  }

  // Uncomment to make a static wallet
  Future<void> _generateDebugWallet() async {
    final deviceId = await PlatformDeviceId.getDeviceId;
    print(deviceId!);
    _credentials = EthPrivateKey.createRandom(Random.secure());
    print(_credentials.privateKeyInt.toString());
  }

  @override
  void dispose() {
    _blockchain.disposeAddress(_address);
    _voter.listener?.cancel();
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

  Widget _cardTitle() {
    final address = _voter.currentVote!.contractAddress;
    return ListTile(
      title: const Text('Vote/Contract Address'),
      subtitle: Text(address),
      // trailing:
      //     IconButton(onPressed: () {}, icon: const Icon(Icons.open_in_browser)),
    );
  }

  Widget _topic() {
    final topic = _voter.currentVote!.topic;
    return ListTile(
      title: const Text('Topic'),
      subtitle: Text(topic),
    );
  }

  Widget _choices() {
    final choices = _voter.currentVote!.choices;
    final List<Widget> buttons = [];
    for (var choice in choices) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            child: Text(choice),
            onPressed: _disableButtons
                ? null
                : () async {
                    await _voter.currentVote!.submit('sendBallot', _credentials,
                        [BigInt.from(choices.indexOf(choice))]);
                    setState(() {
                      _disableButtons = true;
                    });
                  },
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons,
    );
  }

  bool _inProgress = false;
  @override
  Widget build(BuildContext context) {
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
                    children: !_inProgress
                        ? ([
                            const Text(
                              "To register, click \"Show QR\" and have the voting administrator scan the code that appears.",
                              overflow: TextOverflow.visible,
                            ),
                            const Divider(),
                            const Text(
                              'Your Ballot will appear here when voting has started.',
                              overflow: TextOverflow.visible,
                            ),
                            const Divider(),
                            ElevatedButton.icon(
                                onPressed: _showQR,
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Show QR'))
                          ])
                        : ([
                            _cardTitle(),
                            _topic(),
                            _choices(),
                          ]),
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
