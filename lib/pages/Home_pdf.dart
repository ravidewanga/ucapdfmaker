import 'package:flutter/material.dart';
import '../services/global.dart' as global;
class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: global.primaryColor,
              offset: Offset(0, 1.5),
              blurRadius: 1.0,
            )
          ]),
          child: AppBar(
            title: Image.asset('images/header_logo.png',fit: BoxFit.contain,height: 45,),
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset("images/logo_icon.png",),
            ),
            actions: [
              Container(
                padding: EdgeInsets.all(10),
                child: ClipOval(
                  child: Material(
                    child: InkWell(
                      splashColor: Colors.green, // Splash color
                      onTap: () =>{
                        Navigator.push(context,MaterialPageRoute(builder: (context) => HomePage()))
                      },
                      child: SizedBox(
                        width: 37,
                        height: 37,
                        child: Icon(Icons.refresh),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        preferredSize: Size.fromHeight(kToolbarHeight),
      ),

    );
  }
}
