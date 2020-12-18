import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/widgets/product_widgets/productVocherWidget.dart';

class ProductVocherScreen extends StatefulWidget {
  final String vocherID;

  ProductVocherScreen({
    this.vocherID,
  });
  @override
  _ProductVocherScreenState createState() => _ProductVocherScreenState();
}

class _ProductVocherScreenState extends State<ProductVocherScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('productVochers')
            .document(widget.vocherID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          // VocherWidget vocherWidget = VocherWidget(
          //   id: snapshot.data['vocherID'],
          //   customerId: snapshot.data['customerID'],
          //   totalAmt: snapshot.data['totalAmt'],
          //   payAmt: snapshot.data['payAmt'],
          //   leftAmt: snapshot.data['leftAmt'],
          //   timestamp: snapshot.data['timestamp'],
          //   createdDate: snapshot.data['createdDate'],
          //   customerName: widget.customerName,
          // );
          ProductVocherWidget productVocherWidget = ProductVocherWidget(
            productVocherID: snapshot.data['productVocherID'],
            timestamp: snapshot.data['timestamp'],
            total: snapshot.data['total'],
            pInTotal: snapshot.data['pInTotal'],
            creator: snapshot.data['creator'],
          );

          return productVocherWidget;
        });
  }
}
