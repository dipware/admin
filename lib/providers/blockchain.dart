import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class BlockChain with ChangeNotifier {
  final _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());
  final _balances = {};
  final Map<String, StreamSubscription<String>> _listeners = {};
  List<Map<String, String>> _contracts = [];

  Future<StreamSubscription<String>> add(String address) async {
    if (_balances[address] != null) {
      throw Exception('Double reference');
    }
    final ethAddress = EthereumAddress.fromHex(address);
    _balances[address] = await _ethClient.getBalance(ethAddress);
    notifyListeners();
    final listener = _ethClient.addedBlocks().listen((hash) async {
      final newBalance = await _ethClient.getBalance(ethAddress);
      if (_balances[address] != newBalance) {
        _balances[address] = newBalance;
        notifyListeners();
      }
    });
    _listeners[address] = listener;
    return listener;
    // make add all return all listeners
  }

  void disposeAddress(String address) {
    if (_balances[address] != null) {
      _balances.remove(address);
      _listeners[address]!.cancel();
      _listeners.remove(address);
    }
  }

  StreamSubscription<String> addContracts(String address) {
    _fetchTxs(address);
    return _ethClient.addedBlocks().listen((event) {
      _fetchTxs(address);
    });
  }

  void _fetchTxs(String address) async {
    const url = 'api-sepolia.etherscan.io';
    final esKey = dotenv.env['ETHERSCAN'];

    final uri = Uri.https(url, '/api', {
      'module': 'account',
      'action': 'txlist',
      'address': address,
      'apikey': esKey,
    });
    final responseRaw = await http.get(uri);
    final response = jsonDecode(responseRaw.body) as Map<String, dynamic>;
    final List<dynamic> result = response['result'];
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
          'tx': tx['hash'],
          'date': date,
          'time': time,
        });
      }
    }
    if (_contracts.length != contracts.length) {
      _contracts = contracts;
      notifyListeners();
    }
  }

  Map<String, EtherAmount> get balances {
    return {..._balances};
  }

  List<Map<String, String>> get contracts {
    return [..._contracts];
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
