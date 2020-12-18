import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productID;
  final String product;
  int productLeft;
  int productIn;
  int productSale;
  int productTotal;
  final Timestamp timestamp;
  Product(
      {this.productID,
      this.product,
      this.productLeft,
      this.productIn,
      this.productSale,
      this.productTotal,
      this.timestamp});

  factory Product.fromDocument(doc) {
    return Product(
        productID: doc['productID'],
        product: doc['product'],
        productLeft: doc['productLeft'],
        productIn: doc['productIn'],
        productSale: doc['productSale'],
        productTotal: doc['productTotal'],
        timestamp: doc['timestamp']);
  }
}
