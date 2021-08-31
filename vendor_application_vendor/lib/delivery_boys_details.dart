import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'database_models/deliveryBoy.dart';
import 'delivery_boys.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryBoyDetailPage extends StatefulWidget {
  final VendorDeliveryBoy deliveryBoy ;
  DeliveryBoyDetailPage({Key key  , this.deliveryBoy}) : super(key : key) ;
  @override
  _DeliveryBoyDetailPageState createState() => _DeliveryBoyDetailPageState();
}

class _DeliveryBoyDetailPageState extends State<DeliveryBoyDetailPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;

  Widget customText({String title}) {
    return Text(title , style: GoogleFonts.lato(
      fontWeight: FontWeight.bold ,
      fontSize: 14 ,
      color: Colors.black ,
    ),);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Boy Details' ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
        child: ListView(
          children: [
            widget.deliveryBoy.image == null
                ? CircleAvatar(
              radius: 60.0,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              child: CircleAvatar(
                radius: 58.0,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(
                    'assets/images/person_profile_photo.jpg'),
              ),
            )
                : CircleAvatar(
              radius: 50.0,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              child: CircleAvatar(
                radius: 48.0,
                backgroundColor: Colors.white,
                backgroundImage:NetworkImage(widget.deliveryBoy.image),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(title : 'Name:') ,
                customText(title: widget.deliveryBoy.name) ,
              ],
            ) ,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(title : 'Mobile:') ,
                customText(title: widget.deliveryBoy.phoneNumber) ,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(title : 'Email') ,
                widget.deliveryBoy.emailId != null ? customText(title: widget.deliveryBoy.emailId) : customText(title : '---') ,
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                customText(title : 'Address') ,
                customText(title: widget.deliveryBoy.address.description) ,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
