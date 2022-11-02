import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:web3dart/web3dart.dart';

class WalletStorage {
  Future<String> get _localWalletPath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/wallets';
  }

  Future<File> writeWallet(String name, String password) async {
    final path = await _localWalletPath;
    var random = Random.secure();
    // TODO remove when done testing
    // EthPrivateKey credentials = EthPrivateKey.createRandom(random);
    final credentials = EthPrivateKey.fromHex(
        '0x7dbf308e2042e043d0dd229eac765dd610a305888624688674434ca5bf79a11b');

    final address = await credentials.extractAddress();
    final walletFile = File('$path/$name{${address.hex}}.json');
    Wallet wallet = Wallet.createNew(credentials, password, random);
    return walletFile.writeAsString(wallet.toJson());
  }

  Future<List<File>> get wallets async {
    final path = await _localWalletPath;
    final dir = Directory(path);
    await dir.create();
    final List<FileSystemEntity> entities = await dir.list().toList();
    final files = entities.whereType<File>().toList();
    return files;
  }
}
