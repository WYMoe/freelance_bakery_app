import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TotalSaleVocher {
  final String vocherID;
  final int total;
  final String creator;

  final Timestamp createdDate;
  TotalSaleVocher({this.vocherID, this.createdDate, this.total, this.creator});

  factory TotalSaleVocher.fromDocument(doc) {
    return TotalSaleVocher(
        vocherID: doc['vocherID'],
        createdDate: doc['createdDate'],
        total: doc['total'],
        creator: doc['creator']);
  }
}
