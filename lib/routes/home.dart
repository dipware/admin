import 'package:flutter/material.dart';

import '../routes/voter_home.dart';
import '../routes/wallets_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('δημοκρατία'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: Image.asset(
              "assets/justice.png",
              height: 100,
              width: 100,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(11.0),
            child: Text('Welcome to Democracy!'),
          ),
          const Padding(
              padding: EdgeInsets.all(11.0),
              child: Text(
                'Democracy is a voting app that lets you audit your own vote!',
                overflow: TextOverflow.visible,
              )),
          const Padding(
              padding: EdgeInsets.all(11.0),
              child: Text(
                'Are you a voter or an administrator?',
                overflow: TextOverflow.visible,
              )),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, WalletsListPage.routeName);
                },
                child: const Text(
                  "Administrator",
                ),
              ),
              // const SizedBox(
              //   width: 70,
              // ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, VoterHomePage.routeName);
                },
                child: const Text(
                  "Voter",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
