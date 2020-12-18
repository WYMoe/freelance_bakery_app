import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance_demo/models/sale_models/item.dart';

class EditItem extends StatefulWidget {
  final String customerID;
  final String currentVocherID;
  final String currentItemID;

  EditItem({
    this.customerID,
    this.currentVocherID,
    this.currentItemID,
  });
  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  TextEditingController itemController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  Item currentItem;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool itemValidate = true;
  bool priceValidate = true;
  bool qtyValidate = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await Firestore.instance
        .collection('vochers')
        .document(widget.customerID)
        .collection('customerVochers')
        .document(widget.currentVocherID)
        .collection('items')
        .document(widget.currentItemID)
        .get();
    currentItem = Item.fromDocument(doc);
    itemController.text = currentItem.item;
    priceController.text = currentItem.price.toString();
    qtyController.text = currentItem.quantity.toString();

    setState(() {
      isLoading = false;
    });
  }

  updateItemData() {
    // widget.itemsOfVocherTotal.forEach((val) {
    //   result += val;
    // });
    // print(result);

    // Firestore.instance
    //     .collection('vochers')
    //     .document(widget.customerID)
    //     .collection('customerVochers')
    //     .document(widget.currentVocherID)
    //     .updateData({'totalAmt': result});

    if (itemController.text == null || itemController.text.trim().length == 0) {
      setState(() {
        itemValidate = false;
      });
    } else {
      setState(() {
        itemValidate = true;
      });
    }

    if (priceController.text == null ||
        priceController.text.trim().length == 0) {
      setState(() {
        priceValidate = false;
      });
    } else {
      setState(() {
        priceValidate = true;
      });
    }

    if (qtyController.text == null || qtyController.text.trim().length == 0) {
      setState(() {
        qtyValidate = false;
      });
    } else {
      setState(() {
        qtyValidate = true;
      });
    }

    if (itemValidate && priceValidate & qtyValidate) {
      int total =
          int.parse(priceController.text) * int.parse(qtyController.text);
      int result = 0;

      Firestore.instance
          .collection('vochers')
          .document(widget.customerID)
          .collection('customerVochers')
          .document(widget.currentVocherID)
          .collection('items')
          .document(widget.currentItemID)
          .updateData({
        'item': itemController.text.toString(),
        'price': int.parse(priceController.text),
        'quantity': int.parse(qtyController.text),
        'total': total
      }).whenComplete(() {
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text('Edit success!')));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Edit Item'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 30.0,
                          ),
                          buildEditFormColumn(
                              'Item', itemController, itemValidate),
                          SizedBox(
                            height: 20.0,
                          ),
                          buildEditFormColumn(
                              'Price', priceController, priceValidate),
                          SizedBox(
                            height: 20.0,
                          ),
                          buildEditFormColumn('Qty', qtyController, qtyValidate)
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      buildEditItemButton(
                          context: context,
                          buttonLabel: 'Done',
                          function: () {
                            updateItemData();
                          }),
                      SizedBox(
                        height: 20.0,
                      ),
                      // buildEditProfileButton(
                      //     context: context,
                      //     buttonLabel: 'Logout',
                      //     function: () {
                      //       services.googleSignIn.signOut();
                      //       Navigator.push(context,
                      //           MaterialPageRoute(builder: (context) {
                      //         return Home();
                      //       }));
                      //     })
                    ],
                  ),
                )
              ],
            ),
    );
  }

  FlatButton buildEditItemButton(
      {BuildContext context, String buttonLabel, Function function}) {
    return FlatButton(
        onPressed: () {},
        child: Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width * 0.5,
          margin: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
          child: FlatButton(
            onPressed: function,
            child: Text(
              buttonLabel,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.0),
              color: Theme.of(context).primaryColor),
        ));
  }

  Column buildEditFormColumn(
      String label, TextEditingController controller, bool isValid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: controller,
          keyboardType:
              label == 'Item' ? TextInputType.text : TextInputType.number,
          decoration: InputDecoration(errorText: isValid ? null : 'Error'),
        )
      ],
    );
  }
}
