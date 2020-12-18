import 'package:cloud_firestore/cloud_firestore.dart';

class SupplyItem {
  final String supplyItemID;
  final String supplyItem;
  final int supplyItemPrice;
  final double supplyItemQuantity;
  final int supplyTotal;
  final Timestamp dateTime;

  SupplyItem(
      {this.supplyItemID,
      this.supplyItem,
      this.supplyItemPrice,
      this.supplyItemQuantity,
      this.supplyTotal,
      this.dateTime});

  factory SupplyItem.fromDocument(doc) {
    return SupplyItem(
        supplyItemID: doc['supplyItemID'],
        supplyItem: doc['supplyItem'],
        supplyItemPrice: doc['supplyItemPrice'],
        supplyItemQuantity: doc['supplyItemQuantity'],
        supplyTotal: doc['supplyTotal'],
        dateTime: doc['datetime']);
  }
}
