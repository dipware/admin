import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/blockchain.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // void _fetchTxs() {
  //   final uri = Uri.https(url, '/api', {
  //     'module': 'account',
  //     'action': 'txlist',
  //     'address': widget.address,
  //     'apikey': widget.ESKEY,
  //   });
  //   http.get(uri).then((value) {
  //     final response = jsonDecode(value.body) as Map<String, dynamic>;
  //     final List<dynamic> result = response['result'];
  //     final List<String> fetchedAddrs = [];
  //     List<Map<String, String>> contracts = [];
  //     for (final tx in result) {
  //       if (tx['isError'] == '1') continue;
  //       final contract = tx['contractAddress'];
  //       if (contract != '') {
  //         final dateTime = DateTime.fromMillisecondsSinceEpoch(
  //             int.parse(tx['timeStamp']) * 1000);
  //         final date = DateFormat.yMMMMEEEEd().format(dateTime);
  //         final time = DateFormat.jm().format(dateTime);
  //         contracts.add({
  //           'address': tx['contractAddress'],
  //           'date': date,
  //           'time': time,
  //         });
  //       }
  //     }
  //     setState(() {
  //       _contracts = contracts;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final contracts = Provider.of<BlockChain>(context).contracts;
    return Center(
      child: contracts.isEmpty
          ? Text('Waiting for a block....')
          : ListView.builder(
              reverse: true,
              itemCount: contracts.length,
              itemBuilder: ((context, index) => Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.how_to_vote),
                          title: Text(contracts[index]['date']!),
                          trailing: Text(
                            contracts[index]['time']!,
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
