import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleProduct.dart';
import 'package:freelance_demo/models/totalSale_models/totalSaleCustomer.dart';

class TotalSaleEditCustomer extends StatefulWidget {
  final String customerID;
  final String currentVocherID;

  final String productID;

  TotalSaleEditCustomer(
      {this.customerID, this.currentVocherID, this.productID});
  @override
  _TotalSaleEditCustomerState createState() => _TotalSaleEditCustomerState();
}

class _TotalSaleEditCustomerState extends State<TotalSaleEditCustomer> {
  TextEditingController nameController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  //TextEditingController qtyController = TextEditingController();
  TotalSaleCustomer customer;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool nameValidate = true;
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
        .collection('totalSaleVochers')
        .document(widget.currentVocherID)
        .collection('products')
        .document(widget.productID)
        .collection('customers')
        .document(widget.customerID)
        .get();
    customer = TotalSaleCustomer.fromDocument(doc);
    nameController.text = customer.name;
    qtyController.text = customer.qty.toString();
    // qtyController.text = currentItem.supplyItemQuantity.toString();

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

    if (nameController.text == null || nameController.text.trim().length == 0) {
      setState(() {
        nameValidate = false;
      });
    } else {
      setState(() {
        nameValidate = true;
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

    if (nameValidate && qtyValidate) {
      Firestore.instance
          .collection('totalSaleVochers')
          .document(widget.currentVocherID)
          .collection('products')
          .document(widget.productID)
          .collection('customers')
          .document(widget.customerID)
          .updateData({
        'name': nameController.text,
        'qty': int.parse(qtyController.text.trim())
      }).whenComplete(() async {
        QuerySnapshot qs = await Firestore.instance
            .collection('totalSaleVochers')
            .document(widget.currentVocherID)
            .collection('products')
            .document(widget.productID)
            .collection('customers')
            .getDocuments();

        int result = 0;

        qs.documents.forEach((doc) {
          result += doc['qty'];
        });

        Firestore.instance
            .collection('totalSaleVochers')
            .document(widget.currentVocherID)
            .collection('products')
            .document(widget.productID)
            .updateData({'total': result});

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
        title: Text('Edit Sale Data'),
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
                              'Name', nameController, nameValidate),
                          SizedBox(
                            height: 20.0,
                          ),
                          buildEditFormColumn(
                              'Quantity', qtyController, qtyValidate),
                          SizedBox(
                            height: 20.0,
                          ),
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
              label == 'Name' ? TextInputType.text : TextInputType.number,
          decoration: InputDecoration(errorText: isValid ? null : 'Error'),
        )
      ],
    );
  }
}
