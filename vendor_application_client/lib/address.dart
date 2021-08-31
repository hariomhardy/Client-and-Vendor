import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/category_card.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';
import 'package:vendor_application_client/utilites.dart';

import 'address_add.dart';
import 'app_theme.dart';
import 'main.dart';
import 'address_detail.dart';
import 'address_edit.dart';
import 'database_models/user_address.dart' ;
import 'database_functions/user_functions.dart' ;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_functions/user_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cool_alert/cool_alert.dart';
import 'dart:async' ;

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<UserAddress> addresses = <UserAddress> [] ;
  bool progressIndicatorValue = true ;
  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(indicatorType: Indicator.ballRotateChase , color: Theme.of(context).primaryColor ))) ;
  }

  Widget myPopMenu({int index}) {
    return PopupMenuButton(
        onSelected: (value) async {
          // 1 Details , 2 Edit , 3 Delete
          switch(value) {
            case 1 :
              print('Details ' +  'Index : ' +  index.toString()) ;
              Navigator.push(context , MaterialPageRoute(
                  builder: (context) => AddressDetailPage(address: addresses.elementAt(index))
              )) ;
              break ;
            case 2 :
              print('Edit '+  'Index : ' +  index.toString()) ;
              Navigator.push(context , MaterialPageRoute(
                  builder: (context) => AddressEditPage(address: addresses.elementAt(index))
              )).then(refreshScreen) ;
              break ;
            case 3 :
              print("Delete "+  'Index : ' +  index.toString()) ;
              bool val = await deleteAddress(uid: FirebaseAuth.instance.currentUser.uid , address: addresses.elementAt(index) );
              if (val == true ) {
                CoolAlert.show(
                  context: context ,
                  type: CoolAlertType.success ,
                  text : "Address Deleted Successfully !",
                  onConfirmBtnTap: () async {
                    Navigator.pop(context) ;
                    await refreshScreen(null) ;
                  }
                ) ;
              }
              else {
                CoolAlert.show(
                    context : context ,
                    type: CoolAlertType.error ,
                    text : 'Address is not deleted ! Please Try Again'
                );
              }

              break ;
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
                  Text('Details' , style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal ,
                    fontWeight: FontWeight.bold ,
                    fontSize: 14 ,
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
                  Text('Edit' , style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal ,
                    fontWeight: FontWeight.bold ,
                    fontSize: 14 ,
                  ),),
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
                  Text('Delete' , style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal ,
                    fontWeight: FontWeight.bold ,
                    fontSize: 14 ,
                  ),) ,
                ],
              )),
        ]);
  }

  Future<FutureOr> refreshScreen(dynamic value) async {
    addresses = await getUserAddresses(uid : FirebaseAuth.instance.currentUser.uid);
    setState(() {
      this.addresses = addresses ;
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
        future: getUserAddresses(uid : FirebaseAuth.instance.currentUser.uid),
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            addresses = snapshot.data ;
            return Scaffold(
              appBar: AppBar(
                title: Text('My Address'),
              ),
              body: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  ListView.builder(
                      itemCount: addresses.length ,
                      primary: false,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context , int index) {
                        return Card(
                          elevation: 5,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(addresses.elementAt(index).addressType , style : GoogleFonts.lato(
                                      fontWeight: FontWeight.bold ,
                                      fontSize: 16 ,
                                      fontStyle: FontStyle.normal ,
                                      color: Colors.black ,
                                    )),
                                    myPopMenu(index: index),
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                ),
                                Text('Name :  ' + addresses.elementAt(index).name , style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold ,
                                  fontSize: 16 ,
                                  fontStyle: FontStyle.normal ,
                                  color: Colors.black ,
                                ),),
                                Text('Mobile : ' + addresses.elementAt(index).mobile , style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold ,
                                  fontSize: 16 ,
                                  fontStyle: FontStyle.normal ,
                                  color: Colors.black ,
                                ),),
                                Text('Street Area : ' + addresses.elementAt(index).streetArea , style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold ,
                                  fontSize: 14 ,
                                  fontStyle: FontStyle.normal ,
                                  color: Colors.black ,
                                ),),
                                Text('Landmark : ' + addresses.elementAt(index).landmark , style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold ,
                                  fontSize: 14 ,
                                  fontStyle: FontStyle.normal ,
                                  color: Colors.black ,
                                ),),
                                Text('Description : ' + addresses.elementAt(index).description , style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold ,
                                  fontSize: 14 ,
                                  fontStyle: FontStyle.normal ,
                                  color: Colors.black ,
                                ),),
                              ],
                            ),
                          ),
                        );
                      })
                ],
              ),
              floatingActionButton: FloatingActionButton(
                // isExtended: true,
                child: Icon(Icons.add , color: Colors.white,),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                onPressed: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddressAddPage()),
                    ).then(refreshScreen);
                  });
                },
              ),
            );
          }
          else {
            return progressIndicator() ;
          }
        }
    );
  }
}

