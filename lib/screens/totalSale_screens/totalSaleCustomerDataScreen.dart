import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleProduct.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleCustomer.dart';
import 'package:freelance_demo/screens/totalSale_screens/totalSaleEditCustomer.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleVocher.dart';

class TotalSaleCustomerDataScreen extends StatefulWidget {
  final String productID;
  final String vocherID;
  final DateTime createdDate;
  final String productName;
  TotalSaleCustomerDataScreen(
      {this.productID, this.vocherID, this.createdDate, this.productName});
  @override
  _TotalSaleCustomerDataScreenState createState() =>
      _TotalSaleCustomerDataScreenState();
}

class _TotalSaleCustomerDataScreenState
    extends State<TotalSaleCustomerDataScreen> {
  //String name;
  //int qty;
  // String customerID = Uuid().v4();
  Future<void> _showMyDialog(
      String customerID, int cQty, Product product) async {
    int total = product.total;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This Customer will be deleted.'),
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
                    .document(widget.productID)
                    .updateData({'total': total - cQty});

                Firestore.instance
                    .collection('totalSaleVochers')
                    .document(widget.vocherID)
                    .collection('products')
                    .document(widget.productID)
                    .collection('customers')
                    .document(customerID)
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
                  print(total);
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('totalSaleVochers')
            .document(widget.vocherID)
            .collection('products')
            .document(widget.productID)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()));
          }
          Product product = Product.fromDocument(snapshot.data);
          //  total = product.total;

          return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('totalSaleVochers')
                .document(widget.vocherID)
                .collection('products')
                .document(widget.productID)
                .collection('customers')
                .orderBy('timestamp', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold(
                    appBar: AppBar(),
                    body: Center(child: CircularProgressIndicator()));
              }

              List<FlatButton> tiles = [];
              snapshot.data.documents.forEach((doc) {
                TotalSaleCustomer customer =
                    TotalSaleCustomer.fromDocument(doc);

                tiles.add(FlatButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: Text(customer.name),
                            children: <Widget>[
                              SimpleDialogOption(
                                child: Text('Edit'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return TotalSaleEditCustomer(
                                      currentVocherID: widget.vocherID,
                                      customerID: customer.customerID,
                                      productID: widget.productID,
                                    );
                                  }));
                                },
                              ),
                              SimpleDialogOption(
                                child: Text('Delete'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showMyDialog(customer.customerID,
                                      customer.qty, product);
                                },
                              )
                            ],
                          );
                        },
                      );
                    },
                    child: TotalSaleCustomerDataTile(
                      customer: customer,
                    )));
              });

              return Scaffold(
                appBar: AppBar(
                  title: Text('အရောင်းစာရင်း : Data'),
                  centerTitle: false,
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, top: 25.0),
                      child: Text(
                        'Created Date : ' +
                            DateFormat('yyyy-MM-dd').format(widget.createdDate),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Text(
                        'Product : ${widget.productName}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300),
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
                        'Total ${product.total.toString()}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                        child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: tiles,
                    )),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.add),
                  onPressed: () {
                    _showSaleDataAddDialog(product);
                    // showModalBottomSheet(
                    //     isScrollControlled: true,
                    //     shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.only(
                    //             topLeft: Radius.circular(20.0),
                    //             topRight: Radius.circular(20.0))),
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return Container(
                    //         padding: EdgeInsets.only(
                    //             bottom:
                    //                 MediaQuery.of(context).viewInsets.bottom),
                    //         child: SingleChildScrollView(
                    //           child: Padding(
                    //             padding: EdgeInsets.all(20.0),
                    //             child: Column(
                    //               crossAxisAlignment:
                    //                   CrossAxisAlignment.stretch,
                    //               children: <Widget>[
                    //                 Text(
                    //                   'Add Sale Data',
                    //                   style: TextStyle(
                    //                       color: Theme.of(context).primaryColor,
                    //                       fontSize: 30.0,
                    //                       fontWeight: FontWeight.w600),
                    //                   textAlign: TextAlign.center,
                    //                 ),
                    //                 TextField(
                    //                   autofocus: true,
                    //                   decoration: InputDecoration(
                    //                     hintText: 'Enter Customer Name',
                    //                     enabledBorder: UnderlineInputBorder(),
                    //                   ),
                    //                   onChanged: (value) {
                    //                     name = value;
                    //                   },
                    //                 ),
                    //                 SizedBox(
                    //                   height: 10.0,
                    //                 ),
                    //                 TextField(
                    //                   autofocus: true,
                    //                   keyboardType: TextInputType.number,
                    //                   decoration: InputDecoration(
                    //                     hintText: 'Enter Quantity',
                    //                     enabledBorder: UnderlineInputBorder(),
                    //                   ),
                    //                   onChanged: (value) {
                    //                     qty = int.parse(value.trim());
                    //                   },
                    //                 ),
                    //                 SizedBox(
                    //                   height: 10.0,
                    //                 ),
                    //                 FlatButton(
                    //                   onPressed: () async {
                    //                     // if (name == null ||
                    //                     //     name.trim().length == 0) {
                    //                     // } else if (qty == null) {
                    //                     // } else {
                    //                     //   setState(() {
                    //                     //     total += qty;
                    //                     //   });
                    //                     //   Firestore.instance
                    //                     //       .collection('totalSaleVochers')
                    //                     //       .document(widget.vocherID)
                    //                     //       .collection('products')
                    //                     //       .document(widget.productID)
                    //                     //       .collection('customers')
                    //                     //       .document(customerID)
                    //                     //       .setData({
                    //                     //     'name': name,
                    //                     //     'customerID': customerID,
                    //                     //     'timestamp': DateTime.now(),
                    //                     //     'qty': qty
                    //                     //   });
                    //                     //        //totalတစ်ပြိုင်တည်းတွက်ရင်ပြသနာဖြစ်နိုင် DBထဲကloopပတ်တွက်ရင်တော့ okမယ် BUT ကြာမယ်
                    //                     //   Firestore.instance
                    //                     //       .collection('totalSaleVochers')
                    //                     //       .document(widget.vocherID)
                    //                     //       .collection('products')
                    //                     //       .document(widget.productID)
                    //                     //       .updateData({'total': total});

                    //                     //   customerID = Uuid().v4();
                    //                     //   name = '';
                    //                     //   qty = null;

                    //                     //   Navigator.pop(context);
                    //                     // }
                    //                     _showSaleDataAddDialog(product);
                    //                   },
                    //                   child: Text(
                    //                     'Add',
                    //                     style: TextStyle(color: Colors.white),
                    //                   ),
                    //                   color: Theme.of(context).primaryColor,
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     });
                  },
                ),
              );
            },
          );
        });
  }
}

class TotalSaleCustomerDataTile extends StatelessWidget {
  TotalSaleCustomerDataTile({this.customer});
  final TotalSaleCustomer customer;
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
                child: Icon(
                  Icons.account_circle,
                  color: Theme.of(context).primaryColor,
                  size: 60.0,
                )),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      customer.name,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: 4.0,
                    ),
                    Text(
                      'QTY : ${customer.qty.toString()}',
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
