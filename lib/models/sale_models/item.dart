import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String itemID;
  final String item;
  final int price;
  final int quantity;
  final int total;
  final Timestamp dateTime;

  Item(
      {this.itemID,
      this.item,
      this.price,
      this.quantity,
      this.total,
      this.dateTime});

  factory Item.fromDocument(doc) {
    return Item(
        itemID: doc['itemID'],
        item: doc['item'],
        price: doc['price'],
        quantity: doc['quantity'],
        total: doc['total'],
        dateTime: doc['datetime']);
  }
}
