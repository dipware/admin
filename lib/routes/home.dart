import 'dart:io';

import 'package:admin/routes/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

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
      backgroundColor: Theme.of(context).colorScheme.background,
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
          Padding(
            padding: const EdgeInsets.all(7.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: "Welcome to ",
                  style: Theme.of(context).textTheme.bodyText2,
                  children: const <TextSpan>[
                    const TextSpan(
                      text: "Democracy",
                      // style: _help
                      //     ? const TextStyle(
                      //         shadows: [
                      //           Shadow(color: Colors.blueGrey, blurRadius: 49)
                      //         ],
                      //         fontWeight: FontWeight.bold,
                      //         decoration: TextDecoration.underline,
                      //       )
                      //     : null,
                    ),
                    const TextSpan(text: "! If you are "),
                    const TextSpan(
                      text: "unfamiliar",
                      // style: _help
                      //     ? const TextStyle(
                      //         shadows: [
                      //           Shadow(color: Colors.blueGrey, blurRadius: 49)
                      //         ],
                      //         fontWeight: FontWeight.bold,
                      //         decoration: TextDecoration.underline,
                      //       )
                      //     : null,
                    ),
                    const TextSpan(
                        text: " with anything, or would just like to "),
                    const TextSpan(
                      text: "learn",
                      // recognizer: TapGestureRecognizer()..onTap = _tapLearn,
                      // style: _help
                      //     ? const TextStyle(
                      //         shadows: [
                      //           Shadow(color: Colors.blueGrey, blurRadius: 49)
                      //         ],
                      //         fontWeight: FontWeight.bold,
                      //         decoration: TextDecoration.underline,
                      //       )
                      //     : null,
                    ),
                    const TextSpan(text: " how this app "),
                    const TextSpan(
                      text: "works",
                      // style: _help
                      //     ? const TextStyle(
                      //         shadows: [
                      //           Shadow(color: Colors.blueGrey, blurRadius: 49)
                      //         ],
                      //         fontWeight: FontWeight.bold,
                      //         decoration: TextDecoration.underline,
                      //       )
                      //     : null,
                    ),
                    const TextSpan(
                        text:
                            ", tap the question mark at the top right, then click on the underlined text that appears. If you're all set, tap the button below to begin "),
                    const TextSpan(
                      text: "the voting process",
                      // style: _help
                      //     ? const TextStyle(
                      //         shadows: [
                      //           Shadow(color: Colors.blueGrey, blurRadius: 49)
                      //         ],
                      //         fontWeight: FontWeight.bold,
                      //         decoration: TextDecoration.underline,
                      //       )
                      //     : null,
                    ),
                    const TextSpan(text: "."),
                  ]),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: Theme.of(context).textButtonTheme.style,
                onPressed: () {
                  Navigator.pushNamed(context, WalletPage.routeName);
                },
                child: const Text(
                  "Get Started",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
