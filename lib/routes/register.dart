// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart';
// import 'package:provider/provider.dart';
// import 'package:web3dart/web3dart.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({Key? key, required this.voters}) : super(key: key);
//   static const routeName = '/register';
//   final List<String> voters;

//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   bool _init = true;

//   late Client _httpClient;
//   late Web3Client _ethClient;
//   Credentials? _credentials;
//   EthereumAddress? _address;
//   EtherAmount? _balance;
//   String? _bal;
//   final List<Text> votersText = [];

//   @override
//   void initState() {
//     super.initState();
//     _httpClient = Client();
//     _ethClient = Web3Client(dotenv.env['ETH_CLIENT']!, _httpClient);
//     _ethClient.addedBlocks().listen((hash) async {
//       print("New Block:");
//       print(hash);
//       _balance = await _ethClient.getBalance(_address!);
//       _bal = _balance!.getValueInUnit(EtherUnit.gwei).toInt().toString();
//       print(_bal);
//       setState(() {});
//     });
//     print(_ethClient);
//   }

//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//     // hard-coding this for now...
//     if (_init) {
//       _credentials = EthPrivateKey.fromHex(dotenv.env['ETH_SK']!);
//       // print(_credentials.)
//       _address = await _credentials!.extractAddress();
//       _balance = await _ethClient.getBalance(_address!);
//       _bal = _balance!.getValueInUnit(EtherUnit.gwei).toInt().toString();
//       print(_bal);
//       _init = false;
//       votersText.add(Text("voters:\n"));
//       for (var element in widget.voters) {
//         votersText.add(Text(element));
//         final _voterBal = await _ethClient.getBalance(
//           EthereumAddress.fromHex(element),
//         );
//         votersText
//             .add(Text(_voterBal.getValueInUnitBI(EtherUnit.gwei).toString()));
//       }
//       votersText.add(Text("\n"));
//     }
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_address != null) print(_address!.hex);
//     // print(votersText);
//     // if (votersText.isEmpty) {
//     //   setState(() {});
//     // }

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 70),
//         child: Column(
//           children: [
//             if (votersText.isNotEmpty)
//               Expanded(
//                 child: ListView(
//                   children: votersText,
//                 ),
//               ),
//             Expanded(
//               child: Text("Balance: $_bal gwei"),
//             ),
//             Expanded(
//               child: TextButton(
//                 onPressed: () async {
//                   for (var voter in widget.voters) {
//                     final voterAddress = EthereumAddress.fromHex(voter);
//                     final txHash = await _ethClient.sendTransaction(
//                       _credentials!,
//                       Transaction(
//                         to: voterAddress,
//                         // gasPrice: EtherAmount.inWei(BigInt.from(1000000000000000)),
//                         // maxGas: 100000,
//                         value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1),
//                       ),
//                       chainId: 4,
//                     );
//                     // while (true) {
//                     //   final _newBal = await _ethClient.getBalance(_address!);
//                     //   print(_newBal);
//                     //   if (_newBal.toString() != _bal) {
//                     //     _bal = _newBal
//                     //         .getValueInUnit(EtherUnit.gwei)
//                     //         .toInt()
//                     //         .toString();
//                     //     break;
//                     //   }
//                     // }
//                     print("txHash:");
//                     print(txHash);
//                     setState(() {});
//                   }
//                 },
//                 child: const Text("Begin Vote"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
