import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class History extends StatefulWidget {
  History({Key? key}) : super(key: key);
  final ESKEY = dotenv.env['ETHERSCAN'];

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final _httpClient = Client();
  final url = 'https://api-goerli.etherscan.io/';
  @override
  void initState() {
    super.initState();
    final response = _httpClient.get(Uri(path: '$url'))

  }
  @override
  Widget build(BuildContext context) {

  }

}
