import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/models/sale_models/vocher.dart';
import 'package:freelance_demo/widgets/sale_widgets/vocherWidget.dart';
import 'package:freelance_demo/models/sale_models/item.dart';
import 'package:intl/intl.dart';
import 'package:freelance_demo/screens/sale_screens/editPaid.dart';
import 'package:freelance_demo/screens/sale_screens/editItem.dart';

class VocherScreen extends StatefulWidget {
  final String vocherID;
  final String customerID;
  final String customerName;

  VocherScreen({this.customerID, this.vocherID, this.customerName});
  @override
  _VocherScreenState createState() => _VocherScreenState();
}

class _VocherScreenState extends State<VocherScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  Future<void> _showMyDialog(
      String itemId, String customerId, String id) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This item will be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Firestore.instance
                    .collection('vochers')
                    .document(customerId)
                    .collection('customerVochers')
                    .document(id)
                    .collection('items')
                    .document(itemId)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int left = 0;
  int pay = 0;
  int total = 0;
  int paid = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('vochers')
            .document(widget.customerID)
            .collection('customerVochers')
            .document(widget.vocherID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          VocherWidget vocherWidget = VocherWidget(
            id: snapshot.data['vocherID'],
            customerId: snapshot.data['customerID'],
            totalAmt: snapshot.data['totalAmt'],
            payAmt: snapshot.data['payAmt'],
            leftAmt: snapshot.data['leftAmt'],
            timestamp: snapshot.data['timestamp'],
            createdDate: snapshot.data['createdDate'],
            customerName: widget.customerName,
            creator: snapshot.data['creator'],
          );

          return vocherWidget;
        });
  }
}
