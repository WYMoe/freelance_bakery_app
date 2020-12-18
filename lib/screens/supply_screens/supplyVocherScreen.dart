import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/models/supply_models/supplyVocher.dart';
import 'package:freelance_demo/widgets/supply_widgets/supplyVocherWidget.dart';

class VocherScreen extends StatefulWidget {
  final String supplyVocherID;
  final String supplierID;
  final String supplierName;

  VocherScreen({this.supplierID, this.supplyVocherID, this.supplierName});
  @override
  _VocherScreenState createState() => _VocherScreenState();
}

class _VocherScreenState extends State<VocherScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('supplyVochers')
            .document(widget.supplierID)
            .collection('supplierVochers')
            .document(widget.supplyVocherID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          VocherWidget vocherWidget = VocherWidget(
            id: snapshot.data['supplyVocherID'],
            customerId: snapshot.data['supplierID'],
            totalAmt: snapshot.data['totalAmt'],
            payAmt: snapshot.data['payAmt'],
            leftAmt: snapshot.data['leftAmt'],
            timestamp: snapshot.data['timestamp'],
            createdDate: snapshot.data['createdDate'],
            customerName: widget.supplierName,
            creator: snapshot.data['creator'],
          );

          //print(snapshot.data['supplierID']);
          //print(widget.supplierID);
          // print(widget.supplyVocherID);

          return vocherWidget;
        });
  }
}
