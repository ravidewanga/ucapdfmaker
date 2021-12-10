import 'package:flutter/material.dart';
import '../pages/scan_to_pdf.dart';
import '../pages/upload_pdf.dart';

class SlidingUpWidget extends StatefulWidget {
  @override
  _SlidingUpWidgetState createState() => _SlidingUpWidgetState();
}

class _SlidingUpWidgetState extends State<SlidingUpWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(20),
            height: 20,
            child: Text(
              'Choose Options:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey,
          ),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: FlatButton(
                minWidth: MediaQuery.of(context).size.width,
                child: Text('Scan to PDF'),
                //color: Colors.black,
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) =>ScanToPdf()));
                },
              ),
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey,
          ),
          UploadPdf(),
        ],
      ),
    );
  }
}
