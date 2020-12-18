import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freelance_demo/services.dart';
import 'package:freelance_demo/models/supply_models/supplyItem.dart';
import 'package:intl/intl.dart';
import 'package:freelance_demo/screens/supply_screens/editSupplyItem.dart';
import 'package:uuid/uuid.dart';

class VocherWidget extends StatefulWidget {
  final String id;
  final String customerId;
  final int totalAmt;
  final int payAmt;
  final int leftAmt;
  final String customerName;

  final Timestamp timestamp;
  final Timestamp createdDate;
  final String creator;

  VocherWidget(
      {this.id,
      this.customerId,
      this.totalAmt,
      this.payAmt,
      this.leftAmt,
      this.timestamp,
      this.createdDate,
      this.customerName,
      this.creator});

  factory VocherWidget.fromDocument(doc) {
    return VocherWidget(
      id: doc['supplyVocherID'],
      customerId: doc['supplierID'],
      totalAmt: doc['totalAmt'],
      payAmt: doc['payAmt'],
      leftAmt: doc['leftAmt'],
      timestamp: doc['timestamp'],
      createdDate: doc['createdDate'],
      creator: doc['creator'],
    );
  }

  @override
  _VocherWidgetState createState() => _VocherWidgetState(
      id: this.id,
      customerId: this.customerId,
      totalAmt: this.totalAmt,
      payAmt: this.payAmt,
      leftAmt: this.leftAmt,
      timestamp: this.timestamp,
      createdDate: this.createdDate,
      creator: this.creator);
}

class _VocherWidgetState extends State<VocherWidget> {
  final String id;
  final String customerId;
  int totalAmt;
  int payAmt;
  int leftAmt;
  Timestamp timestamp;
  final Timestamp createdDate;
  final String creator;

  String lastPaidDate;
  String itemName;
  int itemPrice;
  double itemQuantity;
  int itemTotal;
  String itemID = Uuid().v4();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final SnackBar snackbar = SnackBar(content: Text("Saved!"));

  _VocherWidgetState(
      {this.id,
      this.customerId,
      this.totalAmt,
      this.payAmt,
      this.leftAmt,
      this.timestamp,
      this.createdDate,
      this.creator});

  int payInput;
  int paidAmt;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    lastPaidDate = DateFormat('yyyy-MM-dd').format(timestamp.toDate());

    paidAmt = payAmt;

    payInput = 0;
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
                    .collection('supplyVochers')
                    .document(customerId)
                    .collection('supplierVochers')
                    .document(id)
                    .collection('supplyItems')
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('supplyVochers')
            .document(widget.customerId)
            .collection('supplierVochers')
            .document(widget.id)
            .collection('supplyItems')
            .orderBy('datetime', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(),
                body: Center(child: CircularProgressIndicator()));
          }
          List<DataRow> newList = [];

          List<SupplyItem> items = [];
          List<int> itemsTotal = [];
          snapshot.data.documents.forEach((doc) {
            print(doc.data['supplyItemPrice']);
            SupplyItem item = SupplyItem.fromDocument(doc);

            items.add(item);
            itemsTotal.add(item.supplyTotal);
            // print(item.supplyTotal);

            newList.add(DataRow(
                onSelectChanged: (val) {
                  if (val) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: Text(item.supplyItem),
                          children: <Widget>[
                            SimpleDialogOption(
                              child: Text('Edit'),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return EditItem(
                                    currentItemID: item.supplyItemID,
                                    currentVocherID: id,
                                    customerID: customerId,
                                  );
                                }));
                              },
                            ),
                            SimpleDialogOption(
                              child: Text('Delete'),
                              onPressed: () {
                                Navigator.pop(context);
                                _showMyDialog(item.supplyItemID);
                              },
                            )
                          ],
                        );
                      },
                    );
                  }
                },
                cells: [
                  DataCell(Center(child: Text(item.supplyItem))),
                  DataCell(
                      Center(child: Text(item.supplyItemPrice.toString()))),
                  DataCell(
                      Center(child: Text(item.supplyItemQuantity.toString()))),
                  DataCell(Center(child: Text(item.supplyTotal.toString()))),
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
                                .collection('supplyVochers')
                                .document(customerId)
                                .collection('supplierVochers')
                                .document(id)
                                .updateData({
                              'totalAmt': totalAmt,
                              'payAmt': payAmt,
                              'leftAmt': leftAmt,
                              'timestamp': DateTime.now()
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
                title: Text('အဝယ်ဘောင်ချာ : ' + widget.customerName),
                centerTitle: false,
              ),
              body: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25.0, top: 25.0, bottom: 10.0),
                    child: Text(
                      'Created Date : ' +
                          DateFormat('yyyy-MM-dd').format(createdDate.toDate()),
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, bottom: 10.0),
                    child: Text(
                      'Creator : ' + creator,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
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
                      margin:
                          EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
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
                          // setState(() {
                          //   leftAmt = 0;
                          //   payAmt = 0;

                          //   leftAmt = totalAmt - paidInput;
                          //   payAmt = paidInput;
                          //   leftAmtTemp = leftAmt;
                          // });
                          // setState(() {
                          //   leftAmt = leftAmtTemp;
                          //   payAmt = payAmtTemp;

                          //   leftAmt = leftAmt - payInput;
                          //   payAmt = payAmt + payInput;
                          // });
                        },
                        child: Text(
                          'Update Total',
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
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                        DataColumn(label: Text('')),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(Text('Total Amount')),
                          DataCell(Text(':')),
                          DataCell(Text('    ' + totalAmt.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Paid Money')),
                          DataCell(Text(':')),
                          DataCell(Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: TextFormField(
                                style: TextStyle(fontSize: 13.0),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isEmpty || value == null) {
                                    paidAmt = 0;
                                  } else {
                                    paidAmt = int.parse(value);
                                  }
                                  setState(() {
                                    leftAmt = totalAmt - (paidAmt + payInput);
                                    payAmt = paidAmt + payInput;
                                  });
                                  setState(() {
                                    // leftAmt = leftAmtTemp;
                                    // payAmt = payAmtTemp;

                                    //leftAmt = leftAmt - payInput;
                                    // payAmt = payAmt + payInput;
                                  });
                                  print(payAmt);
                                },
                                initialValue: payAmt.toString(),
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    alignLabelWithHint: true,
                                    hintText: 'Enter Amount'),
                              ),
                            ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Last Paid Date')),
                          DataCell(Text(':')),
                          DataCell(
                            Text('     ' + lastPaidDate),
                          ),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            'Left Money',
                            style: TextStyle(
                                color:
                                    leftAmt == 0 ? Colors.green : Colors.red),
                          )),
                          DataCell(Text(':')),
                          DataCell(Text('     ' + leftAmt.toString(),
                              style: TextStyle(
                                  color: leftAmt == 0
                                      ? Colors.green
                                      : Colors.red))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pay Money')),
                          DataCell(Text(':')),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: TextField(
                                  onChanged: (value) {
                                    // payAmt = int.parse(value.trim());
                                    if (value == null ||
                                        value.isEmpty == true) {
                                      payInput = 0;
                                    } else {
                                      payInput = int.parse(value);
                                    }

                                    setState(() {
                                      // payController.text = value.trim();
                                      // leftAmt = leftAmtTemp;
                                      // payAmt = payAmtTemp;

                                      leftAmt = totalAmt - (paidAmt + payInput);
                                      payAmt = paidAmt + payInput;
                                    });
                                  },
                                  // onChanged: (value) {
                                  //   setState(() {
                                  //     // leftAmt = leftAmtTemp;
                                  //     // payAmt = payAmtTemp;
                                  //     // print(leftAmt);
                                  //   });
                                  //   // if (value == null || value.isEmpty) {}
                                  // },
                                  keyboardType: TextInputType.number,
                                  // controller: payController,
                                  style: TextStyle(fontSize: 13.0),
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(),
                                      focusedBorder: OutlineInputBorder(),
                                      alignLabelWithHint: true,
                                      hintText: 'Enter Amount'),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  )),
                  Center(
                      child: Container(
                    margin: EdgeInsets.only(
                        top: 10.0, left: 25.0, right: 25.0, bottom: 25.0),
                    height: 40.0,
                    width: MediaQuery.of(context).size.width,
                    child: FlatButton(
                      onPressed: () {
                        // int result = 0;
                        // items.forEach((item) {
                        //   result += item.total;
                        // });
                        // totalAmt = result;
                        // leftAmt = leftAmt - int.parse(payController.text);
                        // payAmt = payAmt + int.parse(payController.text);

                        Firestore.instance
                            .collection('supplyVochers')
                            .document(customerId)
                            .collection('supplierVochers')
                            .document(id)
                            .updateData({
                          'totalAmt': totalAmt,
                          'payAmt': payAmt,
                          'leftAmt': leftAmt,
                          'timestamp': DateTime.now()
                        }).whenComplete(() {
                          _scaffoldKey.currentState.showSnackBar(snackbar);
                        });
                        print('supply pay:' + payAmt.toString());
                        print('supply left:' + leftAmt.toString());
                        print('supply total:' + totalAmt.toString());

                        // setState(() {
                        //   lastPaidDate =
                        //       DateFormat('yyyy-MM-dd').format(DateTime.now());
                        // });
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
                  ))
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
                                      itemQuantity =
                                          double.parse(value.trim()).toDouble();
                                    },
                                  ),
                                  FlatButton(
                                    onPressed: () async {
                                      if (itemName == null ||
                                          itemName.trim().length == 0) {
                                      } else if (itemPrice == null) {
                                      } else if (itemQuantity == null) {
                                      } else {
                                        itemTotal =
                                            (itemPrice * itemQuantity).round();

                                        Firestore.instance
                                            .collection('supplyVochers')
                                            .document(customerId)
                                            .collection('supplierVochers')
                                            .document(id)
                                            .collection('supplyItems')
                                            .document(itemID)
                                            .setData({
                                          'supplyItemID': itemID,
                                          'supplyItem': itemName,
                                          'supplyItemPrice': itemPrice,
                                          'supplyItemQuantity': itemQuantity,
                                          'supplyTotal': itemTotal,
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
