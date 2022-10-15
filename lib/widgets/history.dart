import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class History extends StatefulWidget {
  History({Key? key, required this.address}) : super(key: key);
  final String address;
  final ESKEY = dotenv.env['ETHERSCAN'];

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final url = 'api-goerli.etherscan.io';
  final List<String> creationTxs = [];
  @override
  void initState() {
    super.initState();
    final uri = Uri.https(url, '/api', {
      'module': 'account',
      'action': 'txlist',
      // 'txhash':
      //     '0x8c5ff153d6bb0bf9fec5c81ef561a70bfaa49d0d3e452b88de817145a2ceb696',
      'address': widget.address,
      'apikey': widget.ESKEY,
    });
    http.get(uri).then((value) {
      final response = jsonDecode(value.body) as Map<String, dynamic>;
      final List<dynamic> result = response['result'];
      // print(result);
      result.forEach((element) {
        final contract = element['contractAddress'];
        // if (element['to'] == '') {
        //   print(element['hash']);
        // }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('test', maxLines: 4),
    );
  }
}
