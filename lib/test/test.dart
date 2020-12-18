// DataRow dataRow(Product product) {
//   int left = 0;
//   int pIn = 0;
//   int sale = 0;
//   int total = 0;
//   return DataRow(cells: [
//     DataCell(Text(product.product)),
//     DataCell(Padding(
//       padding: const EdgeInsets.only(top: 5.0),
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.3,
//         child: TextField(
//           onChanged: (value) {
//             if (value.isEmpty) {
//               left = 0;
//             } else {
//               left = int.parse(value.trim());
//             }

//             Firestore.instance
//                 .collection('productVochers')
//                 .document(productVocherID)
//                 .collection('products')
//                 .document(product.productID)
//                 .updateData({'productLeft': left});
//             left = 0;

//             // print('left :' + product.productLeft.toString());
//             // print('in:' + product.productIn.toString());
//             // print('sale:' + product.productSale.toString());
//             // print('total:' + product.productTotal.toString());
//           },
//           keyboardType: TextInputType.number,
//           style: TextStyle(fontSize: 13.0),
//           decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(),
//               focusedBorder: OutlineInputBorder(),
//               alignLabelWithHint: true,
//               hintText: 'Enter Amount'),
//         ),
//       ),
//     )),
//     DataCell(Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.3,
//         child: TextField(
//           onChanged: (value) {
//             if (value.isEmpty) {
//               pIn = 0;
//             } else {
//               pIn = int.parse(value.trim());
//             }

//             Firestore.instance
//                 .collection('productVochers')
//                 .document(productVocherID)
//                 .collection('products')
//                 .document(product.productID)
//                 .updateData({'productIn': pIn});
//             pIn = 0;

//             // print('left :' + product.productLeft.toString());
//             // print('in:' + product.productIn.toString());
//             // print('sale:' + product.productSale.toString());
//             // print('total:' + product.productTotal.toString());
//           },
//           keyboardType: TextInputType.number,
//           style: TextStyle(fontSize: 13.0),
//           decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(),
//               focusedBorder: OutlineInputBorder(),
//               alignLabelWithHint: true,
//               hintText: 'Enter Amount'),
//         ),
//       ),
//     )),
//     DataCell(Padding(
//       padding: const EdgeInsets.all(5.0),
//       child: SizedBox(
//         width: MediaQuery.of(context).size.width * 0.3,
//         child: TextField(
//           onChanged: (value) {
//             if (value.isEmpty) {
//               sale = 0;
//             } else {
//               sale = int.parse(value.trim());
//             }

//             Firestore.instance
//                 .collection('productVochers')
//                 .document(productVocherID)
//                 .collection('products')
//                 .document(product.productID)
//                 .updateData({'productSale': sale});
//             sale = 0;
//             // print('left :' + product.productLeft.toString());
//             // print('in:' + product.productIn.toString());
//             // print('sale:' + product.productSale.toString());
//             // print('total:' + product.productTotal.toString());
//             // Firestore.instance.collection('productVochers').document(productVocherID).collection(collectionPath)

//             // Firestore.instance
//             //     .collection('productVochers')
//             //     .document(productVocherID)
//             //     .collection('products')
//             //     .document(product.productID)
//             //     .updateData({
//             //   'productID': product.productID,
//             //   'product': product.product,
//             //   'productLeft': productLeft,
//             //   'productIn': productIn,
//             //   'productSale': productSale,
//             //   'productTotal': productTotal,
//             // });
//           },
//           keyboardType: TextInputType.number,
//           style: TextStyle(fontSize: 13.0),
//           decoration: InputDecoration(
//               enabledBorder: OutlineInputBorder(),
//               focusedBorder: OutlineInputBorder(),
//               alignLabelWithHint: true,
//               hintText: 'Enter Amount'),
//         ),
//       ),
//     )),
//     DataCell(IconButton(
//         icon: Icon(Icons.question_answer),
//         onPressed: () {
//           total =
//               (product.productIn + product.productLeft) - product.productSale;
//           Firestore.instance
//               .collection('productVochers')
//               .document(productVocherID)
//               .collection('products')
//               .document(product.productID)
//               .updateData({'productTotal': total});
//           total = 0;
//         })),
//     DataCell(Text(product.productTotal.toString()))
//   ]);
// }
