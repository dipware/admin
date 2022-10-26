import 'package:admin/providers/current_vote.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../providers/blockchain.dart';
import '../routes/contract_home.dart';

class History extends StatefulWidget {
  const History({Key? key, required this.wallet}) : super(key: key);
  final Wallet wallet;

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    final contracts =
        Provider.of<BlockChain>(context).contracts.reversed.toList();
    return Center(
      child: contracts.isEmpty
          ? const Text('....')
          : ListView.builder(
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: ((context) =>
                                    ChangeNotifierProvider<CurrentVoteProvider>(
                                      create: (_) => CurrentVoteProvider(
                                          contracts[index]['address']!),
                                      child: ContractHome(
                                        tx: contracts[index]['tx']!,
                                        wallet: widget.wallet,
                                      ),
                                    )),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                      ],
                    ),
                  )),
            ),
    );
  }
}
