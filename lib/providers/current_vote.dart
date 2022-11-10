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

  // Future<String> get topic async {

  //   return (await query('started', []))[0];
  // }

  Future<bool> get started async {
    return (await query('started', []))[0];
  }

  Future<bool> get ended async {
    return (await query('ended', []))[0];
  }

  Future<String> get version async {
    return (await query('version', []))[0];
  }

  Future<List<int>> get results async {
    final List<int> resultsRet = [];

    int i = 0;
    while (true) {
      try {
        final resultRet = await query('results', [BigInt.from(i)]);
        resultsRet.add((resultRet[0] as BigInt).toInt());
        i++;
      } catch (e) {
        break;
      }
    }
    return resultsRet;
  }

  Future<String> beginVote(
    EthPrivateKey pk,
    String topic,
    List<String> choices,
    List<EthereumAddress> voters,
  ) async {
    return submit('beginVote', pk, [topic, choices, voters]);
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
    final result = await ethClient.sendTransaction(
      credentials,
      tx,
      chainId: int.parse(dotenv.env['CHAIN_ID']!),
    );
    ethClient.dispose();
    return result;
  }
}
