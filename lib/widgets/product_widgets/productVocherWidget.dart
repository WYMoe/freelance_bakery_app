import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/models/product_models/product.dart';
import 'package:uuid/uuid.dart';
import 'package:freelance_demo/screens/product_screens/editProduct.dart';
import 'package:intl/intl.dart';

class ProductVocherWidget extends StatefulWidget {
  final String productVocherID;
  final Timestamp timestamp;
  final int total;
  final int pInTotal;
  final String creator;
  ProductVocherWidget(
      {this.productVocherID,
      this.timestamp,
      this.total,
      this.pInTotal,
      this.creator});

  @override
  _ProductVocherWidgetState createState() => _ProductVocherWidgetState();
}

class _ProductVocherWidgetState extends State<ProductVocherWidget> {
  String productName;
  int productLeft;
  int productIn;
  int productSale;
  int productTotal = 0;
  int total;
  int pIntotal;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  String productFloatingID = Uuid().v4();
  String productVocherID = Uuid().v4();
  @override
  void initState() {
    super.initState();
    total = widget.total;
    pIntotal = widget.pInTotal;
  }

  Future<void> _showMyDialog(String productID) async {
    print(productID);
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
                    .document(widget.productVocherID)
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
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('productVochers')
            .document(widget.productVocherID)
            .collection('products')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text('မုန့်စာရင်း : History'),
              ),
              body: Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          List<DataRow> newList = [];
          List<int> totals = [];
          List<int> pInTotals = [];

          snapshot.data.documents.forEach((doc) {
            Product product = Product.fromDocument(doc);
            totals.add(product.productTotal);
            pInTotals.add(product.productIn);

            newList.add(DataRow(
                onSelectChanged: (val) {
                  if (val) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: Text(product.product),
                          children: <Widget>[
                            SimpleDialogOption(
                              child: Text('Edit'),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EditProduct(
                                    productVocherID: widget.productVocherID,
                                    currentItemID: product.productID,
                                  );
                                }));
                              },
                            ),
                            SimpleDialogOption(
                              child: Text('Delete'),
                              onPressed: () {
                                Navigator.pop(context);
                                _showMyDialog(product.productID);
                              },
                            )
                          ],
                        );
                      },
                    );
                  }
                },
                cells: [
                  DataCell(Center(child: Text(product.product))),
                  DataCell(Center(child: Text(product.productLeft.toString()))),
                  DataCell(Center(child: Text(product.productIn.toString()))),
                  DataCell(Center(child: Text(product.productSale.toString()))),
                  DataCell(Center(child: Text(product.productTotal.toString())))
                ]));
          });

          return WillPopScope(
            onWillPop: () async {
              final value = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                          'Make sure everything\'s saved before you exit!'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Save'),
                          onPressed: () {
                            int result = 0;
                            totals.forEach((t) {
                              result += t;
                            });
                            setState(() {
                              total = result;
                            });

                            int pInResult = 0;
                            pInTotals.forEach((pIn) {
                              pInResult += pIn;
                            });

                            setState(() {
                              pIntotal = pInResult;
                            });

                            Firestore.instance
                                .collection('productVochers')
                                .document(widget.productVocherID)
                                .updateData({
                              'total': total,
                              'pInTotal': pIntotal
                            }).whenComplete(() {
                              _scaffoldKey.currentState.showSnackBar(snackbar);
                            });
                            //  Navigator.of(context).pop(false);
                          },
                        ),
                        FlatButton(
                          child: Text('Yes, exit'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ],
                    );
                  });

              return value == true;
            },
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: Text('မုန့်စာရင်း : History'),
                centerTitle: false,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, top: 25.0, bottom: 10.0),
                    child: Text(
                      'Created Date : ' +
                          DateFormat('yyyy-MM-dd')
                              .format(widget.timestamp.toDate()),
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, bottom: 10.0),
                    child: Text(
                      'Creator : ' + widget.creator,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20.0, right: 20, top: 10, bottom: 10.0),
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      'Total(စုစုပေါင်း) : ${total.toString()}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20.0, right: 20, top: 10, bottom: 10.0),
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).primaryColor),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      'Total(အ၀င်) : ${pIntotal.toString()}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView(children: <Widget>[
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              showCheckboxColumn: false,
                              columns: [
                                DataColumn(
                                    label: Text('Product'), numeric: true),
                                DataColumn(
                                    label: Text('လက်ကျန်'), numeric: true),
                                DataColumn(label: Text('အဝင်'), numeric: true),
                                DataColumn(
                                    label: Text('အရောင်း'), numeric: true),
                                DataColumn(label: Text('Total'), numeric: true),
                              ],
                              rows: newList),
                        ),
                      ),
                      // Center(
                      //   child: Container(
                      //     width: MediaQuery.of(context).size.width,
                      //     height: 40.0,
                      //     margin: EdgeInsets.only(
                      //       top: 10.0,
                      //       left: 25.0,
                      //       right: 25.0,
                      //     ),
                      //     child: FlatButton(
                      //       onPressed: () async {
                      //         int result = 0;
                      //         totals.forEach((t) {
                      //           result += t;
                      //         });
                      //         setState(() {
                      //           total = result;
                      //         });
                      //       },
                      //       child: Text(
                      //         'Update Total',
                      //         style: TextStyle(
                      //             color: Colors.white,
                      //             fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(7.0),
                      //         color: Theme.of(context).primaryColor),
                      //   ),
                      // ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0, bottom: 25.0),
                          child: FlatButton(
                            onPressed: () {
                              int result = 0;
                              totals.forEach((t) {
                                result += t;
                              });
                              setState(() {
                                total = result;
                              });

                              int pInResult = 0;
                              pInTotals.forEach((pIn) {
                                pInResult += pIn;
                              });
                              setState(() {
                                pIntotal = pInResult;
                              });

                              Firestore.instance
                                  .collection('productVochers')
                                  .document(widget.productVocherID)
                                  .updateData({
                                'total': total,
                                'pInTotal': pIntotal
                              }).whenComplete(() {
                                _scaffoldKey.currentState
                                    .showSnackBar(snackbar);
                              });
                            },
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
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
                                        hintText: 'Enter Product Name',
                                        enabledBorder: UnderlineInputBorder()),
                                    onChanged: (value) {
                                      productName = value;
                                    },
                                  ),
                                  TextField(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'လက်ကျန်',
                                        enabledBorder: UnderlineInputBorder()),
                                    onChanged: (value) {
                                      productLeft = int.parse(value.trim());
                                    },
                                  ),
                                  TextField(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'အဝင်',
                                        enabledBorder: UnderlineInputBorder()),
                                    onChanged: (value) {
                                      productIn = int.parse(value.trim());
                                    },
                                  ),
                                  TextField(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'အရောင်း',
                                        enabledBorder: UnderlineInputBorder()),
                                    onChanged: (value) {
                                      productSale = int.parse(value.trim());
                                    },
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      if (productName == null ||
                                          productName.trim().length == 0) {
                                      } else if (productLeft == null) {
                                      } else if (productIn == null) {
                                      } else if (productSale == null) {
                                      } else {
                                        productTotal =
                                            (productLeft + productIn) -
                                                productSale;
                                        Firestore.instance
                                            .collection('productVochers')
                                            .document(widget.productVocherID)
                                            .collection('products')
                                            .document(productFloatingID)
                                            .setData({
                                          'productID': productFloatingID,
                                          'product': productName,
                                          'productLeft': productLeft,
                                          'productIn': productIn,
                                          'productSale': productSale,
                                          'productTotal': productTotal,
                                          'timestamp': DateTime.now()
                                        });

                                        setState(() {
                                          productFloatingID = Uuid().v4();
                                          productName = '';
                                          productIn = null;
                                          productLeft = null;
                                          productSale = null;
                                          productTotal = null;
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
            ),
          );
        });
    // });
  }
}
