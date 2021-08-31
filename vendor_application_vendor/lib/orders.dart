import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:vendor_application_vendor/order_detail.dart';
import 'package:vendor_application_vendor/order_edit.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'database_models/order.dart';
import 'database_models/shop.dart';
import 'package:vendor_application_vendor/database_functions/vendor_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_theme.dart';
import 'dart:async';
import 'package:cool_alert/cool_alert.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  bool initData = true;
  List<Order> orders = <Order>[];

  List<Shop> shops = <Shop>[];

  loadInitData() async {
    if (initData) {
      orders = await getAllOrdersByVendorId(vendorUid:FirebaseAuth.instance.currentUser.uid);
      for (int i = 0; i < orders.length; i++) {
        print(orders[i].shopId.toString());
        Shop shop = await getShop(
            vendorId: orders.elementAt(i).vendorId,
            shopId: orders.elementAt(i).shopId);

        if (shop != null)
          shops.add(shop);
      }
      print(shops.toString());
      initData = false ;
    }
  }

  loadAllOrders() async{  //Vendor Id
    List<Order> currentOrders = <Order>[];
    List<Shop> currentShops = <Shop>[];
    currentOrders = await getAllOrdersByVendorId(vendorUid: FirebaseAuth.instance.currentUser.uid);
    for (int i = 0; i < currentOrders.length; i++) {
      Shop shop = await getShop(
          vendorId: currentOrders.elementAt(i).vendorId,
          shopId: currentOrders.elementAt(i).shopId);

      currentShops.add(shop);
    }
    setState(() {
      orders = currentOrders ;
      shops = currentShops ;
    });
  }

  loadOrdersByStatus(String status) async{  //String status
    List<Order> currentOrdersByStatus = <Order>[];
    List<Shop> currentShops = <Shop>[];
    currentOrdersByStatus = await getAllOrdersByVendorId(vendorUid:FirebaseAuth.instance.currentUser.uid);
    currentOrdersByStatus = getOrderByStatus(statusType: status,order: currentOrdersByStatus);
    for (int i = 0; i < currentOrdersByStatus.length; i++) {
      print(currentOrdersByStatus.elementAt(i).toJson().toString());
      Shop shop = await getShop(
          vendorId: currentOrdersByStatus.elementAt(i).vendorId,
          shopId: currentOrdersByStatus.elementAt(i).shopId);
      currentShops.add(shop);
    }
    setState(() {
      this.orders = currentOrdersByStatus ;
      this.shops = currentShops ;
    });
  }


  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                color: Theme.of(context).primaryColor)));
  }

  FutureOr refresh(dynamic value) {
    setState(() {
      initData = true ;
    });
  }

  Widget myPopMenu({int index}) {
    return PopupMenuButton(
        onSelected: (value) async {
          // 1 Details , 2 Edit , 3 Delete
          switch (value) {
            case 1:
              print('Details ' + 'Index : ' + index.toString());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailPage(order: orders.elementAt(index))));
              break;
            case 2:
              if (orders.elementAt(index).orderStatus != 'Delivered') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderEditPage(
                          order: orders.elementAt(index),
                        ))).then(refresh);
              }
              else {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: 'Order can\'t be updated after delivered! Please Try Again' ,
                    onConfirmBtnTap: () {
                      Navigator.pop(context) ;
                    }
                );
              }

              break;
            case 3:
              print("Delete " + 'Index : ' + index.toString());
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
              value: 1,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                    child: Icon(Icons.more),
                  ),
                  Text(
                    'Details',
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
          PopupMenuItem(
              value: 2,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                    child: Icon(Icons.edit_outlined),
                  ),
                  Text(
                    'Edit',
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
          /*
          PopupMenuItem(
              value: 3,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                    child: Icon(Icons.delete),
                  ),
                  Text(
                    'Delete',
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
           */
        ]);
  }

  @override
  void initState() {
    super.initState() ;
    print('Home Pages Called') ;
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult now){
      if (now == ConnectivityResult.none) {
        print('Not Connected') ;
        internetStatus = false ;
        noInternetConnectionDialog(context) ;
      }else if (previous == ConnectivityResult.none){
        print('Connected') ;
        if (internetStatus == false ) {
          internetStatus = true ;
          Navigator.pop(context) ;
        }
      }
      previous = now ;
    }) ;
  }

  @override
  void dispose() {
    super.dispose() ;
    connectivitySubscription.cancel() ;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadInitData(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              children: [
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 70, // fixed height
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        semanticChildCount: 6,
                        children: [
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'All',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {
                              loadAllOrders();
                              print('All');
                              ;
                            },
                          ),
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Pending',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {
                              loadOrdersByStatus("Pending");
                              print('Pending is pressed');
                              ;
                            },
                          ),
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Accepted',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {
                              loadOrdersByStatus('Accepted');
                              print('Accepted is pressed');
                              ;
                            },
                          ),
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Rejected',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {
                              loadOrdersByStatus('Rejected');
                              print('Rejected is pressed');
                              ;
                            },
                          ),
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Delivered',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {
                              loadOrdersByStatus('Delivered');
                              print('Delivered is pressed');
                              ;
                            },
                          ),
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Cancelled',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            onPressed: () {
                              loadOrdersByStatus('Cancelled');
                              print('Cancelled is pressed');
                              ;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: orders.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 2, 10, 5),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex : 1 ,
                                  child: shops.elementAt(index).image == null
                                      ? CircleAvatar(
                                    radius: 60.0,
                                    backgroundColor: Theme.of(context)
                                        .secondaryHeaderColor,
                                    child: CircleAvatar(
                                      radius: 58.0,
                                      backgroundColor: Colors.white,
                                      backgroundImage: AssetImage(
                                          'assets/images/person_profile_photo.jpg'),
                                    ),
                                  )
                                      : CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor: Theme.of(context)
                                        .secondaryHeaderColor,
                                    child: CircleAvatar(
                                      radius: 48.0,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          shops.elementAt(index).image),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        orders
                                            .elementAt(index)
                                            .orderStatus,
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        shops.elementAt(index).shopName,
                                        style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Booking Id : ' + orders.elementAt(index).orderId,
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Payment Type : ' + orders
                                            .elementAt(index)
                                            .paymentType,
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Slot Date: ' + orders.elementAt(index).slotDate,
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Slot Time : ' +
                                            orders
                                                .elementAt(index)
                                                .slotStartTime +
                                            '- ' +
                                            orders
                                                .elementAt(index)
                                                .slotEndTime,
                                        style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(flex : 1 , child: myPopMenu(index: index)),

                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ],
            );
          } else {
            return progressIndicator();
          }
        });
  }
}