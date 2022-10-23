// import 'package:admin/routes/register.dart';
import 'package:admin/providers/blockchain.dart';
import 'package:admin/routes/voter_home.dart';
import 'package:admin/routes/wallet_home.dart';
import 'package:admin/routes/wallets_list.dart';
import 'package:admin/utils/wallet_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'routes/home.dart';
import 'routes/scan.dart';
import 'utils/style.dart';

import 'firebase_options.dart';
import 'routes/register.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const VoterAdminApp());
}

class VoterAdminApp extends StatefulWidget {
  const VoterAdminApp({Key? key}) : super(key: key);

  @override
  State<VoterAdminApp> createState() => _VoterAdminAppState();
}

class _VoterAdminAppState extends State<VoterAdminApp> {
  // final Future<FirebaseApp> _initialization =
  //     Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => BlockChain(),
        child: MaterialApp(
          home: const HomePage(),
          theme: themeData,
          routes: {
            ScanPage.routeName: (_) => ScanPage(),
            WalletsListPage.routeName: (_) => WalletsListPage(
                  walletStorage: WalletStorage(),
                ),
            VoterHomePage.routeName: (_) => VoterHomePage(),
            // WalletHome.routeName: (_) => WalletHome(),
            // RegisterPage.routeName: (_) => RegisterPage(),
          },
        ));
  }
}
