import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/models/sale_models/item.dart';
import 'package:freelance_demo/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';
import 'package:freelance_demo/models/sale_models/vocher.dart';
import 'package:intl/intl.dart';
import 'package:freelance_demo/screens/sale_screens/editItem.dart';

class VocherUpload extends StatefulWidget {
  final String name;
  final String id;

  VocherUpload(this.id, this.name);
  @override
  _VocherUploadState createState() => _VocherUploadState();
}

class _VocherUploadState extends State<VocherUpload> {
  TextEditingController controller = TextEditingController();
  TextEditingController amtController = TextEditingController();
  TextEditingController payController = TextEditingController();
  String itemName;
  int itemPrice;
  int itemQuantity;
  int itemTotal;
  List<int> vocherTotal = [];
  String vocherID = Uuid().v4();
  String itemID = Uuid().v4();
  Vocher vocher;
  int totalAmt = 0;
  int payAmt = 0;
  int leftAmt = 0;
  String paydate = 'Year-Month-Day';
  DateTime createdDate;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));
  // void getTotalAmt() async {
  //   var doc = await Firestore.instance
  //       .collection('vochers')
  //       .document(widget.id)
  //       .collection('customerVochers')
  //       .document(vocherID)
  //       .get();
  //   vocher = Vocher.fromDocument(doc);
  //   setState(() {
  //     totalAmt = vocher.totalAmt.toString();
  //   });

  //   print(vocher.totalAmt);
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    createdDate = DateTime.now();
  }

  Future<void> _showMyDialog(String itemId) async {
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
                    .collection('vochers')
                    .document(widget.id)
                    .collection('customerVochers')
                    .document(vocherID)
                    .collection('items')
                    .document(itemId)
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

  checkAndDelete() async {
    DocumentSnapshot doc = await Firestore.instance
        .collection('vochers')
        .document(widget.id)
        .collection('customerVochers')
        .document(vocherID)
        .get();

    if (doc.data == null) {
      Firestore.instance
          .collection('vochers')
          .document(widget.id)
          .collection('customerVochers')
          .document(vocherID)
          .collection('items')
          .getDocuments()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.documents) {
          ds.reference.delete();
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    checkAndDelete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('vochers')
            .document(widget.id)
            .collection('customerVochers')
            .document(vocherID)
            .collection('items')
            .orderBy('datetime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()));
          }
          List<DataRow> newList = [];
          List<int> itemsTotal = [];
          snapshot.data.documents.forEach((doc) {
            Item item = Item.fromDocument(doc);
            itemsTotal.add(item.total);

            newList.add(DataRow(
                onSelectChanged: (value) {
                  if (value) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: Text(item.item),
                          children: <Widget>[
                            SimpleDialogOption(
                              child: Text('Edit'),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EditItem(
                                    customerID: widget.id,
                                    currentVocherID: vocherID,
                                    currentItemID: item.itemID,
                                  );
                                }));
                              },
                            ),
                            SimpleDialogOption(
                              child: Text('Delete'),
                              onPressed: () {
                                Navigator.pop(context);
                                _showMyDialog(item.itemID);
                              },
                            )
                          ],
                        );
                      },
                    );
                  }
                },
                cells: [
                  DataCell(Center(child: Text(item.item))),
                  DataCell(Center(child: Text(item.price.toString()))),
                  DataCell(Center(child: Text(item.quantity.toString()))),
                  DataCell(Center(child: Text(item.total.toString()))),
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
                            Firestore.instance
                                .collection('vochers')
                                .document(widget.id)
                                .collection('customerVochers')
                                .document(vocherID)
                                .setData({
                              'createdDate': createdDate,
                              'customerID': widget.id,
                              'vocherID': vocherID,
                              'totalAmt': totalAmt,
                              'payAmt': payAmt,
                              'leftAmt': leftAmt,
                              'timestamp': DateTime.now(),
                              'creator': creator
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
                title: Text('အရောင်းဘောင်ချာ : ' + widget.name),
                centerTitle: false,
              ),
              body: ListView(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, top: 25.0, bottom: 10.0),
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
                          DataColumn(label: Text('Item'), numeric: true),
                          DataColumn(label: Text('Price'), numeric: true),
                          DataColumn(label: Text('Qty'), numeric: true),
                          DataColumn(label: Text('Total'), numeric: true),
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
                        itemsTotal.forEach((val) {
                          result += val;
                        });
                        leftAmt = result - payAmt;

                        setState(() {
                          totalAmt = result;
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(columns: [
                      DataColumn(label: Text('')),
                      DataColumn(label: Text('')),
                      DataColumn(label: Text(''))
                    ], rows: [
                      DataRow(cells: [
                        DataCell(Text('Total Amount')),
                        DataCell(Text(':')),
                        DataCell(Text('    ' + totalAmt.toString()))
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Pay Money')),
                        DataCell(Text(':')),
                        DataCell(Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextField(
                              onChanged: (value) {
                                if (value.isEmpty || value == null) {
                                  payAmt = 0;
                                } else {
                                  payAmt = int.parse(value.trim());
                                }

                                setState(() {
                                  leftAmt = totalAmt - payAmt;
                                  paydate = DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now());
                                });
                              },
                              keyboardType: TextInputType.number,
                              controller: payController,
                              style: TextStyle(fontSize: 13.0),
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                  hintText: 'Enter Amount'),
                            ),
                          ),
                        ))
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Pay Date')),
                        DataCell(Text(':')),
                        DataCell(Text(paydate))
                      ]),
                      DataRow(cells: [
                        DataCell(Text(
                          'Left Money',
                          style: TextStyle(
                              color: leftAmt == 0 ? Colors.green : Colors.red),
                        )),
                        DataCell(Text(':')),
                        DataCell(Text('    ' + leftAmt.toString(),
                            style: TextStyle(
                                color:
                                    leftAmt == 0 ? Colors.green : Colors.red)))
                      ]),
                    ]),
                  ),
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40.0,
                    margin: EdgeInsets.only(
                        top: 10.0, left: 25.0, right: 25.0, bottom: 25.0),
                    child: FlatButton(
                      onPressed: () async {
                        Firestore.instance
                            .collection('vochers')
                            .document(widget.id)
                            .collection('customerVochers')
                            .document(vocherID)
                            .setData({
                          'createdDate': createdDate,
                          'customerID': widget.id,
                          'vocherID': vocherID,
                          'totalAmt': totalAmt,
                          'payAmt': payAmt,
                          'leftAmt': leftAmt,
                          'timestamp': DateTime.now(),
                          'creator': 'MT_Admin'
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
                                    'Add Item',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  TextField(
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'Enter Item Name',
                                        enabledBorder: UnderlineInputBorder()),
                                    onChanged: (value) {
                                      itemName = value;
                                    },
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'Enter Item Price',
                                        enabledBorder: UnderlineInputBorder()),
                                    onChanged: (value) {
                                      itemPrice = int.parse(value.trim());
                                    },
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                        hintText: 'Enter Item Quantity',
                                        enabledBorder: UnderlineInputBorder()),
                                    onChanged: (value) {
                                      itemQuantity = int.parse(value.trim());
                                    },
                                  ),
                                  FlatButton(
                                    onPressed: () {
                                      if (itemName == null ||
                                          itemName.trim().length == 0) {
                                      } else if (itemPrice == null) {
                                      } else if (itemQuantity == null) {
                                      } else {
                                        itemTotal = itemPrice * itemQuantity;
                                        vocherTotal.add(itemTotal);

                                        Firestore.instance
                                            .collection('vochers')
                                            .document(widget.id)
                                            .collection('customerVochers')
                                            .document(vocherID)
                                            .collection('items')
                                            .document(itemID)
                                            .setData({
                                          'itemID': itemID,
                                          'item': itemName,
                                          'price': itemPrice,
                                          'quantity': itemQuantity,
                                          'total': itemTotal,
                                          'datetime': DateTime.now()
                                        });

                                        setState(() {
                                          itemID = Uuid().v4();
                                          itemName = '';
                                          itemPrice = null;
                                          itemQuantity = null;
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
