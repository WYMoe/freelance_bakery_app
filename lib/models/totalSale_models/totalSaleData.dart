import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalSaleData {
  final String customerName;
  final int qty;

  final String id;
  final Timestamp timestamp;
  TotalSaleData({this.customerName, this.id, this.timestamp, this.qty});

  factory TotalSaleData.fromDocument(doc) {
    return TotalSaleData(
        customerName: doc['name'],
        id: doc['id'],
        timestamp: doc['timestamp'],
        qty: doc['qty']);
  }
}
