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

const _units = EtherUnit.values;

class _AccountCardState extends State<AccountCard> {
  EtherUnit _dropdownUnit = _units.first;
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
                    // style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Divider(color: Theme.of(context).dividerColor),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.end,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Balance: ',
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
                    final balance = ether.getValueInUnit(_dropdownUnit);
                    return Text(
                      "$balance",
                      // style: Theme.of(context).textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    );
                  }),
                ),
                SizedBox(
                  width: 27,
                ),
                DropdownButton<EtherUnit>(
                  alignment: Alignment.bottomCenter,
                  value: _dropdownUnit,
                  items: _units
                      .map<DropdownMenuItem<EtherUnit>>((EtherUnit value) {
                    return DropdownMenuItem<EtherUnit>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _dropdownUnit = value!;
                    });
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
