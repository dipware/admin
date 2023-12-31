import 'dart:async';
import 'dart:convert';

import 'package:admin/providers/current_vote.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class VoterProvider with ChangeNotifier {
  // final Future<String> _abi = rootBundle.loadString("assets/Democracy.abi");
  final _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, http.Client());
  CurrentVote? currentVote;
  StreamSubscription? listener;
  // String? topic;

  final EthPrivateKey voterCredentials;

  VoterProvider(this.voterCredentials) {
    _fetchContractAddress();
    listener = _ethClient.addedBlocks().listen((event) {
      _fetchContractAddress();
    });
  }
  @override
  void dispose() {
    super.dispose();
    listener?.cancel();
    _ethClient.dispose();
  }

  String? get topic {
    return currentVote?.topic;
    // currentVote?.query('topic', []).then((value) => print(value));
    // return (await currentVote?.query('topic', []))?[0] as String;
    // if (tryTopic == null) {
    //   return '';
    // }
    // return tryTopic[0];
  }

  void _fetchContractAddress() async {
    final address = await voterCredentials.extractAddress();

    final url = dotenv.env['API_URL'];
    final esKey = dotenv.env['ETHERSCAN'];

    final uri = Uri.https(url!, '/api', {
      'module': 'account',
      'action': 'txlist',
      'address': address.hex,
      'apikey': esKey,
    });

    final responseRaw = await http.get(uri);
    final response = jsonDecode(responseRaw.body) as Map<String, dynamic>;
    final List<dynamic> result = response['result'];
    for (final tx in result.reversed) {
      if (tx['isError'] == '1') continue;
      if (tx['value'] != '0') continue;
      if (tx['to'] != address.hex) continue;
      final txString = tx['input'] as String;
      final txParsed = txString.substring(txString.length - 40);
      final tryVote = CurrentVote('0x' + txParsed);
      bool started;
      bool ended;
      try {
        started = await tryVote.started;
        ended = await tryVote.ended;
      } catch (_) {
        break;
      }
      if (started == true && ended == false && currentVote == null) {
        currentVote = tryVote;
        await currentVote!.update();
        notifyListeners();
        break;
      }
      if (ended == true && currentVote != null) {
        currentVote = null;
        notifyListeners();
      }
      break;
    }
  }
}
