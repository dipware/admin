import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../providers/blockchain.dart';

class AccountCard extends StatefulWidget {
  final String address;
  const AccountCard({Key? key, required this.address}) : super(key: key);

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  final _units = EtherUnit.values;
  int _unitIndex = 0;
  @override
  Widget build(BuildContext context) {
    final address = widget.address;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Address: ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: Text(
                    address,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Divider(color: Theme.of(context).dividerColor),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Address: ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Expanded(
                  child: Consumer<BlockChain>(
                      builder: (context, blockchain, widget) {
                    final EtherAmount? ether = blockchain.balances[address];
                    if (ether == null) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final gwei = ether.getValueInUnit(EtherUnit.wei);
                    return Text(
                      "gwei ${EtherUnit.gwei.name}",
                      style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                DropdownButton<EtherUnit>(
                  value: _units[_unitIndex],
                  items: _units
                      .map<DropdownMenuItem<EtherUnit>>((EtherUnit value) {
                    return DropdownMenuItem<EtherUnit>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // _units.
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
