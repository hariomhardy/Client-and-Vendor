import 'dart:async';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/database_models/vendor.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';
import 'package:vendor_application_client/shop.dart';
import 'package:vendor_application_client/utilites.dart';

import 'app_theme.dart';
import 'main.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_functions/user_functions.dart';
import 'vendor.dart';

// ignore: must_be_immutable
class CategoryCardActivity extends StatefulWidget {
  String title;
  CategoryCardActivity({Key key, this.title}) : super(key: key);

  @override
  _CategoryCardActivityState createState() => _CategoryCardActivityState();
}

class _CategoryCardActivityState extends State<CategoryCardActivity> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<String> searchVendors = <String> [] ;
  List<Vendor> vendors = <Vendor> [] ;
  List<Vendor> currentVendors = <Vendor> [] ;
  bool progressIndicatorValue = true;
  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                color: Theme.of(context).primaryColor)));
  }
  TextEditingController searchBar = new TextEditingController();
  bool initData = true;
  bool sortByNameAscend = true ;
  bool sortByBusinessAscend = true ;

  loadInitData() async {
    if (initData) {
      // Loading all the categories field
      vendors = await loadVendorsByCategory(categoryName: widget.title) ;
      currentVendors = vendors ;

      // Loading all the vendor names
      for (int i = 0 ; i < vendors.length ; i++) {
        searchVendors.add(vendors.elementAt(i).name) ;
      }
      initData = false;
    }
  }

  searchResult() {
    print(searchBar.text) ;
    List<Vendor> newVendors = <Vendor> [] ;
    for (int i = 0 ; i< vendors.length ; i++ ) {
      if (vendors.elementAt(i).name.startsWith(searchBar.text)) {
        newVendors.add(vendors.elementAt(i)) ;
      }
    }
    setState(() {
      currentVendors = newVendors ;
    });
  }

  Widget myPopMenu() {
    return PopupMenuButton(
        child: Center(
          child: Container(
            padding: EdgeInsets.fromLTRB(5, 2, 5, 2),
            margin: EdgeInsets.fromLTRB(0, 5, 10, 5),
            color: Theme.of(context).secondaryHeaderColor,
            child: Row(
              children: [
                Text('Sort by' , style : GoogleFonts.lato(
                  fontWeight: FontWeight.bold ,
                  color: Colors.white ,
                ),) ,
                SizedBox(
                  width: 5,
                ) ,
                Icon(
                  Icons.compare_arrows,
                  size: 24,
                  color: Colors.white,
                ),
              ],
            ),
          ),
            ),
        onSelected: (value) async {
          // 1 Details , 2 Edit , 3 Delete
          switch(value) {
            case 1 :
              print('Name ') ;
              setState(() {
                currentVendors.sort((a,b) => a.name.compareTo(b.name)) ;
                if (!sortByNameAscend) {
                  currentVendors = currentVendors.reversed.toList() ;
                }
                sortByNameAscend = ! sortByNameAscend ;
              });
              break ;
            case 2 :
              print('Business Name') ;
              setState(() {
                currentVendors.sort((a,b) => a.businessName.compareTo(b.businessName)) ;
                if (!sortByBusinessAscend) {
                  currentVendors = currentVendors.reversed.toList() ;
                }
                sortByBusinessAscend = ! sortByBusinessAscend ;
              });
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
                  Text('Sort by Name' , style: GoogleFonts.lato(
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
                    child: Icon(Icons.more),
                  ),
                  Text('Sort by Business Name' , style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal ,
                    fontWeight: FontWeight.bold ,
                    fontSize: 14 ,
                  ),),
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
        future:  loadInitData() ,
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.title,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              body: ListView(
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
                            suggestions: searchVendors,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Search Vendors',
                            ),
                            controller: searchBar ,
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          color: Colors.white,
                          icon: Icon(
                            Icons.search,
                            color: Theme.of(context).secondaryHeaderColor,
                            size: 28,
                          ),
                          onPressed: () {
                            searchResult() ;
                          } ,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      myPopMenu() , 
                    ],
                  ),
                  ListView.builder(
                      primary: false,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: currentVendors.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.fromLTRB(5, 2, 5, 2),
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 2, 10, 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      currentVendors.elementAt(index).image == null
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
                                          backgroundImage:NetworkImage(currentVendors.elementAt(index).image),
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(currentVendors.elementAt(index).name ,
                                            style: GoogleFonts.lato(
                                              fontSize: 16 ,
                                              fontWeight: FontWeight.bold ,
                                            ),maxLines: 3,
                                              overflow: TextOverflow.fade,) ,
                                            Text(currentVendors.elementAt(index).businessName , style: GoogleFonts.lato(
                                              fontSize: 14 ,
                                              fontWeight: FontWeight.bold ,
                                            ),maxLines: 3,
                                              overflow: TextOverflow.fade,) ,
                                            Text(currentVendors.elementAt(index).email , style: GoogleFonts.lato(
                                              fontSize: 14 ,
                                              fontWeight: FontWeight.bold ,
                                            ),maxLines: 3,
                                              overflow: TextOverflow.fade,) ,
                                            Text(currentVendors.elementAt(index).mobile , style: GoogleFonts.lato(
                                              fontSize: 14 ,
                                              fontWeight: FontWeight.bold ,
                                            ),maxLines: 3,
                                              overflow: TextOverflow.fade,) ,
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      FlatButton(
                                        color: Theme.of(context).secondaryHeaderColor,
                                        child: Text('View Shops ...' , style: GoogleFonts.lato(
                                          fontSize: 14 ,
                                          fontWeight: FontWeight.bold ,
                                          color: Colors.white,
                                        ),),
                                        onPressed: () {
                                          Navigator.push(
                                              context ,
                                              MaterialPageRoute(
                                                  builder: (context) => VendorPage(vendor: currentVendors.elementAt(index),)
                                              )
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ],
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

