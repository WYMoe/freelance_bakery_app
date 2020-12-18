import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String product;
  final String productID;
  final int total;
  final Timestamp timestamp;
  Product({this.product, this.productID, this.timestamp, this.total});

  factory Product.fromDocument(doc) {
    return Product(
        product: doc['product'],
        productID: doc['productID'],
        timestamp: doc['timestamp'],
        total: doc['total']);
  }
}
