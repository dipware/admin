import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import '../providers/current_vote.dart';
import 'voter_home.dart';

class PastVote {
  final String address;
  final String topic;
  final String chosen;
  final String txHash;
  // final List<int> results;

  // PastVote(this.address, this.topic, this.choices, this.results);
  PastVote(
    this.address,
    this.topic,
    this.chosen,
    this.txHash,
  );
}

class VoterHistory extends StatefulWidget {
  const VoterHistory({Key? key}) : super(key: key);

  @override
  State<VoterHistory> createState() => _VoterHistoryState();
}

class _VoterHistoryState extends State<VoterHistory> {
  final _client = Client();
  late Web3Client _ethClient;
  late StreamSubscription<String> _listener;
  bool _noHistory = false;

  // bool _init = false;
  late EthPrivateKey _credentials;
  late String _address;
  List<PastVote> pastVotes = [];
  @override
  void initState() {
    super.initState();
    _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, _client);
    _init();
  }

  @override
  void dispose() {
    super.dispose();
    _listener.cancel();
    _client.close();
    _ethClient.dispose();
  }

  Future<void> _init() async {
    final deviceId = await PlatformDeviceId.getDeviceId;
    final debugWallet = VoterHomePage.debugWallets[deviceId];
    if (debugWallet != null) {
      _credentials = EthPrivateKey.fromInt(debugWallet);
    } else {}
    _address = (await _credentials.extractAddress()).hex;
    print('address: $_address');

    _fetchHistory();
    _listener = _ethClient.addedBlocks().listen((blockHash) {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
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
    final List<PastVote> newHistory = [];
    for (final tx in result.reversed) {
      if (tx['isError'] == '1') continue;
      final txString = tx['to'] as String;
      if (txString != _address) {
        final tryVote = CurrentVote(txString);
        try {
          final version = await tryVote.version;
          if (version != '1.0') continue;
          final started = await tryVote.started;
          final ended = await tryVote.ended;
          if (started && ended) {
            final txHash = tx['hash'];
            final topic = await tryVote.query('topic', []);
            final numChoices = await tryVote.query('numChoices', []);
            final chosenI = await tryVote
                .query('voted', [await _credentials.extractAddress()]);
            final chosen = await tryVote.query('choices', [chosenI[0]]);
            final List<String> choices = [];
            for (var i = 0; i < numChoices[0].toInt(); i++) {
              final choice = await tryVote.query('choices', [BigInt.from(i)]);
              choices.add(choice[0]);
            }
            newHistory.add(PastVote(txString, topic[0], chosen[0], txHash));
          }
        } catch (_) {
          continue;
        }
      }
    }
    if (mounted && pastVotes.length != newHistory.length) {
      setState(() {
        pastVotes = newHistory;
      });
    }
    if (mounted && newHistory.isEmpty) {
      setState(() {
        _noHistory = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.info_outlined),
        onPressed: () {},
      ),
      body: pastVotes.isEmpty
          ? Center(
              child: _noHistory
                  ? const Text('Your history is empty.')
                  : const CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: pastVotes.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  title: Text(
                    pastVotes[index].topic,
                  ),
                  subtitle: Text(pastVotes[index].chosen),
                  trailing: IconButton(
                      onPressed: () async {
                        final uri = Uri.parse(
                            'https://goerli.etherscan.io/tx/${pastVotes[index].txHash}');
                        await launchUrl(uri);
                      },
                      icon: const Icon(Icons.open_in_new)),
                ),
              ),
            ),
    );
  }
}
