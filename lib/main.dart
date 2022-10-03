// import 'package:admin/routes/register.dart';
import 'package:admin/providers/blockchain.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const VoterAdminApp());
}

class VoterAdminApp extends StatefulWidget {
  const VoterAdminApp({Key? key}) : super(key: key);

  @override
  State<VoterAdminApp> createState() => _VoterAdminAppState();
}

class _VoterAdminAppState extends State<VoterAdminApp> {
  final Future<FirebaseApp> _initialization =
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BlockChain(),
      child: MaterialApp(
        home: FutureBuilder(
            future: _initialization,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                throw FirebaseException(
                    plugin: "firebase_core", message: "${snapshot.error}");
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return MaterialApp(
                  home: HomePage(),
                  theme: themeData,
                  routes: {
                    ScanPage.routeName: (_) => ScanPage(),
                    WalletsListPage.routeName: (_) =>
                        WalletsListPage(walletStorage: WalletStorage()),
                    // RegisterPage.routeName: (_) => RegisterPage(),
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voter Administrator"),
      ),
      body: const Center(
        child: Text("hi"),
      ),
    );
  }
}
