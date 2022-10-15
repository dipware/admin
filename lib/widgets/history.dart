import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/blockchain.dart';

class History extends StatefulWidget {
  History({Key? key, required this.address}) : super(key: key);
  final String address;
  final ESKEY = dotenv.env['ETHERSCAN'];

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool _init = false;
  late StreamSubscription<String> _listener;
  final url = 'api-goerli.etherscan.io';
  List<String> creationAddrs = [];
  List<Map<String, String>> _contracts = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _listener =
          Provider.of<BlockChain>(context).client.addedBlocks().listen((_) {
        _fetchTxs();
      });
      _init = true;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _listener.cancel();
  }

  void _fetchTxs() {
    final uri = Uri.https(url, '/api', {
      'module': 'account',
      'action': 'txlist',
      'address': widget.address,
      'apikey': widget.ESKEY,
    });
    http.get(uri).then((value) {
      final response = jsonDecode(value.body) as Map<String, dynamic>;
      final List<dynamic> result = response['result'];
      final List<String> fetchedAddrs = [];
      List<Map<String, String>> contracts = [];
      for (final tx in result) {
        if (tx['isError'] == '1') continue;
        final contract = tx['contractAddress'];
        if (contract != '') {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(
              int.parse(tx['timeStamp']) * 1000);
          final date = DateFormat.yMMMMEEEEd().format(dateTime);
          final time = DateFormat.jm().format(dateTime);
          contracts.add({
            'address': tx['contractAddress'],
            'date': date,
            'time': time,
          });
        }
      }
      setState(() {
        _contracts = contracts;
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _contracts.isEmpty
          ? Text('Waiting for a block....')
          : ListView.builder(
              reverse: true,
              itemCount: _contracts.length,
              itemBuilder: ((context, index) => Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.how_to_vote),
                          title: Text(_contracts[index]['date']!),
                          trailing: Text(
                            _contracts[index]['time']!,
                          ),
                        ),
                        Divider()
                      ],
                    ),
                  )),
            ),
    );
  }
}
