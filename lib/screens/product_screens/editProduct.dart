import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freelance_demo/models/product_models/product.dart';

class EditProduct extends StatefulWidget {
  final String productVocherID;
  final String currentItemID;

  EditProduct({
    this.productVocherID,
    this.currentItemID,
  });
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  TextEditingController itemController = TextEditingController();
  TextEditingController leftController = TextEditingController();
  TextEditingController inController = TextEditingController();
  TextEditingController saleController = TextEditingController();

  Product currentItem;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  bool itemValidate = true;
  bool leftValidate = true;
  bool inValidate = true;
  bool saleValidate = true;

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
        .collection('productVochers')
        .document(widget.productVocherID)
        .collection('products')
        .document(widget.currentItemID)
        .get();
    currentItem = Product.fromDocument(doc);
    itemController.text = currentItem.product;
    leftController.text = currentItem.productLeft.toString();
    inController.text = currentItem.productIn.toString();
    saleController.text = currentItem.productSale.toString();

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

    if (leftController.text == null || leftController.text.trim().length == 0) {
      setState(() {
        leftValidate = false;
      });
    } else {
      setState(() {
        leftValidate = true;
      });
    }

    if (inController.text == null || inController.text.trim().length == 0) {
      setState(() {
        inValidate = false;
      });
    } else {
      setState(() {
        inValidate = true;
      });
    }

    if (saleController.text == null || saleController.text.trim().length == 0) {
      setState(() {
        saleValidate = false;
      });
    } else {
      setState(() {
        saleValidate = true;
      });
    }

    if (itemValidate && leftValidate & inValidate) {
      int total =
          (int.parse(leftController.text) + int.parse(inController.text)) -
              int.parse(saleController.text);
      int result = 0;

      Firestore.instance
          .collection('productVochers')
          .document(widget.productVocherID)
          .collection('products')
          .document(widget.currentItemID)
          .updateData({
        'product': itemController.text.toString(),
        'productLeft': int.parse(leftController.text),
        'productIn': int.parse(inController.text),
        'productSale': int.parse(saleController.text),
        'productTotal': total
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
                              'လက်ကျန်', leftController, leftValidate),
                          SizedBox(
                            height: 20.0,
                          ),
                          buildEditFormColumn('အဝင်', inController, inValidate),
                          buildEditFormColumn(
                              'အရောင်း', saleController, saleValidate)
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
