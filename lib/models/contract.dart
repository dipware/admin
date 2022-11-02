import 'dart:developer';
import 'dart:io';

import 'package:admin/providers/blockchain.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class Contract {
  final _bin = rootBundle.loadString('assets/Democracy.bin');

  Future<String> deploy(Credentials credentials) async {
    final ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, Client());

    final bin = await _bin;
    final data = intToBytes(hexToInt(bin));
    final nonce =
        await ethClient.getTransactionCount(await credentials.extractAddress());
    log('deploy: nonce: $nonce');
    final tx = ethClient.sendTransaction(
      credentials,
      Transaction(
        data: data,
        // maxGas: 840241,
        nonce: nonce,
      ),
      chainId: 11155111,
      // chainId: 1337,
      // chainId: 5,
    );
    ethClient.dispose();
    return tx;
  }

  // Future<DeployedContract> get contract async {
  //   final abi = await _abi;
  //   return DeployedContract(
  //     ContractAbi.fromJson(abi, "Democracy"),
  //     EthereumAddress.fromHex(_address!),
  //   );
  // }
}
