import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class CurrentVote {
  final _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());
  final Future<String> _abi = rootBundle.loadString("assets/Democracy.abi");
  final String _contractAddress;
  CurrentVote(this._contractAddress);

  Future<DeployedContract> get contract async {
    final abi = await _abi;
    return DeployedContract(
      ContractAbi.fromJson(abi, "Democracy"),
      EthereumAddress.fromHex(_contractAddress),
    );
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await this.contract;
    final ethFunction = contract.function(functionName);
    final result = await _ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<String> submit(
      String functionName, Credentials credentials, List<dynamic> args) async {
    EthereumAddress address = await credentials.extractAddress();
    final contract = await this.contract;
    final ethFunction = contract.function(functionName);
    final nonce = await _ethClient.getTransactionCount(address);
    log('submit: $functionName($args) nonce: $nonce ');
    final tx = Transaction.callContract(
      contract: contract,
      function: ethFunction,
      parameters: args,
      nonce: nonce,
    );

    final estimate = await _ethClient.estimateGas(
      sender: address,
      to: contract.address,
      data: tx.data,
    );
    log("Gas Estimate $functionName($args): $estimate");
    final result = _ethClient.sendTransaction(
      credentials,
      tx,
      // chainId: 5,
      chainId: 11155111,
    );
    return result;
  }
}
