import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/blockchain.dart';
import 'routes/voter_home.dart';
import 'routes/voter_portal.dart';
import 'routes/wallet_home.dart';
import 'routes/wallets_list.dart';
import 'routes/home.dart';
import 'routes/scan.dart';
import 'utils/wallet_storage.dart';
import 'utils/style.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const DemocracyApp());
}

class Abi {}

class DemocracyApp extends StatefulWidget {
  const DemocracyApp({Key? key}) : super(key: key);
  @override
  State<DemocracyApp> createState() => _VoterAdminAppState();
}

class _VoterAdminAppState extends State<DemocracyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BlockChain(),
      child: MaterialApp(
        home: const HomePage(),
        theme: themeData,
        routes: {
          WalletsListPage.routeName: (_) => WalletsListPage(
                walletStorage: WalletStorage(),
              ),
          VoterHomePage.routeName: (_) => const VoterHomePage(),
          WalletHome.routeName: (_) => const WalletHome(),
          VoterPortal.routeName: (_) => const VoterPortal(),
        },
      ),
    );
  }
}
