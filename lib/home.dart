import 'package:flutter/material.dart';

import 'package:freelance_demo/screens/supply_screens/supplierHomePage.dart';
import 'screens/sale_screens/myHomePage.dart';
import 'package:freelance_demo/curvePainter.dart';
import 'package:freelance_demo/screens/product_screens/productHomePage.dart';
import 'package:freelance_demo/screens/totalSale_screens/totalSaleHomePage.dart';
import 'screens/totalSale_screens/totalSaleHomePage.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xfffffddf),
      body: SafeArea(
        child: Stack(children: <Widget>[
          TopBar(),
          // Container(
          //   margin: EdgeInsets.all(15.0),
          //   padding: EdgeInsets.all(20.0),
          //   decoration: BoxDecoration(
          //       border: Border.all(color: Colors.deepPurple),
          //       borderRadius: BorderRadius.circular(15.0)),
          //   child: Text(
          //     'Myo Thant Bakery',
          //     style: TextStyle(
          //       color: Theme.of(context).primaryColor,
          //       fontSize: 20.0,
          //     ),
          //     textAlign: TextAlign.center,
          //   ),
          // ),

          Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1,
                    left: 10.0,
                    bottom: 10.0),
                child: Center(
                  child: Text(
                    'Myo Thant\nCookies',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'CreteRound',
                        color: Colors.white,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
              ),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 1.5,
                mainAxisSpacing: 1.5,
                shrinkWrap: true,
                children: <Widget>[
                  MainButton(
                    mainButtonName: 'အရောင်း\n(ကုန်သည်)',
                    route: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MyHomePage();
                      }));
                    },
                    cornertopleftValue: 20.0,
                    cornerbottomleftValue: 20.0,
                    cornerbottomrightValue: 20.0,
                    cornertoprightValue: 20.0,
                    image: 'customerIcon',
                  ),
                  MainButton(
                    mainButtonName: 'အဝယ်',
                    route: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SupplierHomePage();
                      }));
                    },
                    cornertopleftValue: 20.0,
                    cornerbottomleftValue: 20.0,
                    cornerbottomrightValue: 20.0,
                    cornertoprightValue: 20.0,
                    image: 'buyIcon',
                  ),
                  MainButton(
                    mainButtonName: 'မုန့်စာရင်း',
                    route: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ProductHomePage();
                      }));
                    },
                    cornertopleftValue: 20.0,
                    cornerbottomleftValue: 20.0,
                    cornerbottomrightValue: 20.0,
                    cornertoprightValue: 20.0,
                    image: 'montListIcon',
                  ),
                  MainButton(
                    mainButtonName: 'အရောင်းစာရင်း',
                    route: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TotalSaleHomePage();
                      }));
                    },
                    cornertopleftValue: 20.0,
                    cornerbottomleftValue: 20.0,
                    cornerbottomrightValue: 20.0,
                    cornertoprightValue: 20.0,
                    image: 'saleListicon',
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class MainButton extends StatelessWidget {
  final String mainButtonName;
  final Function route;
  final double cornertopleftValue;
  final double cornertoprightValue;
  final double cornerbottomleftValue;
  final double cornerbottomrightValue;
  final String image;

  MainButton(
      {this.mainButtonName,
      this.route,
      this.cornertopleftValue,
      this.cornertoprightValue,
      this.cornerbottomleftValue,
      this.cornerbottomrightValue,
      this.image});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: route,
      child: Card(
        margin: EdgeInsets.only(top: 6.0, bottom: 6.0, left: 15.0, right: 15.0),

        // color: Colors.lightBlueAccent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cornertopleftValue),
                topRight: Radius.circular(cornertoprightValue),
                bottomLeft: Radius.circular(cornerbottomleftValue),
                bottomRight: Radius.circular(cornerbottomrightValue))),
        elevation: 5.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: Image.asset('assets/images/${image}.png')),
            Expanded(
              child: Center(
                child: Text(
                  mainButtonName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color(0xff1f456e),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
