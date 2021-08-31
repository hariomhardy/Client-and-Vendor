import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/database_functions/vendor_functions.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'app_theme.dart';
import 'database_models/order.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<Order> orders = [];
  int pendingOrder,acceptedOrders,deliveredOrders,rejectedOrders,ordersToday,totalOrders;


  @override
  void initState() {
    super.initState() ;
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

  load() async{
    int currentPendingOrder= 0;
    int currentAcceptedOrders=0;
    int currentDeliveredOrders=0;
    int currentRejectedOrders=0;
    int currentOrdersToday =0;
    int currentTotalOrders =0;

    orders = await getAllOrdersByVendorId(vendorUid:FirebaseAuth.instance.currentUser.uid);
    for (int i = 0;i<orders.length;i++){
          if (orders[i].orderStatus == 'Pending')
            currentPendingOrder += 1;
          if (orders[i].orderStatus == 'Accepted')
            currentAcceptedOrders += 1;
          if (orders[i].orderStatus == 'Rejected')
            currentRejectedOrders += 1;
          if (orders[i].orderStatus == 'Delivered')
            currentDeliveredOrders += 1;
      }

      currentOrdersToday = currentPendingOrder+currentAcceptedOrders;
      currentTotalOrders = currentOrdersToday + currentDeliveredOrders;

      if (this.mounted) {
          setState(() {
            this.pendingOrder = currentPendingOrder;
            this.acceptedOrders = currentAcceptedOrders;
            this.deliveredOrders = currentDeliveredOrders;
            this.rejectedOrders = currentRejectedOrders;
            this.ordersToday = currentOrdersToday;
            this.totalOrders = currentTotalOrders;
          });
      }
  }



  @override
  Widget build(BuildContext context) {
    // TODO : Tasks by make the summary count of all the orders dynamic =====> Already done in "Today's Orders"
    load();
    return Container(
      child: ListView(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ListTile(
              tileColor: Theme.of(context).secondaryHeaderColor,
              leading: Icon(Icons.bookmark_border, color: Colors.white, size: 24),
              title: Text(
                'Total Orders',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
              trailing: Text('$totalOrders' ,style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ), ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ListTile(
              tileColor: Theme.of(context).secondaryHeaderColor,
              leading: Icon(Icons.bookmark_border, color: Colors.white, size: 24),
              title: Text(
                'Today Orders',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
              trailing: Text('$ordersToday' ,style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ), ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ListTile(
              tileColor: Theme.of(context).secondaryHeaderColor,
              leading: Icon(Icons.bookmark_border, color: Colors.white, size: 24),
              title: Text(
                'Pending',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
              trailing: Text('$pendingOrder' ,style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ), ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ListTile(
              tileColor: Theme.of(context).secondaryHeaderColor,
              leading: Icon(Icons.bookmark_border, color: Colors.white, size: 24),
              title: Text(
                'In Process',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
              trailing: Text('$acceptedOrders' ,style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ), ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ListTile(
              tileColor: Theme.of(context).secondaryHeaderColor,
              leading: Icon(Icons.bookmark_border, color: Colors.white, size: 24),
              title: Text(
                'Rejected',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
              trailing: Text('$rejectedOrders' ,style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ), ),
            ),
          ),

          //TODO : discuss  how to implement deliveryed as total orders and delivered is same.

          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ListTile(
              tileColor: Theme.of(context).secondaryHeaderColor,
              leading: Icon(Icons.bookmark_border, color: Colors.white, size: 24),
              title: Text(
                'Deliveryed',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                ),
              ),
              trailing: Text('$deliveredOrders' ,style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.normal,
                color: Colors.white,
              ), ),
            ),
          ),
          // TODO :  Add container for orders for which payment has been completed
        ],
      )
    );
  }
}
