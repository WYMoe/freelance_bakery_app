import 'package:cloud_firestore/cloud_firestore.dart';

class TotalSaleCustomer {
  final String name;
  final String customerID;
  final int qty;
  final Timestamp timestamp;
  TotalSaleCustomer({this.name, this.customerID, this.qty, this.timestamp});

  factory TotalSaleCustomer.fromDocument(doc) {
    return TotalSaleCustomer(
        name: doc['name'],
        customerID: doc['customerID'],
        qty: doc['qty'],
        timestamp: doc['timestamp']);
  }
}
