import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class CurrentVote with ChangeNotifier {
  final Future<String> _abi = rootBundle.loadString("assets/Democracy.abi");
  final String _contractAddress;
  String topic = '';
  List<String> choices = [];
  CurrentVote(this._contractAddress);

  Future<void> update() async {
    final topicRet = await query('topic', []);
    topic = topicRet[0];
    final List<String> choicesRet = [];

    int i = 0;
    while (true) {
      try {
        final choiceRet = await query('choices', [BigInt.from(i)]);
        choicesRet.add(choiceRet[0]);
        i++;
      } catch (e) {
        break;
      }
    }
    choices = choicesRet;
    notifyListeners();
  }

  Future<bool> get locked async {
    return (await query('locked', []))[0];
  }

  String get contractAddress {
    return _contractAddress;
  }

  Future<DeployedContract> get contract async {
    final abi = await _abi;
    return DeployedContract(
      ContractAbi.fromJson(abi, "Democracy"),
      EthereumAddress.fromHex(_contractAddress),
    );
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());

    final contract = await this.contract;
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    ethClient.dispose();
    return result;
  }

  Future<String> submit(
      String functionName, Credentials credentials, List<dynamic> args) async {
    final ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());
    EthereumAddress address = await credentials.extractAddress();
    final contract = await this.contract;
    final ethFunction = contract.function(functionName);
    final nonce = await ethClient.getTransactionCount(address);
    log('submit: $functionName($args) nonce: $nonce ');
    final tx = Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: args,
      nonce: nonce,
    );

    final estimate = await ethClient.estimateGas(
      sender: address,
      to: contract.address,
      data: tx.data,
    );
    log("Gas Estimate $functionName($args): $estimate");
    final result = ethClient.sendTransaction(
      credentials,
      tx,
      chainId: 5,
      // chainId: 11155111,
    );
    ethClient.dispose();
    return result;
  }
}
