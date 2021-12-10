import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../services/global.dart' as global;

class UploadPdf extends StatefulWidget {
  final ChromeSafariBrowser browser = new MyChromeSafariBrowser();
  @override
  _UploadPdfState createState() => _UploadPdfState();
}

class _UploadPdfState extends State<UploadPdf> {

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', 'Cancel', true, ScanMode.QR);
      print('bar code: ' + barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    if (barcodeScanRes.toString() != '-1') {
      await widget.browser.open(
        url: Uri.parse(barcodeScanRes),
        options: ChromeSafariBrowserClassOptions(
          android: AndroidChromeCustomTabsOptions(
            packageName: "com.android.chrome",
            addDefaultShareMenuItem: false,
            enableUrlBarHiding: false,
            toolbarBackgroundColor: global.primaryColor,
            showTitle: true,
          ),
          ios: IOSSafariOptions(barCollapsingEnabled: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: FlatButton(
          minWidth: MediaQuery.of(context).size.width,
          child: Text('Upload PDF'),
          //color: Colors.black,
          onPressed:() => scanQR(),
        ),
      ),
    );
  }
}

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() async{
    print("ChromeSafari browser closed");
  }
}