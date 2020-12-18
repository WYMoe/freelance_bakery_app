import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/models/sale_models/item.dart';
import 'package:freelance_demo/services.dart';
import 'package:uuid/uuid.dart';

class SalePage extends StatefulWidget {
  final String name;
  final String id;
  SalePage(this.id, this.name);
  @override
  _SalePageState createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  TextEditingController controller = TextEditingController();
  String itemName;
  int itemPrice;
  int itemQuantity;
  int itemTotal = 1000;
  String vocherID = Uuid().v4();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('sale_data')
                .document(widget.name)
                .collection('vochers')
                .document(vocherID)
                .collection('items')
                .orderBy('datetime', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              List<DataRow> newList = [];
              snapshot.data.documents.forEach((doc) {
                Item item = Item.fromDocument(doc);

                newList.add(DataRow(cells: [
                  DataCell(Text(item.item)),
                  DataCell(Text(item.price.toString())),
                  DataCell(Text(item.quantity.toString())),
                  DataCell(Text(item.total.toString()))
                ]));
              });
              return ListView(children: <Widget>[
                Center(
                    child: Text(
                  'Sale Page',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
                DataTable(columns: [
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Total')),
                ], rows: newList),
                FlatButton(
                    onPressed: () {
                      Firestore.instance
                          .collection('sale_history')
                          .document(widget.name)
                          .collection('vochers')
                          .document('vocher')
                          .collection('items')
                          .document()
                          .setData({
                        'item': itemName,
                        'price': itemPrice,
                        'quantity': itemQuantity,
                        'total': itemTotal,
                        'datetime': DateTime.now()
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20.0),
                      decoration:
                          BoxDecoration(color: Theme.of(context).primaryColor),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                    ))
              ]);
            }),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightBlueAccent,
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0))),
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Add Item',
                              style: TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontSize: 30.0,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            TextField(
                              autofocus: false,
                              decoration: InputDecoration(
                                  hintText: 'Enter item name',
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.lightBlueAccent))),
                              onChanged: (value) {
                                itemName = value;
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextField(
                              autofocus: false,
                              decoration: InputDecoration(
                                  hintText: 'Enter item price',
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.lightBlueAccent))),
                              onChanged: (value) {
                                itemPrice = int.parse(value);
                              },
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            TextField(
                              autofocus: false,
                              decoration: InputDecoration(
                                  hintText: 'Enter item quantity',
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.lightBlueAccent))),
                              onChanged: (value) {
                                itemQuantity = int.parse(value);
                              },
                            ),
                            FlatButton(
                              onPressed: () {
                                Firestore.instance
                                    .collection('sale_data')
                                    .document(widget.name)
                                    .collection('vochers')
                                    .document('1')
                                    .setData({'vocherID': '1'});
                                Firestore.instance
                                    .collection('sale_data')
                                    .document(widget.name)
                                    .collection('vochers')
                                    .document('1')
                                    .collection('items')
                                    .document()
                                    .setData({
                                  'item': itemName,
                                  'price': itemPrice,
                                  'quantity': itemQuantity,
                                  'total': itemTotal,
                                  'datetime': DateTime.now()
                                });
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Add',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Colors.lightBlueAccent,
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
