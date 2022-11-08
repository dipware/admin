import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../providers/blockchain.dart';
import '../providers/current_vote.dart';
import 'voter_home.dart';
import 'package:http/http.dart' as http;

class PastVote {
  final String address;
  final String topic;
  final String chosen;
  // final List<int> results;

  // PastVote(this.address, this.topic, this.choices, this.results);
  PastVote(
    this.address,
    this.topic,
    this.chosen,
  );
}

class VoterHistory extends StatefulWidget {
  const VoterHistory({Key? key}) : super(key: key);

  @override
  State<VoterHistory> createState() => _VoterHistoryState();
}

class _VoterHistoryState extends State<VoterHistory> {
  bool _init = false;
  late EthPrivateKey _credentials;
  late String _address;
  final List<PastVote> pastVotes = [];
  @override
  void initState() {
    super.initState();
    _initDebugWallet();
  }

  Future<void> _initDebugWallet() async {
    final deviceId = await PlatformDeviceId.getDeviceId;
    _credentials = EthPrivateKey.fromInt(VoterHomePage.debugWallets[deviceId]!);
    _address = (await _credentials.extractAddress()).hex;
    print('address: $_address');
    await _fetchContractAddress();
    _init = true;
    setState(() {});
  }

  Future<void> _fetchContractAddress() async {
    final url = dotenv.env['API_URL'];
    final esKey = dotenv.env['ETHERSCAN'];

    final uri = Uri.https(url!, '/api', {
      'module': 'account',
      'action': 'txlist',
      'address': _address,
      'apikey': esKey,
    });

    final responseRaw = await http.get(uri);
    final response = jsonDecode(responseRaw.body) as Map<String, dynamic>;
    final List<dynamic> result = response['result'];
    for (final tx in result.reversed) {
      if (tx['isError'] == '1') continue;
      final txString = tx['to'] as String;
      if (txString != _address) {
        print('input: $txString');
        final tryVote = CurrentVote(txString);
        try {
          final version = await tryVote.version;
          if (version != '1.0') continue;
          final started = await tryVote.started;
          final ended = await tryVote.ended;
          print('started $started');
          print('ended $ended');
          if (started && ended) {
            final topic = await tryVote.query('topic', []);
            final numChoices = await tryVote.query('numChoices', []);
            final chosenI = await tryVote
                .query('voted', [await _credentials.extractAddress()]);
            final chosen = await tryVote.query('choices', [chosenI[0]]);
            print(chosen);
            final List<String> choices = [];
            for (var i = 0; i < numChoices[0].toInt(); i++) {
              final choice = await tryVote.query('choices', [BigInt.from(i)]);
              print(choice);
              choices.add(choice[0]);
            }
            print(choices);

            pastVotes.add(PastVote(txString, topic[0], chosen[0]));
            setState(() {});
          }
        } catch (_) {
          continue;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: pastVotes.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(
              pastVotes[index].topic,
            ),
            subtitle: Text('${pastVotes[index].chosen}'),
          ),
        ),
      ),
    );
  }
}
