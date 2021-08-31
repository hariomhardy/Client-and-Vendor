import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/items_add.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'package:vendor_application_vendor/utilities_functions/widgit_utilities.dart';
import 'app_theme.dart';
import 'database_models/shop.dart';
import 'database_models/vendor.dart';
import 'items_edit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_functions/vendor_functions.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_functions/user_functions.dart';
import 'database_models/item.dart';
import 'database_models/category.dart';
import 'package:cool_alert/cool_alert.dart';
import 'dart:async';

class ItemsPage extends StatefulWidget {
  final Category category;

  ItemsPage({Key key, this.category}) : super(key: key);

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<String> searchItems = <String>[];
  List<Item> items = <Item>[];

  List<Item> currentItems = <Item>[];

  bool progressIndicatorValue = true;

  bool initData = true;

  TextEditingController searchBar = new TextEditingController();

  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                color: Theme.of(context).primaryColor)));
  }

  searchResult() {
    print(searchBar.text);
    List<Item> newCurrentItems = <Item>[];
    for (int i = 0; i < items.length; i++) {
      print(items.elementAt(i).productName);
      if (items.elementAt(i).productName.startsWith(searchBar.text)) {
        print(items.elementAt(i).productName);
        newCurrentItems.add(items.elementAt(i));
      }
    }
    for (int i = 0; i < newCurrentItems.length; i++) {
      print(newCurrentItems.elementAt(i).productName);
    }
    print(newCurrentItems);
    setState(() {
      currentItems = newCurrentItems;
    });
  }

  loadInitData() async {
    if (initData) {
      // load items
      items = await loadingVendorCategoryItems(
          uid: FirebaseAuth.instance.currentUser.uid,
          category: widget.category);
      currentItems = items;
      searchItems = <String>[];
      for (int i = 0; i < items.length; i++) {
        searchItems.add(items.elementAt(i).productName);
      }
      initData = false;
    }
  }

  FutureOr refresh(dynamic value) {
    setState(() {
      initData = true;
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
        future: loadInitData(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong');
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Items - ' + widget.category.categoryName),
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
                            suggestions: searchItems,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Search Items',
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
                        flex: 1,
                        child: IconButton(
                          color: Colors.white,
                          icon: Icon(
                            Icons.search,
                            color: Theme.of(context).secondaryHeaderColor,
                            size: 28,
                          ),
                          onPressed: searchResult,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  ListView.builder(
                      primary: false,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: currentItems.length,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      items.elementAt(index).image == null
                                          ? CircleAvatar(
                                              radius: 40.0,
                                              backgroundColor: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              child: CircleAvatar(
                                                radius: 38.0,
                                                backgroundColor: Colors.white,
                                                backgroundImage: AssetImage(
                                                    'assets/images/person_profile_photo.jpg'),
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 40.0,
                                              backgroundColor: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              child: CircleAvatar(
                                                radius: 38.0,
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                    items
                                                        .elementAt(index)
                                                        .image),
                                              ),
                                            ),
                                      Flexible(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              items
                                                  .elementAt(index)
                                                  .productName,
                                              style: GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                              maxLines: 3,
                                            ),
                                            Text(
                                              items
                                                  .elementAt(index)
                                                  .productDescription,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 3,
                                            ),
                                            Text(
                                              'Unit : ' +
                                                  items
                                                      .elementAt(index)
                                                      .quantity
                                                      .toString() +
                                                  ' ' +
                                                  items
                                                      .elementAt(index)
                                                      .quantityType,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 3,
                                            ),
                                            Text(
                                              'MRP: ' +
                                                  items
                                                      .elementAt(index)
                                                      .originalPrice
                                                      .toString(),
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 3,
                                            ),
                                            Text(
                                              'Best Price: ' +
                                                  items
                                                      .elementAt(index)
                                                      .discountPrice
                                                      .toString(),
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 3,
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.black,
                                              size: 24,
                                            ),
                                            onPressed: () async {
                                              bool val = await deleteItem(
                                                  item: items.elementAt(index));
                                              if (val) {
                                                CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.success,
                                                    text:
                                                        "Item deleted Successfully !",
                                                    onConfirmBtnTap: () {
                                                      Navigator.pop(context);
                                                      refresh(null);
                                                    });
                                              } else {
                                                CoolAlert.show(
                                                    context: context,
                                                    type: CoolAlertType.error,
                                                    text:
                                                        'Shop not deleted ! Please Try Again',
                                                    onConfirmBtnTap: () {
                                                      Navigator.pop(context);
                                                    });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      RaisedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ItemsEditPage(
                                                          item: items.elementAt(
                                                              index)))).then(
                                              refresh);
                                        },
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        child: Text(
                                          'Edit Item',
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
              floatingActionButton: FloatingActionButton(
                backgroundColor: Theme.of(context).secondaryHeaderColor,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () async {
                  Vendor vendor = await getVendorProfile(uid: FirebaseAuth.instance.currentUser.uid ) ;
                  List<Shop> shops = await getVendorShops(uid : FirebaseAuth.instance.currentUser.uid) ;
                  print(vendor.toJson()) ;
                  if (vendor.name == null) {
                    errorDialog(
                      context: context ,
                      title: 'Vendor Profile Error' ,
                      content: 'All the details of the vendor names and shops need to be updated in Accounts Section'
                    );
                    return ;
                  }
                  else if (vendor.name != null && shops.length == 0 ){
                    errorDialog(
                        context: context ,
                        title: 'Vendor-Shop Profile Error' ,
                        content: 'All the details of shops need to be updated in Accounts Section'
                    );
                    return ;
                  }
                  else if (vendor.name != null && shops.length > 0  ) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemsAddPage())).then(refresh);
                  }
                },
              ),
            );
          } else {
            return progressIndicator();
          }
        });
  }
}
