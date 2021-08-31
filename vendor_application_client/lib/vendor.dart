import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vendor_application_client/utilites.dart';
import 'database_models/vendor.dart';
import 'database_models/shop.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_functions/user_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'shop.dart';
import 'database_models/category.dart';

class VendorPage extends StatefulWidget {
  final Vendor vendor ;
  VendorPage({Key key , this.vendor}) : super(key : key) ;
  @override
  _VendorPageState createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<String> searchShops = <String> [] ;
  List<Shop> shops = <Shop> [] ;
  List<Shop> currentShops = <Shop> [] ;
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

  loadInitData() async {
    if (initData) {
      // Loading all the categories field
      shops = await loadShopsByVendor(vendorId: widget.vendor.vendorId) ;
      currentShops = shops  ;

      // Loading all the vendor names
      for (int i = 0 ; i < shops.length ; i++) {
        searchShops.add(shops.elementAt(i).shopName) ;
      }
      initData = false;
    }
  }

  searchResult() {
    print(searchBar.text) ;
    List<Shop> newShops = <Shop> [] ;
    for (int i = 0 ; i< shops.length ; i++ ) {
      if (shops.elementAt(i).shopName.startsWith(searchBar.text)) {
        newShops.add(shops.elementAt(i)) ;
      }
    }
    setState(() {
      currentShops = newShops ;
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
              print(sortByNameAscend) ;
              setState(() {
                currentShops.sort((a,b) => a.shopName.compareTo(b.shopName)) ;
                if (!sortByNameAscend) {
                  currentShops = currentShops.reversed.toList() ;
                }
                sortByNameAscend = ! sortByNameAscend ;
                print(currentShops.elementAt(0).shopName) ;
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
                  widget.vendor.name,
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
                  SizedBox(
                    height : 10 ,
                  ) ,
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                          child: SimpleAutoCompleteTextField(
                            key: null,
                            suggestions: searchShops,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Search Shops',
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
                          },
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
                      itemCount: currentShops.length,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      currentShops.elementAt(index).image == null
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
                                          backgroundImage:NetworkImage(currentShops.elementAt(index).image),
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentShops.elementAt(index).shopName,
                                              style: GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              currentShops.elementAt(index).shopNumber,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              // TODO : Rating ko dynamic bana hai  ==============>Done
                                              currentShops.elementAt(index).rating == null ?
                                              'Rating : No rating yet':
                                              'Rating : ${currentShops.elementAt(index).rating.overallRating/currentShops.elementAt(index).rating.count}',
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              // TODO : Rating by Users ko dynamic bana hai ===========>Done
                                              currentShops.elementAt(index).rating == null ?
                                              'Rating\'s Count by Users: 0':
                                              'Rating\'s Count by Users: ${currentShops.elementAt(index).rating.count}',
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(currentShops.elementAt(index).openTime.toString() +
                                                    '-' +
                                                    currentShops.elementAt(index).closeTime.toString()),
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.bike_scooter,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                currentShops.elementAt(index).deliveryOptions == true ? Text ('Yes') : Text('No')
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // TODO : Geo-location part is being commented plz review it
                                      /*
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                          Text(
                                            // TODO Geo location task
                                            '30',
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                       */
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RaisedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context ,
                                              MaterialPageRoute(
                                                  builder: (context) => ShopPage(vendor: widget.vendor ,
                                                  shop: currentShops.elementAt(index) )
                                              )
                                          );
                                        },
                                        color: Theme.of(context).secondaryHeaderColor,
                                        child: Text(
                                          'View More ...',
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
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

class VendorPageByItem extends StatefulWidget {
  final String searchRes ;
  final bool byCategory ;
  VendorPageByItem({Key key , this.searchRes , this.byCategory }) : super(key: key) ;
  @override
  _VendorPageByItemState createState() => _VendorPageByItemState();
}

class _VendorPageByItemState extends State<VendorPageByItem> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<String> searchShops = <String> [] ;
  List<Shop> shops = <Shop> [] ;
  List<Shop> currentShops = <Shop> [] ;
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

  loadInitData() async {
    if (initData) {
      // Loading all the categories field
      if (widget.byCategory) {
        shops = await getShopsByCategory(categoryName: widget.searchRes) ;
      }
      else {
        shops = await getShopsByItem(productName: widget.searchRes) ;
      }

      currentShops = shops  ;

      // Loading all the vendor names
      for (int i = 0 ; i < shops.length ; i++) {
        searchShops.add(shops.elementAt(i).shopName) ;
      }
      initData = false;
    }
  }

  searchResult() {
    print(searchBar.text) ;
    List<Shop> newShops = <Shop> [] ;
    for (int i = 0 ; i< shops.length ; i++ ) {
      if (shops.elementAt(i).shopName.startsWith(searchBar.text)) {
        newShops.add(shops.elementAt(i)) ;
      }
    }
    setState(() {
      currentShops = newShops ;
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
              print(sortByNameAscend) ;
              setState(() {
                currentShops.sort((a,b) => a.shopName.compareTo(b.shopName)) ;
                if (!sortByNameAscend) {
                  currentShops = currentShops.reversed.toList() ;
                }
                sortByNameAscend = ! sortByNameAscend ;
                print(currentShops.elementAt(0).shopName) ;
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
                  widget.searchRes,
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
                  SizedBox(
                    height : 10 ,
                  ) ,
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                          child: SimpleAutoCompleteTextField(
                            key: null,
                            suggestions: searchShops,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Search Shops',
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
                          },
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
                      itemCount: currentShops.length,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Expanded(
                                        flex : 1 ,
                                        child: currentShops.elementAt(index).image == null
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
                                            backgroundImage:NetworkImage(currentShops.elementAt(index).image),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentShops.elementAt(index).shopName,
                                              style: GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              currentShops.elementAt(index).shopNumber,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.fade,
                                            ),
                                            AutoSizeText(
                                              // TODO : Rating ko dynamic bana hai ==============>Done
                                              currentShops.elementAt(index).rating == null ?
                                              'Rating : No rating yet':
                                              'Rating : ${currentShops.elementAt(index).rating.overallRating/currentShops.elementAt(index).rating.count}',
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                            ),
                                            AutoSizeText(
                                              // TODO : Rating by Users ko dynamic bana hai =============> Done
                                              currentShops.elementAt(index).rating == null ?
                                              'Rating\'s Count by Users: 0':
                                              'Rating\'s Count by Users: ${currentShops.elementAt(index).rating.count}',
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                AutoSizeText('Shop Time : ' +  currentShops.elementAt(index).openTime.toString() +
                                                    '-' +
                                                    currentShops.elementAt(index).closeTime.toString() , maxLines: 1,),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.bike_scooter,
                                                  size: 16,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                currentShops.elementAt(index).deliveryOptions == true ? Text ('Delivery : Yes') : Text('Delivery : No')
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // TODO : Geo-location part is being commented plz review it
                                      /*
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: Colors.black,
                                            size: 18,
                                          ),
                                          Text(
                                            // TODO Geo location task
                                            '30',
                                            style: GoogleFonts.lato(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                       */
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RaisedButton(
                                        onPressed: () async {
                                          // TODO : get
                                          Vendor vendor = await getVendorOfShop(shop : currentShops.elementAt(index)) ;
                                          print(vendor.toJson().toString());
                                          Navigator.push(
                                              context ,
                                              MaterialPageRoute(
                                                  builder: (context) => ShopPage(vendor: vendor ,
                                                      shop: currentShops.elementAt(index) )
                                              )
                                          );
                                        },
                                        color: Theme.of(context).secondaryHeaderColor,
                                        child: Text(
                                          'View More ...',
                                          style: GoogleFonts.lato(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
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
