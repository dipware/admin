import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class BlockChain with ChangeNotifier {
  final _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());
  final _balances = {};
  final _listeners = {};

  void add(String address) {
    if (_balances[address] != null) {
      print("ADD RETURN");
      return;
    }
    final ethAddress = EthereumAddress.fromHex(address);
    final listener = _ethClient.addedBlocks().listen((hash) async {
      final newBalance = await _ethClient.getBalance(ethAddress);
      print(newBalance);
      if (_balances[address] != newBalance) {
        _balances[address] = newBalance;
        notifyListeners();
      }
    });
    _listeners[address] = listener;
  }

  Map get balances {
    return {..._balances};
  }

  Web3Client get client {
    return _ethClient;
  }
  // BlockChain() {

  //   _ethClient.addedBlocks().listen((hash) async {
  //     print("New Block:");
  //     print(hash);
  //     _balance = await _ethClient.getBalance(_address!);
  //     _bal = _balance!.getValueInUnit(EtherUnit.gwei).toInt().toString();
  //     print(_bal);
  //     setState(() {});
  //   });
  // }
}
