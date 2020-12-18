import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/models/product_models/product.dart';
import 'package:uuid/uuid.dart';

import 'package:intl/intl.dart';

class ProductUpload extends StatefulWidget {
  @override
  _ProductUploadState createState() => _ProductUploadState();
}

class _ProductUploadState extends State<ProductUpload> {
  String productName;
  int total = 0;

  DateTime createdDate;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  String productFloatingID = Uuid().v4();
  String productVocherID = Uuid().v4();

  @override
  void initState() {
    super.initState();

    createdDate = DateTime.now();

    createRow();
    print(productVocherID);
  }

  @override
  void dispose() async {
    super.dispose();

    checkAndDelete();
  }

  checkAndDelete() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('productVochers')
        .document(productVocherID)
        .get();

    if (doc.data == null) {
      Firestore.instance
          .collection('productVochers')
          .document(productVocherID)
          .collection('products')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
    }
  }

  createRow() {
    List<String> productNames = [
      'အဖြူ',
      'အရစ်',
      'အပွင့်',
      'ထောင့်',
      'နှမ်း',
      'ကိတ်',
      'ပိုး',
      'စုံ'
    ];
    for (int i = 0; i < 8; i++) {
      String productId = Uuid().v4();
      Firestore.instance
          .collection('productVochers')
          .document(productVocherID)
          .collection('products')
          .document(productId)
          .setData({
        'productID': productId,
        'product': productNames[i],
        'productLeft': 0,
        'productIn': 0,
        'productSale': 0,
        'productTotal': 0,
        'timestamp': DateTime.now()
      });
    }
  }

  DataRow dataRow(Product product) {
    int left = 0;
    int pIn = 0;
    int sale = 0;
    int total = 0;
    return DataRow(
        onSelectChanged: (value) {
          if (value) {
            _showMyDialog(product.productID);
          }
        },
        cells: [
          DataCell(Text(product.product)),
          DataCell(Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    left = 0;
                  } else {
                    left = int.parse(value.trim());
                  }

                  Firestore.instance
                      .collection('productVochers')
                      .document(productVocherID)
                      .collection('products')
                      .document(product.productID)
                      .updateData({'productLeft': left});
                  left = 0;
                },
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 13.0),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: ''),
              ),
            ),
          )),
          DataCell(Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    pIn = 0;
                  } else {
                    pIn = int.parse(value.trim());
                  }

                  Firestore.instance
                      .collection('productVochers')
                      .document(productVocherID)
                      .collection('products')
                      .document(product.productID)
                      .updateData({'productIn': pIn});
                  pIn = 0;
                },
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 13.0),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: ''),
              ),
            ),
          )),
          DataCell(Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: TextField(
                onChanged: (value) {
                  if (value.isEmpty) {
                    sale = 0;
                  } else {
                    sale = int.parse(value.trim());
                  }

                  Firestore.instance
                      .collection('productVochers')
                      .document(productVocherID)
                      .collection('products')
                      .document(product.productID)
                      .updateData({'productSale': sale});
                  sale = 0;
                },
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 13.0),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    hintText: ''),
              ),
            ),
          )),
          DataCell(IconButton(
              icon: Icon(Icons.forward),
              onPressed: () {
                total = (product.productIn + product.productLeft) -
                    product.productSale;
                Firestore.instance
                    .collection('productVochers')
                    .document(productVocherID)
                    .collection('products')
                    .document(product.productID)
                    .updateData({'productTotal': total});
                total = 0;
              })),
          DataCell(Text(product.productTotal.toString()))
        ]);
  }

  Future<void> _showMyDialog(String productID) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This item will be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Firestore.instance
                    .collection('productVochers')
                    .document(productVocherID)
                    .collection('products')
                    .document(productID)
                    .delete();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // return StreamBuilder<QuerySnapshot>(
    //     stream: Firestore.instance

    //         .collection('productVochers')
    //         .document(vocherID)
    //         .collection('products')
    //         .orderBy('datetime', descending: false)
    //         .snapshots(),
    //     builder: (context, snapshot) {
    //       if (!snapshot.hasData) {
    //         return Scaffold(
    //             appBar: AppBar(),
    //             body: Center(child: CircularProgressIndicator()));
    //       }
    //       List<DataRow> newList = [];
    //       List<int> itemsTotal = [];
    //       snapshot.data.documents.forEach((doc) {
    //         Pro item = Item.fromDocument(doc);
    //         itemsTotal.add(item.total);

    //         newList.add(DataRow(
    //             onSelectChanged: (value) {
    //               if (value) {
    //                 showDialog(
    //                   context: context,
    //                   builder: (context) {
    //                     return SimpleDialog(
    //                       title: Text(item.item),
    //                       children: <Widget>[
    //                         SimpleDialogOption(
    //                           child: Text('Edit'),
    //                           onPressed: () {
    //                             Navigator.pop(context);
    //                             Navigator.push(context,
    //                                 MaterialPageRoute(builder: (context) {
    //                               return null;
    //                             }));
    //                           },
    //                         ),
    //                         SimpleDialogOption(
    //                           child: Text('Delete'),
    //                           onPressed: () {
    //                             // Navigator.pop(context);
    //                             // _showMyDialog(item.itemID);
    //                           },
    //                         )
    //                       ],
    //                     );
    //                   },
    //                 );
    //               }
    //             },
    //             cells: [
    //               DataCell(Text(item.item)),
    //               DataCell(Text(item.price.toString())),
    //               DataCell(Text(item.quantity.toString())),
    //               DataCell(Text(item.total.toString())),
    //             ]));
    //       });

    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('productVochers')
            .document(productVocherID)
            .collection('products')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()));
          }

          List<DataRow> newList = [];
          List<int> totals = [];
          snapshot.data.documents.forEach((doc) {
            Product product = Product.fromDocument(doc);
            totals.add(product.productTotal);

            newList.add(dataRow(product));
          });

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text('မုန့်စာရင်း : '),
              centerTitle: false,
            ),
            body: ListView(children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 25.0, top: 25.0, bottom: 10.0),
                child: Text(
                  'Created Date:' +
                      DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                      showCheckboxColumn: false,
                      columns: [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('လက်ကျန်')),
                        DataColumn(label: Text('အဝင်')),
                        DataColumn(label: Text('အရောင်း')),
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('Total')),
                      ],
                      rows: newList),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40.0,
                  margin: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
                  child: FlatButton(
                    onPressed: () async {
                      int result = 0;
                      totals.forEach((t) {
                        result += t;
                      });
                      setState(() {
                        total = result;
                      });
                    },
                    child: Text(
                      'Calculate Total',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      color: Theme.of(context).primaryColor),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Total'),
                      Text(':'),
                      Text(total.toString())
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40.0,
                  margin: EdgeInsets.only(
                      top: 10.0, left: 25.0, right: 25.0, bottom: 25.0),
                  child: FlatButton(
                    onPressed: () {
                      Firestore.instance
                          .collection('productVochers')
                          .document(productVocherID)
                          .setData({
                        'productVocherID': productVocherID,
                        'total': total,
                        'timestamp': createdDate
                      }).whenComplete(() {
                        _scaffoldKey.currentState.showSnackBar(snackbar);
                      });
                    },
                    child: Text(
                      'Save',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7.0),
                      color: Theme.of(context).primaryColor),
                ),
              ),
            ]),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
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
                                  'Add Product',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                TextField(
                                  autofocus: false,
                                  decoration: InputDecoration(
                                      hintText: 'Enter product name',
                                      enabledBorder: UnderlineInputBorder()),
                                  onChanged: (value) {
                                    productName = value;
                                  },
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    if (productName == null ||
                                        productName.trim().length == 0) {
                                    } else {
                                      Firestore.instance
                                          .collection('productVochers')
                                          .document(productVocherID)
                                          .collection('products')
                                          .document(productFloatingID)
                                          .setData({
                                        'productID': productFloatingID,
                                        'product': productName,
                                        'productTotal': 0,
                                        'timestamp': DateTime.now()
                                      });

                                      setState(() {
                                        productFloatingID = Uuid().v4();
                                        productName = '';
                                      });

                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    'Add',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    });
              },
            ),
          );
        });
    // });
  }
}
