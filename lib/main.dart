import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VoterAdminApp());
}

class VoterAdminApp extends StatefulWidget {
  const VoterAdminApp({Key? key}) : super(key: key);

  @override
  State<VoterAdminApp> createState() => _VoterAdminAppState();
}

class _VoterAdminAppState extends State<VoterAdminApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context, snapshot) {
      if (snapshot.hasError) {
        throw FirebaseException(
            plugin: "firebase_core", message: "Error in initialization");
      }
      if (snapshot.connectionState == ConnectionState.done) {
        return MyHomePage();
      }
      return Center(
        child: CircularProgressIndicator(),
      );
    });
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
