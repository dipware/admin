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

  Future<File> writeWallet(String password) async {
    final path = await _localWalletPath;
    var random = Random.secure();
    EthPrivateKey credentials = EthPrivateKey.createRandom(random);
    final address = await credentials.extractAddress();
    final walletFile = File('$path/$address.json');
    Wallet wallet = Wallet.createNew(credentials, password, random);
    return walletFile.writeAsString(wallet.toJson());
  }

  // Future<File> loadWallet(String password) async {
  //   final path = await _localWalletPath;
  //   entities.forEach(print);
  // }

  Future<List<File>> get wallets async {
    final path = await _localWalletPath;
    final dir = Directory(path);
    await dir.create();
    print(dir.path);
    final List<FileSystemEntity> entities = await dir.list().toList();
    final files = entities.whereType<File>().toList();
    return files;
  }
}
