import 'package:cloud_firestore/cloud_firestore.dart';

class Vocher {
  final String id;
  final String customerId;
  final int totalAmt;
  final int payAmt;
  final int leftAmt;

  final Timestamp timestamp;
  final Timestamp createdDate;
  final String creator;

  Vocher(
      {this.id,
      this.customerId,
      this.totalAmt,
      this.payAmt,
      this.leftAmt,
      this.timestamp,
      this.createdDate,
      this.creator});

  factory Vocher.fromDocument(doc) {
    return Vocher(
        id: doc['vocherID'],
        customerId: doc['customerID'],
        totalAmt: doc['totalAmt'],
        payAmt: doc['payAmt'],
        leftAmt: doc['leftAmt'],
        timestamp: doc['timestamp'],
        createdDate: doc['createdDate'],
        creator: doc['creator']);
  }
}
