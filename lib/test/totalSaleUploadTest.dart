import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleCustomer.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleProduct.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleData.dart';

class TotalSaleUpload extends StatefulWidget {
  @override
  _TotalSaleUploadState createState() => _TotalSaleUploadState();
}

class _TotalSaleUploadState extends State<TotalSaleUpload> {
  int total = 0;
  DateTime createdDate;
  String totalSaleVocherID = Uuid().v4();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  @override
  void initState() {
    super.initState();

    createdDate = DateTime.now();

    createRow();
  }

  @override
  void dispose() {
    super.dispose();

    checkAndDelete();
  }

  checkAndDelete() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('totalSaleVochers')
        .document(totalSaleVocherID)
        .get();

    if (doc.data == null) {
      Firestore.instance
          .collection('totalSaleVochers')
          .document(totalSaleVocherID)
          .collection('totalSaleProducts')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          Firestore.instance
              .collection('totalSaleVochers')
              .document(totalSaleVocherID)
              .collection('totalSaleProducts')
              .document(ds.documentID)
              .collection('data')
              .getDocuments()
              .then((snapshot) {
            for (DocumentSnapshot ds in snapshot.documents) {
              ds.reference.delete();
            }
          });

          ds.reference.delete();
        }
      });

      Firestore.instance
          .collection('totalSaleVochers')
          .document(totalSaleVocherID)
          .collection('totalSaleCustomers')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
      Firestore.instance
          .collection('totalSaleVochers')
          .document(totalSaleVocherID)
          .delete();
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
          .collection('totalSaleVochers')
          .document(totalSaleVocherID)
          .collection('totalSaleProducts')
          .document(productId)
          .setData({
        'product': productNames[i],
        'productID': productId,
        'timestamp': DateTime.now(),
        'total': 0
      });
    }
  }

  Future<void> _showCustomerAddDialog() async {
    String totalSaleCustomerID = Uuid().v4();
    String name;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Customer'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  onChanged: (val) {
                    name = val;
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Done'),
              onPressed: () {
                if (name == null || name.trim().length == 0) {
                } else {
                  Firestore.instance
                      .collection('totalSaleVochers')
                      .document(totalSaleVocherID)
                      .collection('totalSaleCustomers')
                      .document(totalSaleCustomerID)
                      .setData({
                    'name': name,
                    'id': totalSaleCustomerID,
                    'timestamp': DateTime.now()
                  });
                  name = '';
                  totalSaleCustomerID = Uuid().v4();
                  Navigator.of(context).pop();
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

  Future<void> _showProductAddDialog() async {
    String totalSaleProductAddID = Uuid().v4();
    String productName;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  onChanged: (val) {
                    productName = val;
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Done'),
              onPressed: () async {
                if (productName == null || productName.trim().length == 0) {
                } else {
                  Firestore.instance
                      .collection('totalSaleVochers')
                      .document(totalSaleVocherID)
                      .collection('totalSaleProducts')
                      .document(totalSaleProductAddID)
                      .setData({
                    'product': productName,
                    'productID': totalSaleProductAddID,
                    'timestamp': DateTime.now(),
                    'total': 0
                  });

                  totalSaleProductAddID = Uuid().v4();
                  productName = '';

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

  DataCell dataCell(Product product, TotalSaleCustomer customer) {
    int qty;

    return DataCell(Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: TextField(
          onChanged: (value) {
            if (value.isEmpty) {
              qty = 0;
            } else {
              qty = int.parse(value.trim());
            }

            Firestore.instance
                .collection('totalSaleVochers')
                .document(totalSaleVocherID)
                .collection('totalSaleProducts')
                .document(product.productID)
                .collection('data')
                .document(customer.customerID)
                .setData({
              'name': customer.name,
              'qty': qty,
              'id': customer.customerID,
              'timestamp': customer.timestamp
            });
            qty = 0;
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('totalSaleVochers')
            .document(totalSaleVocherID)
            .collection('totalSaleCustomers')
            .orderBy('timestamp', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()));
          }

          List<DataColumn> newColumn = [DataColumn(label: Text('Product'))];
          List<TotalSaleCustomer> customers = [];
          int columnDocumentCount = snapshot.data.documents.length;

          snapshot.data.documents.forEach((doc) {
            TotalSaleCustomer customer = TotalSaleCustomer.fromDocument(doc);
            customers.add(customer);

            newColumn.add(DataColumn(label: Text(customer.name)));
          });
          newColumn.add(DataColumn(label: Text('')));

          newColumn.add(DataColumn(label: Text('total')));

          return StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('totalSaleVochers')
                  .document(totalSaleVocherID)
                  .collection('totalSaleProducts')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Scaffold(
                      appBar: AppBar(),
                      body: Center(child: CircularProgressIndicator()));
                }

                List<DataRow> newList = [];

                snapshot.data.documents.forEach((doc) {
                  Product product = Product.fromDocument(doc);

                  List<DataCell> cells = [DataCell(Text(product.product))];

                  for (int i = 0; i < columnDocumentCount; i++) {
                    cells.add(dataCell(product, customers[i]));
                  }

                  cells.add(
                    DataCell(IconButton(
                        icon: Icon(Icons.forward),
                        onPressed: () async {
                          QuerySnapshot qs = await Firestore.instance
                              .collection('totalSaleVochers')
                              .document(totalSaleVocherID)
                              .collection('totalSaleProducts')
                              .document(product.productID)
                              .collection('data')
                              .getDocuments();
                          int result = 0;

                          qs.documents.forEach((doc) {
                            result += doc['qty'];
                          });

                          Firestore.instance
                              .collection('totalSaleVochers')
                              .document(totalSaleVocherID)
                              .collection('totalSaleProducts')
                              .document(product.productID)
                              .updateData({'total': result});
                        })),
                  );
                  cells.add(DataCell(Text(product.total.toString())));

                  newList.add(DataRow(cells: cells));
                });

                return Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    title: Text('အရောင်းစာရင်း : New'),
                    centerTitle: false,
                  ),
                  body: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, top: 25.0, bottom: 10.0),
                        child: Text(
                          'Created Date:' +
                              DateFormat('yyyy-MM-dd').format(createdDate),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w300),
                        ),
                      ),
                      Center(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                              showCheckboxColumn: false,
                              columns: newColumn,
                              rows: newList),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0, bottom: 0.0),
                          child: FlatButton(
                            onPressed: () {
                              _showCustomerAddDialog();
                            },
                            child: Text(
                              'Add Customer',
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
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0, bottom: 0.0),
                          child: FlatButton(
                            onPressed: () {
                              _showProductAddDialog();
                            },
                            child: Text(
                              'Add Product',
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
                      Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          margin: EdgeInsets.only(
                              top: 10.0, left: 25.0, right: 25.0, bottom: 30.0),
                          child: FlatButton(
                            onPressed: () {
                              Firestore.instance
                                  .collection('totalSaleVochers')
                                  .document(totalSaleVocherID)
                                  .setData({
                                'createdDate': createdDate,
                                'vocherID': totalSaleVocherID
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
                    ],
                  ),
                );
              });
        });
  }
}
