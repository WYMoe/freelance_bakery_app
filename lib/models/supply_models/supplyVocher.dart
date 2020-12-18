import 'package:cloud_firestore/cloud_firestore.dart';

class SupplyVocher {
  final String suppyVocherId;
  final String supplierId;
  final int totalAmt;
  final int payAmt;
  final int leftAmt;

  final Timestamp timestamp;
  final Timestamp createdDate;
  final String creator;

  SupplyVocher(
      {this.suppyVocherId,
      this.supplierId,
      this.totalAmt,
      this.payAmt,
      this.leftAmt,
      this.timestamp,
      this.createdDate,
      this.creator});

  factory SupplyVocher.fromDocument(doc) {
    return SupplyVocher(
        suppyVocherId: doc['supplyVocherID'],
        supplierId: doc['supplierID'],
        totalAmt: doc['totalAmt'],
        payAmt: doc['payAmt'],
        leftAmt: doc['leftAmt'],
        timestamp: doc['timestamp'],
        createdDate: doc['createdDate'],
        creator: doc['creator']);
  }
}
