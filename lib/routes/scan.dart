import 'dart:developer';

import 'package:admin/providers/blockchain.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  static const routeName = '/scan';
  @override
  State<StatefulWidget> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final List<String> _voterKeys = [];

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller!.pauseCamera();
  //   }
  //   controller!.resumeCamera();
  // }

  @override
  Widget build(BuildContext context) {
    final _blockchain = Provider.of<BlockChain>(context);
    // var _contract = _blockchain.contracts.last;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 3, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Theme.of(context).backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  if (_voterKeys.isNotEmpty)
                    Text(
                      "Number of registered Voters: ${_voterKeys.length}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  else
                    Text(
                      "Scan a voter's QR code to register them.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  Text(_blockchain.contracts.first['tx']!),
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(_voterKeys);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text("Begin Vote!"))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen(
      (scanData) {
        // print(scanData.code);
        setState(() {
          // result = scanData;
          if (!_voterKeys.contains(scanData.code)) {
            _voterKeys.add(scanData.code!);
          }
        });
      },
    );
    controller.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must allow camera permission.')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
