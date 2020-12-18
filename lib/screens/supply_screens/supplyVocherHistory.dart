import 'package:flutter/material.dart';
import 'package:freelance_demo/models/supply_models/supplyVocher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:freelance_demo/screens/supply_screens/supplyVocherScreen.dart';

class SupplyVocherHistory extends StatefulWidget {
  final String supplierID;
  final String supplierName;
  SupplyVocherHistory({this.supplierID, this.supplierName});
  @override
  _SupplyVocherHistoryState createState() => _SupplyVocherHistoryState();
}

class _SupplyVocherHistoryState extends State<SupplyVocherHistory> {
  // getUserProfile() async {
  //   QuerySnapshot querySnapshot = await Firestore.instance
  //       .collection('vochers')
  //       .document(widget.customerID)
  //       .collection('customerVochers')
  //       .getDocuments();

  //   setState(() {
  //     querySnapshot.documents.forEach((doc) {
  //       Vocher vocher = Vocher.fromDocument(doc);
  //       print(vocher.id);
  //       vocherTiles.add(VocherTile(
  //         vocher: vocher,
  //       ));
  //     });
  //   });
  //   print(vocherTiles.length);
  // }

  @override
  void initState() {
    super.initState();
  }

  int _val = DateTime.now().month;
  bool vocherCheck;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('အဝယ်စာရင်း : ' + widget.supplierName),
          centerTitle: false,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('supplyVochers')
                .document(widget.supplierID)
                .collection('supplierVochers')
                .orderBy('createdDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              List<VocherTile> vocherTiles = [];

              snapshot.data.documents.forEach((doc) {
                SupplyVocher supplyVocher = SupplyVocher.fromDocument(doc);
                DateTime date = supplyVocher.createdDate.toDate();

                if (date.month == _val) {
                  vocherTiles.add(VocherTile(
                    supplyVocher: supplyVocher,
                    supplierID: widget.supplierID,
                    supplierName: widget.supplierName,
                  ));
                }
              });

              if (vocherTiles.length == 0) {
                vocherCheck = false;
              } else {
                vocherCheck = true;
              }
              return ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border:
                            Border.all(color: Theme.of(context).primaryColor)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                          // dropdownColor: Theme.of(context).primaryColor,
                          elevation: 1,
                          isDense: false,
                          value: _val,
                          items: [
                            DropdownMenuItem(
                              child: Text("January"),
                              value: 1,
                            ),
                            DropdownMenuItem(
                              child: Text("February"),
                              value: 2,
                            ),
                            DropdownMenuItem(child: Text("March"), value: 3),
                            DropdownMenuItem(child: Text("April"), value: 4),
                            DropdownMenuItem(
                              child: Text("May"),
                              value: 5,
                            ),
                            DropdownMenuItem(
                              child: Text("June"),
                              value: 6,
                            ),
                            DropdownMenuItem(child: Text("July"), value: 7),
                            DropdownMenuItem(child: Text("August"), value: 8),
                            DropdownMenuItem(
                              child: Text("September"),
                              value: 9,
                            ),
                            DropdownMenuItem(
                              child: Text("October"),
                              value: 10,
                            ),
                            DropdownMenuItem(
                                child: Text("November"), value: 11),
                            DropdownMenuItem(child: Text("December"), value: 12)
                          ],
                          onChanged: (val) {
                            setState(() {
                              _val = val;
                              print(_val);
                            });
                          }),
                    ),
                  ),
                  Column(
                    children: vocherCheck
                        ? vocherTiles
                        : [
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list,
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Text('No Vocher')
                                ],
                              ),
                            )
                          ],
                  )
                ],
              );
            }));
  }
}

class VocherTile extends StatefulWidget {
  final SupplyVocher supplyVocher;
  final String supplierID;
  final String supplierName;

  VocherTile({this.supplyVocher, this.supplierID, this.supplierName});

  @override
  _VocherTileState createState() => _VocherTileState();
}

class _VocherTileState extends State<VocherTile> {
  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This voucher will be deleted.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Firestore.instance
                    .collection('supplyVochers')
                    .document(widget.supplierID)
                    .collection('supplierVochers')
                    .document(widget.supplyVocher.suppyVocherId)
                    .collection('supplyItems')
                    .getDocuments()
                    .then((snapshot) {
                  for (DocumentSnapshot ds in snapshot.documents) {
                    ds.reference.delete();
                  }
                });
                Firestore.instance
                    .collection('supplyVochers')
                    .document(widget.supplierID)
                    .collection('supplierVochers')
                    .document(widget.supplyVocher.suppyVocherId)
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
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: FlatButton(
        onPressed: () {
          //print('widget.supplyVocher.suppyVocherId');

          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return VocherScreen(
                supplierID: widget.supplierID,
                supplierName: widget.supplierName,
                supplyVocherID: widget.supplyVocher.suppyVocherId);
          }));
          //print(widget.vocher.id);
        },
        onLongPress: () {
          _showMyDialog();
          print(widget.supplyVocher.createdDate);
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
                child: Image(
                  image: widget.supplyVocher.leftAmt != 0
                      ? AssetImage('assets/images/unpaid.png')
                      : AssetImage('assets/images/paid.png'),
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
                        DateFormat('yyyy-MM-dd')
                            .format(widget.supplyVocher.createdDate.toDate()),
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                          DateFormat('h:mm a')
                              .format(widget.supplyVocher.createdDate.toDate()),
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.0),
                      widget.supplyVocher.leftAmt != 0
                          ? Text(
                              'Left Money : ${widget.supplyVocher.leftAmt}',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            )
                          : Text(
                              'Paid',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600),
                            ),
                      Text(
                        'Creator        : ${widget.supplyVocher.creator}',
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
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

// ListTile(
//           //DateFormat('yyyy-MM-dd-h:mm a').format()  DateFormat.yMd().add_jm()    -> 7/10/1996 5:08 P
//           leading: Image.asset('assets/images/paid.png'),
//           title: Text(DateFormat.yMMMd()
//               .add_jm()
//               .format(widget.vocher.createdDate.toDate())),
//           trailing: widget.vocher.leftAmt != 0
//               ? Text(
//                   'Left Money : ${widget.vocher.leftAmt.toString()}',
//                   style: TextStyle(color: Colors.red),
//                 )
//               : Text(
//                   'Left Money : ${widget.vocher.leftAmt.toString()}',
//                   style: TextStyle(color: Colors.blueAccent),
//                 ))
