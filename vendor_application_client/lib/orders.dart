import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/rating.dart';
import 'package:vendor_application_client/utilites.dart';

import 'app_theme.dart';
import 'main.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_models/order.dart';
import 'database_functions/order_functions.dart';
import 'database_functions/user_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_models/shop.dart';
import 'package:cool_alert/cool_alert.dart';
import 'orders_detail.dart';
import 'orders_edit.dart';
import 'database_functions/user_functions.dart';
import 'dart:async';
import 'database_models/user.dart' ;
import 'package:firebase_auth/firebase_auth.dart' ;

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
      orders = await getOrders(userUid: FirebaseAuth.instance.currentUser.uid);
      for (int i = 0; i < orders.length; i++) {
        Shop shop = await getShop(
            vendorId: orders.elementAt(i).vendorId,
            shopId: orders.elementAt(i).shopId);
        shops.add(shop);
      }
      initData = false ;
    }

  }

  loadPendingOrders() async {
    orders = await getPendingOrders(userUid : FirebaseAuth.instance.currentUser.uid );
    shops = [] ;
    for (int i = 0; i < orders.length; i++) {
      //print(orders[i].toJson().toString());
      Shop shop = await getShop(
          vendorId: orders.elementAt(i).vendorId,
          shopId: orders.elementAt(i).shopId);
      this.shops.add(shop);
    }
    print(shops.toString()) ;
    setState(() {
      this.orders = orders ;
      this.shops = shops ;
    });
  }

  loadPreviousOrders() async {
    orders = await getPreviousOrders(userUid : FirebaseAuth.instance.currentUser.uid );
    print(orders.toString());
    shops = [] ;
    shops = [] ;
    for (int i = 0; i < orders.length; i++) {
      Shop shop = await getShop(
          vendorId: orders.elementAt(i).vendorId,
          shopId: orders.elementAt(i).shopId);
      this.shops.add(shop);
    }
    print(shops.toString()) ;
    setState(() {
      this.orders = orders ;
      this.shops = shops ;
    });
  }

  loadAllOrders() async {
    orders = await getOrders(userUid: FirebaseAuth.instance.currentUser.uid);
    print(orders.toString()) ;
    shops = [] ;
    for (int i = 0; i < orders.length; i++) {
      Shop shop = await getShop(
          vendorId: orders.elementAt(i).vendorId,
          shopId: orders.elementAt(i).shopId);
      shops.add(shop);

    }
    print(shops.toString()) ;
    setState(() {
      this.orders = orders ;
      this.shops = shops ;
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

  FutureOr refresh(value) async {
    orders = await getOrders(userUid: FirebaseAuth.instance.currentUser.uid);
    for (int i = 0; i < orders.length; i++) {
      Shop shop = await getShop(
          vendorId: orders.elementAt(i).vendorId,
          shopId: orders.elementAt(i).shopId);
      shops.add(shop);
    }
    setState(() {
      this.orders = orders ;
      this.shops = shops ;
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
              if (orders
                  .elementAt(index)
                  .orderStatus == 'Pending') {
                print('Edit ' + 'Index : ' + index.toString());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OrderEditPage(
                              order: orders.elementAt(index),
                            ))).then(refresh);
              }
              else {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: 'Edit is only Possible till order is not Accepted',
                    onConfirmBtnTap: () {
                      Navigator.pop(context);
                    }
                );
              }
              break;
            case 3:
              print("Delete " + 'Index : ' + index.toString());
              if (orders
                  .elementAt(index)
                  .orderStatus == 'Pending') {
                Users user = await getUserProfile(
                    uid: FirebaseAuth.instance.currentUser.uid);
                bool val = await cancelOrder(user, orders.elementAt(index));
                if (val) {
                  CoolAlert.show(
                      context: context,
                      type: CoolAlertType.success,
                      text: 'Order Deleted',
                      onConfirmBtnTap: () {
                        Navigator.pop(context);
                        refresh(null);
                      }
                  );
                } else {
                  CoolAlert.show(
                      context: context,
                      type: CoolAlertType.success,
                      text: 'Order can\'t be deleted !! Try again',
                      onConfirmBtnTap: () {
                        Navigator.pop(context);
                      }
                  );
                }
              }
              else {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.success,
                    text: 'Order can\'t be deleted it is only possible till it is not Accepted',
                    onConfirmBtnTap: () {
                      Navigator.pop(context);
                    }
                );
              }
              break;

            case 4 :
              print('Rate Order');
              // TODO : Harshti check condition if user has already rated or not  ============>Done
              if (orders.elementAt(index).orderStatus == 'Rejected') {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: 'Rejected orders can\'t be rated.',
                    onConfirmBtnTap: () {
                      Navigator.pop(context);
                    }
                );
              }
              else if (orders.elementAt(index).orderStatus != 'Delivered') {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: 'Order can\'t be rated as it is not delivered yet.',
                    onConfirmBtnTap: () {
                      Navigator.pop(context);
                    }
                );
              }
              else if (orders.elementAt(index).isRated == true) {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: 'Order is already rated.',
                    onConfirmBtnTap: () {
                      Navigator.pop(context);
                    }
                );
              }
              else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RatingPage(
                              order: orders.elementAt(index),
                            )));
                break;
              }
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
              PopupMenuItem(
              value: 4,
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                    child: Icon(Icons.star_rate),
                  ),
                  Text(
                    'Rate Order',
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              )),
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
                              print('All is pressed');
                              loadAllOrders() ;
                            },
                          ),
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Upcoming',
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
                              print('Upcoming is pressed');
                              loadPendingOrders() ;
                            },
                          ),
                          FlatButton(
                            child: Card(
                              color: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Previous',
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
                              print('Previous is pressed');
                              loadPreviousOrders() ;
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
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
