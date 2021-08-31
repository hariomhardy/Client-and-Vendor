import 'dart:async';
import 'dart:io';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/category_card.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';
import 'package:vendor_application_client/utilites.dart';

import 'app_theme.dart';
import 'database_functions/order_functions.dart';
import 'main.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'database_models/category.dart';
import 'database_functions/user_functions.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_models/user.dart' ;
import 'vendor.dart';
import 'database_models/category.dart';
import 'package:auto_size_text/auto_size_text.dart' ;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<String> searchItems = <String>[];
  List<Category> categories = <Category>[];
  List<Category> currentCategories = <Category>[];
  bool progressIndicatorValue = true;
  TextEditingController searchBar = new TextEditingController();
  bool initData = true;
  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                color: Theme.of(context).primaryColor)));
  }
  loadInitData() async {
    if (initData) {
      // Loading all the categories field
      categories = await loadCategory();
      currentCategories = categories;
      print(categories);
      // Loading all the item names
      searchItems = await loadItemNames() ;
      initData = false;
    }
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




    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             channel.id,
    //             channel.name,
    //             channel.description,
    //             icon: android?.smallIcon,
    //           ),
    //         ));
    //   }
    // });

  }

  @override
  void dispose() {
    super.dispose() ;
    connectivitySubscription.cancel() ;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:  loadInitData() ,
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: ClampingScrollPhysics(),
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                        child: SimpleAutoCompleteTextField(
                          key: null,
                          suggestions: searchItems ,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Search Product',
                          ),
                          controller: searchBar,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        color: Colors.white,
                        icon: Icon(
                          Icons.search,
                          color: Theme.of(context).secondaryHeaderColor,
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      VendorPageByItem(
                                        searchRes : searchBar.text , byCategory: false  ,) ));
                        },
                      ),
                    ),
                  ],
                ),
                // TODO : We have to update the user admin email and phone number
                Card(
                  color: Theme.of(context).secondaryHeaderColor,
                  margin: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Got Query ?',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Reach out us at',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              ' +9100000011111',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: FlatButton(
                                color: Colors.red,
                                shape: StadiumBorder(),
                                child: Text(
                                  'Call',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () {
                                  print('Hello');
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
                  child: Text(
                    'Category',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).secondaryHeaderColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                ListView.builder(
                    primary: false,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: currentCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
                        child: Card(
                          elevation: 5,
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex : 1 ,
                                    child: currentCategories.elementAt(index).image == null
                                        ? Image.asset(
                                      'assets/images/bakery_kirana.png',
                                      height: 50,
                                      width: 50,
                                    )
                                        : Image.network(
                                      currentCategories.elementAt(index).image,
                                      height: 50,
                                      width: 50,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3 ,
                                    child: FlatButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(
                                                builder: (context) => VendorPageByItem(searchRes : currentCategories
                                                            .elementAt(index).categoryName , byCategory: true ,) ));
                                      },
                                      child: AutoSizeText(
                                        currentCategories
                                            .elementAt(index)
                                            .categoryName,
                                        style: GoogleFonts.lato(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                        maxLines : 1 ,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      );
                    }),
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
