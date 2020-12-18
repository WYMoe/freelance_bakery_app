import 'package:cloud_firestore/cloud_firestore.dart';

class ProductVocher {
  final String productVocherID;
  final Timestamp timestamp;
  final int total;
  final int pInTotal;
  final String creator;
  ProductVocher(
      {this.productVocherID,
      this.timestamp,
      this.total,
      this.pInTotal,
      this.creator});

  factory ProductVocher.fromDocument(doc) {
    return ProductVocher(
        productVocherID: doc['productVocherID'],
        timestamp: doc['timestamp'],
        total: doc['total'],
        pInTotal: doc['pInTotal'],
        creator: doc['creator']);
  }
}
