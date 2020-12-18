import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/home.dart';
import 'package:freelance_demo/login_detail.dart';
import 'package:freelance_demo/screens/product_screens/productHomePage.dart';
import 'package:freelance_demo/screens/totalSale_screens/totalSaleHomePage.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MT_Admin',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Color(0xff1f456e),
        ),
        home: ValidateScreen());
  }
}

class ValidateScreen extends StatefulWidget {
  ValidateScreen({Key key}) : super(key: key);

  @override
  _ValidateScreenState createState() => _ValidateScreenState();
}

class _ValidateScreenState extends State<ValidateScreen> {
  String _platformImei = 'Unknown';
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser u;
  bool validate = true;


  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformImei;

    try {
      platformImei = await ImeiPlugin.getImei();
    } on PlatformException {
      platformImei = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformImei = platformImei;
    });
    if (devicesID.contains(_platformImei)) {
      validate = true;
      final user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: loginMail, password: loginPassword);
      u = user;
      //print(u.email);
    } else {
      validate = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return validate
        ? Home()
        : Scaffold(
            body: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text('YOU ARE NOT AUTHENTICATED'),
                  ],
                ),
              ),
            ),
          );
  }
}

//  validate
//         ? Home()
//         : Scaffold(
//             body: Container(
//               child: Center(
//                 child: Text('YOU ARE NOT ALLOWED'),
//               ),
//             ),
//           );
