import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Contract {
  static Future<DeployedContract> _loadContract(String contractAddress) async {
    String abi = await rootBundle.loadString("assets/abi.json");

    final contract = DeployedContract(
      ContractAbi.fromJson(abi, "Democracy"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  static Future<List<dynamic>> query(
      String functionName, List<dynamic> args) async {
    final ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/4219bd2c584d4e788aefb96b72a3f5c9",
        Client());
    final contract = await _loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  static Future<String> submit(
      String functionName, Credentials credentials, List<dynamic> args) async {
    final ethClient = Web3Client(
      "https://rinkeby.infura.io/v3/4219bd2c584d4e788aefb96b72a3f5c9",
      Client(),
    );
    EthereumAddress address = await credentials.extractAddress();
    // EthPrivateKey credentials = EthPrivateKey.fromHex(
    //     "31dff975ff91483e5fa4c12264418599e4db311519d9d4722a97158f4fa0fcc4");
    DeployedContract contract = await _loadContract();
    final ethFunction = contract.function(functionName);
    final tx = Transaction.callContract(
        contract: contract, function: ethFunction, parameters: args);

    final estimate = await ethClient.estimateGas(
      sender: address,
      to: contract.address,
      data: tx.data,
    );
    print("Estimate: $estimate");
    final result = ethClient.sendTransaction(credentials, tx, chainId: 4);
    return result;
  }
}
