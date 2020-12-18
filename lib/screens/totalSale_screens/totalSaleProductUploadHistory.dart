import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleProduct.dart';
//import 'package:freelance_demo/models/supply_models/supplier.dart';
//import 'package:freelance_demo/screens/supply_screens/supplyVocherUpload.dart';
//import 'package:freelance_demo/screens/sale_screens/vocherUpload.dart';
//import 'package:freelance_demo/screens/supply_screens/supplyVocherHistory.dart';
import 'package:freelance_demo/services.dart';
//import 'vocherHistory.dart';

import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'totalSaleCustomerDataScreen.dart';

class TotalSaleProductUploadHistory extends StatefulWidget {
  TotalSaleProductUploadHistory(
      {this.vocherID, this.createdDate, this.total, this.creator});
  final String vocherID;
  final DateTime createdDate;
  final int total;
  final String creator;

  @override
  _TotalSaleProductUploadHistoryState createState() =>
      _TotalSaleProductUploadHistoryState();
}

class _TotalSaleProductUploadHistoryState
    extends State<TotalSaleProductUploadHistory> {
  String name = '';
  // int no;
  String productAddId = Uuid().v4();

  //int total;
  Product product;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  Future<void> _showSaleDataAddDialog(Product product) async {
    String customerID = Uuid().v4();
    String name;
    int qty;
    int total = product.total;
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(product.product),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: TextField(
                      onChanged: (val) {
                        name = val;
                      },
                      decoration: InputDecoration(
                          hintText: 'Enter Customer Name',
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ))),
                ),
                SizedBox(
                  height: 5.0,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: TextField(
                      onChanged: (val) {
                        qty = int.parse(val.trim());
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: 'Enter Quantity',
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ))),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Done'),
              onPressed: () async {
                if (name == null || name.trim().length == 0) {
                } else if (qty == null) {
                } else {
                  total += qty;
                  Firestore.instance
                      .collection('totalSaleVochers')
                      .document(widget.vocherID)
                      .collection('products')
                      .document(product.productID)
                      .updateData({'total': total});

                  Firestore.instance
                      .collection('totalSaleVochers')
                      .document(widget.vocherID)
                      .collection('products')
                      .document(product.productID)
                      .collection('customers')
                      .document(customerID)
                      .setData({
                    'name': name,
                    'customerID': customerID,
                    'timestamp': DateTime.now(),
                    'qty': qty
                  });

                  customerID = Uuid().v4();
                  name = '';
                  qty = null;

                  Navigator.pop(context);
                }
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

  Future<void> _showDeleteDialog(String productID) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This Product will be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Firestore.instance
                    .collection('totalSaleVochers')
                    .document(widget.vocherID)
                    .collection('products')
                    .document(productID)
                    .collection('customers')
                    .getDocuments()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.documents) {
                    ds.reference.delete();
                  }
                });

                Firestore.instance
                    .collection('totalSaleVochers')
                    .document(widget.vocherID)
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

  int pTotal = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pTotal = widget.total;
    print(pTotal);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('totalSaleVochers')
            .document(widget.vocherID)
            .collection('products')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()));
          }

          List<FlatButton> productUploadTile = [];
          List<int> totals = [];
          snapshot.data.documents.forEach((doc) {
            Product product = Product.fromDocument(doc);
            totals.add(product.total);

            productUploadTile.add(FlatButton(
              onLongPress: () {
                _showDeleteDialog(product.productID);
              },
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      title: Text('Product : ${product.product}'),
                      children: <Widget>[
                        SimpleDialogOption(
                          child: Text('Add Data'),
                          onPressed: () {
                            Navigator.pop(context);
                            _showSaleDataAddDialog(product);
                          },
                        ),
                        SimpleDialogOption(
                          child: Text('View Data'),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return TotalSaleCustomerDataScreen(
                                productID: product.productID,
                                vocherID: widget.vocherID,
                                createdDate: product.timestamp.toDate(),
                                productName: product.product,
                              );
                            }));
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: TotalSaleProductUploadTile(
                product: product,
              ),
            ));
          });

          if (productUploadTile.length == 0) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text('No Products'),
              ),
            );
          }
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
                              pTotal = result;
                            });
                            Firestore.instance
                                .collection('totalSaleVochers')
                                .document(widget.vocherID)
                                .updateData({'total': pTotal}).whenComplete(() {
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
                title: Text('အရောင်းစာရင်း : Daily'),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        top: 25.0,
                        left: MediaQuery.of(context).size.width * 0.12),
                    child: Text(
                      'Created Date : ' +
                          DateFormat('yyyy-MM-dd').format(widget.createdDate),
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Creator : ' + widget.creator,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300),
                      ),
                      FlatButton.icon(
                          onPressed: () {
                            int result = 0;
                            totals.forEach((t) {
                              result += t;
                            });
                            setState(() {
                              pTotal = result;
                            });
                            Firestore.instance
                                .collection('totalSaleVochers')
                                .document(widget.vocherID)
                                .updateData({'total': pTotal}).whenComplete(() {
                              _scaffoldKey.currentState.showSnackBar(snackbar);
                            });
                          },
                          icon: Icon(Icons.save),
                          label: Text('Save'))
                    ],
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
                      'Total ${pTotal.toString()}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 20.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: ListView(
                          physics: BouncingScrollPhysics(),
                          children: productUploadTile,
                        )),
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
                                    autofocus: true,
                                    // validator: (val) {
                                    //   if (val == null ||
                                    //       val.isEmpty ||
                                    //       val.trim().length == 0) {
                                    //     return "Please Add Customer Name";
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                    decoration: InputDecoration(
                                      enabledBorder: UnderlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      name = value;
                                    },
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      if (name == '' ||
                                          name.trim().length == 0) {
                                      } else {
                                        Firestore.instance
                                            .collection('totalSaleVochers')
                                            .document(widget.vocherID)
                                            .collection('products')
                                            .document(productAddId)
                                            .setData({
                                          'product': name,
                                          'productID': productAddId,
                                          'timestamp': DateTime.now(),
                                          'total': 0
                                        });

                                        setState(() {
                                          productAddId = Uuid().v4();
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
  }
}

class TotalSaleProductUploadTile extends StatelessWidget {
  TotalSaleProductUploadTile({
    this.product,
  });
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(width: 0.5, color: Colors.blueGrey)),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image(
                image: AssetImage('assets/images/saleListicon.png'),
                width: 60.0,
                height: 60.0,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.product,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      'Total : ${product.total.toString()}',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Future<void> _showMyDialog() async {
//   return showDialog<void>(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Delete!'),
//         content: SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Text('This supplier will be deleted.'),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           FlatButton(
//             child: Text('OK'),
//             onPressed: () {
//               Firestore.instance
//                   .collection('suppliers')
//                   .document(widget.product.id)
//                   .delete();

//               Firestore.instance
//                   .collection('supplyVochers')
//                   .document(widget.product.id)
//                   .collection('supplierVochers')
//                   .getDocuments()
//                   .then((snapshot) {
//                 for (DocumentSnapshot ds in snapshot.documents) {
//                   ds.reference.delete();
//                 }
//               });

//               Firestore.instance
//                   .collection('supplyVochers')
//                   .document(widget.product.id)
//                   .collection('supplierVochers')
//                   .getDocuments()
//                   .then((snapshot) {
//                 for (DocumentSnapshot ds in snapshot.documents) {
//                   ds.reference
//                       .collection('supplyItems')
//                       .getDocuments()
//                       .then((snapshot) {
//                     for (DocumentSnapshot ds in snapshot.documents) {
//                       ds.reference.delete();
//                     }
//                   });
//                   ds.reference.delete();
//                 }
//               });

//               Navigator.of(context).pop();
//             },
//           ),
//           FlatButton(
//             child: Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
