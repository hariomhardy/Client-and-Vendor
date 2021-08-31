import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vendor_application_vendor/database_functions/vendor_functions.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/database_models/vendor.dart';
import 'package:vendor_application_vendor/profile_edit.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'database_models/order.dart';
import 'app_theme.dart';

class ProfilePage extends StatefulWidget {
  final Vendor vendor;

  ProfilePage({Key key, this.vendor}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StreamSubscription connectivitySubscription;

  ConnectivityResult previous;

  bool internetStatus = true;

  List<Order> orders = [];
  String vendorName;

  double rating;

  int booking;

  String businessName;

  String email;

  String mobile;

  String password;

  String imageUrl;

  @override
  void initState() {
    super.initState();
    print('Home Pages Called');
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult now) {
      if (now == ConnectivityResult.none) {
        print('Not Connected');
        internetStatus = false;
        noInternetConnectionDialog(context);
      } else if (previous == ConnectivityResult.none) {
        print('Connected');
        if (internetStatus == false) {
          internetStatus = true;
          Navigator.pop(context);
        }
      }
      previous = now;
    });
  }

  @override
  void dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  loadBooking() async {
    int currentOrdersToday = 0;
    orders = await getAllOrdersByVendorId(
        vendorUid: FirebaseAuth.instance.currentUser.uid);

    for (int i = 0; i < orders.length; i++) {
      if (orders[i].orderStatus == 'Pending' ||
          orders[i].orderStatus == 'Accepted') currentOrdersToday += 1;
    }

    if (this.mounted) {
      setState(() {
        this.booking = currentOrdersToday;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    loadBooking();
    imageUrl = widget.vendor.image;
    vendorName = widget.vendor.name;
    rating = 3; // TODO Harshit rating ??
    businessName = widget.vendor.businessName;
    email = widget.vendor.email;
    mobile = widget.vendor.mobile;
    password = widget.vendor.password;

    if (vendorName == null) {
      vendorName = ' --- ';
    }
    if (businessName == null) {
      businessName = ' --- ';
    }
    if (email == null) {
      email = ' --- ';
    }
    if (mobile == null) {
      mobile = ' --- ';
    }
    if (password == null) {
      password = ' --- ';
    }

    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText('Profile'),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              imageUrl == null
                  ? CircleAvatar(
                      radius: 50.0,
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      child: CircleAvatar(
                        radius: 48.0,
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
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                    ),
              SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: AutoSizeText(
                  vendorName,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: AutoSizeText(
                  'Total Booking : $booking',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: FlatButton(
                  color: Theme.of(context).secondaryHeaderColor,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileEditPage(
                                  vendor: widget.vendor,
                                )));
                  },
                  child: AutoSizeText(
                    'EDIT PROFILE',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        'Business Name : ' + businessName,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AutoSizeText(
                        'Email Id : ' + email,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AutoSizeText(
                        'Mobile : ' + mobile,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AutoSizeText(
                        'Password : ' + password,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
