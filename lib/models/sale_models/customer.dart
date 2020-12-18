import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final Timestamp timestamp;

  Customer({this.id, this.name, this.timestamp});

  factory Customer.fromDocument(doc) {
    return Customer(
        id: doc['id'], name: doc['name'], timestamp: doc['timestamp']);
  }
}
