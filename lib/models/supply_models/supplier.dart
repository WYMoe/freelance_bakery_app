import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String id;
  final String name;
  final Timestamp timestamp;

  Supplier({this.id, this.name, this.timestamp});

  factory Supplier.fromDocument(doc) {
    return Supplier(
        id: doc['id'], name: doc['name'], timestamp: doc['timestamp']);
  }
}
