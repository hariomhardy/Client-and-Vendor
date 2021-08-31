import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:vendor_application_vendor/database_functions/vendor_functions.dart';
import 'package:vendor_application_vendor/database_models/vendor.dart';
import 'package:vendor_application_vendor/profile.dart';
import 'package:vendor_application_vendor/shop.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'app_theme.dart';
import 'authentication_service.dart';
import 'delivery_boys.dart';
import 'package:vendor_application_vendor/login.dart';
import 'package:vendor_application_vendor/testing_dbms.dart';
import 'dart:async' ;
import 'package:cool_alert/cool_alert.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  bool progressIndicatorValue = true ;
  Widget progressIndicator() {
    return Center(
        child: Container(
          width: 100,
            height: 100,
            child: LoadingIndicator(indicatorType: Indicator.ballRotateChase , color: Theme.of(context).primaryColor ))) ;
  }
  String imageUrl ;
  String vendorName ;
  String mobile ;
  Vendor vendor ;

  FutureOr refresh(dynamic value) {
    setState(() {

    });
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
        future: getVendorProfile(uid : FirebaseAuth.instance.currentUser.uid),
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            vendor = snapshot.data ;
            imageUrl = vendor.image ;
            vendorName = vendor.name ;
            mobile = vendor.mobile ;
            if (imageUrl == null ) {
              imageUrl = null ;
            }
            if (vendorName == null ) {
              vendorName = ' --- ' ;
            }
            if (mobile == null) {
              mobile = ' --- ' ;
            }
            return ListView(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: AutoSizeText(
                    'Profile' ,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold ,
                      fontSize: 18 ,
                      color: Colors.black ,
                    ),
                    maxLines: 1,
                  ),
                ),
                Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                          backgroundImage:NetworkImage(imageUrl),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          AutoSizeText(
                            vendorName ,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            maxLines: 1 ,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          AutoSizeText(
                             mobile ,
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            maxLines: 1 ,
                          ),
                        ],
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () {
                              Navigator.push(context , MaterialPageRoute(builder: (context) => ProfilePage(vendor: vendor,))).then(refresh) ;
                          }),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(context , MaterialPageRoute(
                          builder: (context) => ShopPage(vendor: vendor,)
                      )) ;
                    },
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading:
                      Icon(Icons.location_on_outlined, color: Colors.white, size: 24),
                      title: AutoSizeText(
                        'My Shops',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                      trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(context , MaterialPageRoute(builder: (context) => DeliveryBoysPage(vendor: vendor,) ));
                    },
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading:
                      Icon(Icons.delivery_dining, color: Colors.white, size: 24),
                      title: AutoSizeText(
                        'View Delivery Boys',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed: () {},
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading: Icon(Icons.brightness_auto_outlined, color: Colors.white, size: 24),
                      title: Text(
                        'View Coupons',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed: () {} ,
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading: Icon(Icons.star, color: Colors.white, size: 24),
                      title: Text(
                        'Rate Us',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: FlatButton(
                    onPressed: () async {
                      bool val = await signOutUser();
                      if (val) {
                        CoolAlert.show(
                          barrierDismissible: false ,
                            context: context,
                            type: CoolAlertType.success,
                            text: "Logout Successfully !",
                            onConfirmBtnTap: () {
                              Navigator.pop(context) ;
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (BuildContext context) => EmailLoginPage()),
                                      (Route<dynamic> route) => false
                              );
                            }
                        );
                      }
                      else {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: 'Logout is not succeeded ! Please Try Again' ,
                            onConfirmBtnTap: () {
                              Navigator.pop(context) ;
                            }
                        );
                      }
                    },
                    color: Theme.of(context).secondaryHeaderColor,
                    child: Text(
                      'Logout',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          else {
            return progressIndicator() ;
          }

        }
    );
  }
}
