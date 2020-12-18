import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance_demo/models/supply_models/supplier.dart';
import 'package:freelance_demo/screens/supply_screens/supplyVocherUpload.dart';
//import 'package:freelance_demo/screens/sale_screens/vocherUpload.dart';
import 'package:freelance_demo/screens/supply_screens/supplyVocherHistory.dart';
import 'package:freelance_demo/services.dart';
//import 'vocherHistory.dart';

import 'package:uuid/uuid.dart';

class SupplierHomePage extends StatefulWidget {
  SupplierHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SupplierHomePageState createState() => _SupplierHomePageState();
}

class _SupplierHomePageState extends State<SupplierHomePage> {
  String name = '';
  // int no;
  String supplierId = Uuid().v4();

  Supplier supplier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('အဝယ်'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('suppliers')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      List<SupplierTile> supplierTiles = [];
                      snapshot.data.documents.forEach((doc) {
                        Supplier supplier = Supplier.fromDocument(doc);
                        supplierTiles.add(SupplierTile(supplier));
                      });

                      if (supplierTiles.length == 0) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text('No Supplier')
                            ],
                          ),
                        );
                      }

                      return ListView(
                        children: supplierTiles,
                      );
                    })),
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
                            'Add Supplier',
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
                              if (name == '' || name.trim().length == 0) {
                              } else {
                                Firestore.instance
                                    .collection('suppliers')
                                    .document(supplierId)
                                    .setData({
                                  'name': name,
                                  'id': supplierId,
                                  'timestamp': DateTime.now()
                                });
                                var doc = await Firestore.instance
                                    .collection('suppliers')
                                    .document(supplierId)
                                    .get();
                                supplier = Supplier.fromDocument(doc);

                                setState(() {
                                  supplierId = Uuid().v4();
                                });
                                print(supplier.id);
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
  }
}

class SupplierTile extends StatefulWidget {
  final Supplier supplier;

  SupplierTile(this.supplier);

  @override
  _SupplierTileState createState() => _SupplierTileState();
}

class _SupplierTileState extends State<SupplierTile> {
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This supplier will be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Firestore.instance
                    .collection('suppliers')
                    .document(widget.supplier.id)
                    .delete();

                Firestore.instance
                    .collection('supplyVochers')
                    .document(widget.supplier.id)
                    .collection('supplierVochers')
                    .getDocuments()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.documents) {
                    ds.reference.delete();
                  }
                });

                Firestore.instance
                    .collection('supplyVochers')
                    .document(widget.supplier.id)
                    .collection('supplierVochers')
                    .getDocuments()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.documents) {
                    ds.reference
                        .collection('supplyItems')
                        .getDocuments()
                        .then((snapshot) {
                      for (DocumentSnapshot ds in snapshot.documents) {
                        ds.reference.delete();
                      }
                    });
                    ds.reference.delete();
                  }
                });

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
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: FlatButton(
        onLongPress: () {
          _showMyDialog();
        },
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return SalePage(widget.customer.name, widget.customer.id);
          // }));
          print(widget.supplier.id);

          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: Text('Supplier : ${widget.supplier.name}'),
                children: <Widget>[
                  SimpleDialogOption(
                    child: Text('Create New Voucher'),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SupplyVocherUpload(
                            widget.supplier.id, widget.supplier.name);
                      }));
                    },
                  ),
                  SimpleDialogOption(
                    child: Text('View History'),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SupplyVocherHistory(
                          supplierID: widget.supplier.id,
                          supplierName: widget.supplier.name,
                        );
                      }));
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                        widget.supplier.name,
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
