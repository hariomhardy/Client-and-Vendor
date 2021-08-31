import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/database_models/vendor.dart';
import 'package:vendor_application_vendor/profile.dart';
import 'package:vendor_application_vendor/shop.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'app_theme.dart';
import 'database_models/deliveryBoy.dart';
import 'delivery_boys_add.dart';
import 'delivery_boys_details.dart' ;
import 'delivery_boys_edit.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:vendor_application_vendor/database_functions/delivery_boy_functions.dart' ;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'dart:async' ;

class DeliveryBoysPage extends StatefulWidget {
  final Vendor vendor ;
  DeliveryBoysPage({Key key , this.vendor}) : super(key : key) ;
  @override
  _DeliveryBoysPageState createState() => _DeliveryBoysPageState();
}

class _DeliveryBoysPageState extends State<DeliveryBoysPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<VendorDeliveryBoy> deliveryBoys = <VendorDeliveryBoy> [];
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
              Navigator.push(context , MaterialPageRoute(builder: (context) => DeliveryBoyDetailPage(deliveryBoy: deliveryBoys.elementAt(index),) )) ;

              break ;
            case 2 :
              print('Edit '+  'Index : ' +  index.toString()) ;
              Navigator.push(context , MaterialPageRoute(builder: (context) => DeliveryBoysEditPage(vendor : widget.vendor , deliveryBoy: deliveryBoys.elementAt(index),) )).then((refresh)) ;

              break ;
            case 3 :
              print("Delete "+  'Index : ' +  index.toString()) ;
              bool val = await deleteDeliveryBoy(widget.vendor , deliveryBoys.elementAt(index)) ;
              if (val) {
                CoolAlert.show(
                  context: context,
                  type: CoolAlertType.success,
                  text: "Delivery Boy Deleted Successfully !",
                  onConfirmBtnTap: () {
                    Navigator.pop(context) ;
                    refresh(null) ;
                  }
                );
              }
              else {
                CoolAlert.show(
                    context: context,
                    type: CoolAlertType.error,
                    text: 'Delivery Boy not Deleted ! Please Try Again'
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
        future: loadingVendorDeliveryBoys(uid : FirebaseAuth.instance.currentUser.uid),
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            deliveryBoys = snapshot.data ;
            print(deliveryBoys) ;
            return Scaffold(
              appBar: AppBar(
                title: Text('Delivery Boys'),
              ),
              body: ListView.builder(
                  itemCount: deliveryBoys.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context , int index) {
                    return Card(
                      elevation: 15,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  deliveryBoys.elementAt(index).image == null
                                      ? CircleAvatar(
                                    radius: 40.0,
                                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                                    child: CircleAvatar(
                                      radius: 38.0,
                                      backgroundColor: Colors.white,
                                      backgroundImage: AssetImage(
                                          'assets/images/person_profile_photo.jpg'),
                                    ),
                                  )
                                      : CircleAvatar(
                                    radius: 40.0,
                                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                                    child: CircleAvatar(
                                      radius: 38.0,
                                      backgroundColor: Colors.white,
                                      backgroundImage:NetworkImage(deliveryBoys.elementAt(index).image),
                                    ),
                                  ),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(deliveryBoys.elementAt(index).name , style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold ,
                                          fontSize: 16 ,
                                          fontStyle: FontStyle.normal ,
                                          color: Colors.black ,
                                        ), maxLines: 3 ,),
                                        Text(deliveryBoys.elementAt(index).phoneNumber , style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold ,
                                          fontSize: 16 ,
                                          fontStyle: FontStyle.normal ,
                                          color: Colors.black ,
                                        ), maxLines: 3,),
                                        Text(deliveryBoys.elementAt(index).address.description , style: GoogleFonts.lato(
                                          fontWeight: FontWeight.bold ,
                                          fontSize: 14 ,
                                          fontStyle: FontStyle.normal ,
                                          color: Colors.black ,
                                        ), maxLines: 3,),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: myPopMenu(index: index),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add , color: Colors.white,),
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                onPressed: () {
                  Navigator.push(context , MaterialPageRoute(builder: (context) => DeliveryBoysAddPage( vendor : widget.vendor ) )).then(refresh) ;
                },
              ) ,
            );
          }
          else {
            return progressIndicator() ;
          }

        }
    );
  }
}

