// floatingActionButton: FloatingActionButton(
//                 backgroundColor: Colors.blueAccent,
//                 child: Icon(Icons.add),
//                 onPressed: () {
//                   showModalBottomSheet(
//                       isScrollControlled: true,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.only(
//                               topLeft: Radius.circular(20.0),
//                               topRight: Radius.circular(20.0))),
//                       context: context,
//                       builder: (BuildContext context) {
//                         return Container(
//                           padding: EdgeInsets.only(
//                               bottom: MediaQuery.of(context).viewInsets.bottom),
//                           child: SingleChildScrollView(
//                             child: Padding(
//                               padding: EdgeInsets.all(20.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                                 children: <Widget>[
//                                   Text(
//                                     'Add Item',
//                                     style: TextStyle(
//                                         color: Colors.lightBlueAccent,
//                                         fontSize: 30.0,
//                                         fontWeight: FontWeight.w600),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   TextField(
//                                     autofocus: false,
//                                     decoration: InputDecoration(
//                                         hintText: 'Enter item name',
//                                         enabledBorder: UnderlineInputBorder(
//                                             borderSide: BorderSide(
//                                                 color:
//                                                     Colors.lightBlueAccent))),
//                                     onChanged: (value) {
//                                       itemName = value;
//                                     },
//                                   ),
//                                   SizedBox(
//                                     height: 5.0,
//                                   ),
//                                   TextField(
//                                     keyboardType: TextInputType.number,
//                                     autofocus: false,
//                                     decoration: InputDecoration(
//                                         hintText: 'Enter item price',
//                                         enabledBorder: UnderlineInputBorder(
//                                             borderSide: BorderSide(
//                                                 color:
//                                                     Colors.lightBlueAccent))),
//                                     onChanged: (value) {
//                                       itemPrice = int.parse(value.trim());
//                                     },
//                                   ),
//                                   SizedBox(
//                                     height: 5.0,
//                                   ),
//                                   TextField(
//                                     keyboardType: TextInputType.number,
//                                     autofocus: false,
//                                     decoration: InputDecoration(
//                                         hintText: 'Enter item quantity',
//                                         enabledBorder: UnderlineInputBorder(
//                                             borderSide: BorderSide(
//                                                 color:
//                                                     Colors.lightBlueAccent))),
//                                     onChanged: (value) {
//                                       itemQuantity = int.parse(value.trim());
//                                     },
//                                   ),
//                                   FlatButton(
//                                     onPressed: () {
//                                       itemTotal = itemPrice * itemQuantity;

//                                       Firestore.instance
//                                           .collection('vochers')
//                                           .document(widget.customerID)
//                                           .collection('customerVochers')
//                                           .document(widget.vocherID)
//                                           .collection('items')
//                                           .document()
//                                           .setData({
//                                         'item': itemName,
//                                         'price': itemPrice,
//                                         'quantity': itemQuantity,
//                                         'total': itemTotal,
//                                         'datetime': DateTime.now()
//                                       });
//                                       Navigator.pop(context);
//                                     },
//                                     child: Text(
//                                       'Add',
//                                       style: TextStyle(color: Colors.white),
//                                     ),
//                                     color: Colors.lightBlueAccent,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       });
//                 },
//               ),
// @override
// Widget build(BuildContext context) {
//   return WillPopScope(
//     onWillPop: () async {
//       final value = await showDialog<bool>(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               content: Text('Are you sure you want to exit?'),
//               actions: <Widget>[
//                 FlatButton(
//                   child: Text('No'),
//                   onPressed: () {
//                     Navigator.of(context).pop(false);
//                   },
//                 ),
//                 FlatButton(
//                   child: Text('Yes, exit'),
//                   onPressed: () {
//                     Navigator.of(context).pop(true);
//                   },
//                 ),
//               ],
//             );
//           });

//       return value == true;
//     },
//     child: Scaffold(
//       appBar: AppBar(),
//       body: SafeArea(child: Container()),
//     ),
//   );
// }
