import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/cart.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/category_card.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';
import 'package:vendor_application_client/utilites.dart';

import 'app_theme.dart';
import 'database_models/user.dart';
import 'main.dart';
import 'database_models/vendor.dart';
import 'database_models/shop.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_functions/user_functions.dart';
import 'database_models/item.dart';
import 'database_functions/user_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ShopPage extends StatefulWidget {
  final Vendor vendor ;
  final Shop shop ;

  ShopPage({Key key, this.vendor , this.shop}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  List<String> searchItems = <String> [] ;
  List<Item> items = <Item> [] ;
  List<Item> currentItems = <Item> [] ;
  List<bool> currentItemsInCart = <bool> [] ;
  List<int> currentItemsInCartCount = <int> [] ;
  List<Item> currentCartItems = <Item> [] ;
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
  int itemCount = 0 ;
  double amount = 0 ;
  Users users ;

  loadInitData()  async {
    if (initData) {
      itemCount = 0 ;
      amount = 0 ;
      // loading the user profile
      users = await getUserProfile(uid: FirebaseAuth.instance.currentUser.uid) ;
      currentCartItems = <Item> [] ;
      if (users != null ) {
        print(users.cart) ;
        if (users.cart != null ) {
          if (users.cart.items != null ) {
            currentCartItems = users.cart.items ;
          }
        }
      }
      print('#1');
      // Loading all the categories field
      items = await loadItemsByVendorShop(vendorId: widget.vendor.vendorId , shopId:  widget.shop.shopId ) ;
      currentItems = items   ;
      print('#2') ;
      // Checking if items are present in cart alreday or not
      print(currentCartItems) ;
      for (int i = 0 ; i <currentCartItems.length ; i++ ) {
        if (currentCartItems.elementAt(i).count != null && currentCartItems.elementAt(i).discountPrice != null ){
          itemCount += currentCartItems.elementAt(i).count ;
          amount += currentCartItems.elementAt(i).count * currentCartItems.elementAt(i).discountPrice ;
        }
      }
      print('#3') ;
      // Checking the index of
      currentItemsInCart = <bool> [] ;
      currentItemsInCartCount = <int> [] ;
      for (int i = 0 ; i< currentItems.length ; i++ ) {
        var idx = currentCartItems.indexWhere((element) => element.itemId == currentItems.elementAt(i).itemId) ;
        print(idx) ;
        if (idx != -1 ) {
          currentItemsInCart.add(true) ;
          currentItemsInCartCount.add(currentCartItems.elementAt(idx).count) ;
        }
        else{
          currentItemsInCart.add(false) ;
          currentItemsInCartCount.add(0) ;
        }
      }
      print('#4') ;
      searchItems = <String> [] ;
      // Loading all the vendor names
      for (int i = 0 ; i < items.length ; i++) {
        searchItems.add(items.elementAt(i).productName) ;
      }
      print('#5') ;
      //
      print('###########') ;
      print('Search Item List : ' + searchItems.toString() ) ;
      print('Current Items List : ' + currentItems.toString()) ;
      print('Current Cart Items List : ' + currentCartItems.toString()) ;
      print('Is Current item in Cart :  ' + currentItemsInCart.toString()) ;
      print('Current Item Cart Count : ' + currentItemsInCartCount.toString());
      initData = false;
    }
  }

  searchResult() {
    print(searchBar.text) ;
    List<Item> newCurrentItems = <Item> [] ;
    List<Item> newCurrentCartItems = <Item> [] ;
    List<bool> newCurrentItemInCart = <bool> [] ;
    List<int> newCurrentItemsInCartCount = <int> [] ;
    // Current Items
    for (int i = 0 ; i< items.length ; i++ ) {
      if (items.elementAt(i).productName.startsWith(searchBar.text)) {
        newCurrentItems.add(items.elementAt(i)) ;
      }
    }
    // Current Cart Items
    if (users != null ) {
      print(users.cart) ;
      if (users.cart != null ) {
        if (users.cart.items != null ) {
          newCurrentCartItems = users.cart.items ;
        }
      }
    }
    // Current Item in Cart
    // Checking the index of
    for (int i = 0 ; i< newCurrentItems.length ; i++ ) {
      var idx = newCurrentCartItems.indexWhere((element) => element.itemId == newCurrentItems.elementAt(i).itemId) ;
      if (idx != -1 ) {
        newCurrentItemInCart.add(true) ;
        newCurrentItemsInCartCount.add(currentCartItems.elementAt(idx).count) ;
      }
      else{
        newCurrentItemInCart.add(false) ;
        newCurrentItemsInCartCount.add(0) ;
      }
    }

    setState(() {
      currentItems = newCurrentItems ;
      currentCartItems = newCurrentCartItems ;
      currentItemsInCart = newCurrentItemInCart ;
      currentItemsInCartCount = newCurrentItemsInCartCount ;
      print('Current Items List : ' + currentItems.toString()) ;
      print('Current Cart Items List : ' + currentCartItems.toString()) ;
      print('Is Current item in Cart :  ' + currentItemsInCart.toString()) ;
      print('Current Item Cart Count : ' + currentItemsInCartCount.toString());
    });
  }

  addItemInCart(Item item) async {
    List<Item> newCurrentItems = currentItems ;
    List<Item> newCurrentCartItems = <Item> [] ;
    List<bool> newCurrentItemInCart = <bool> [] ;
    List<int> newCurrentItemsInCartCount = <int> [] ;
    int newItemCount = 0 ;
    double newAmount = 0 ;
    Users currentUser = await updateCart(users , item , context) ;
    // Current Cart Items
    if (currentUser != null ) {
      print(currentUser.cart) ;
      if (currentUser.cart != null ) {
        if (currentUser.cart.items != null ) {
          newCurrentCartItems = users.cart.items ;
          for (int i = 0 ; i <newCurrentCartItems.length ; i++ ) {
            print(newCurrentCartItems.elementAt(i).toJson()) ;
            if (newCurrentCartItems.elementAt(i).count != null && newCurrentCartItems.elementAt(i).discountPrice != null ) {
              newItemCount += newCurrentCartItems.elementAt(i).count ;
              newAmount += newCurrentCartItems.elementAt(i).count * newCurrentCartItems.elementAt(i).discountPrice ;
            }
          }
        }
      }
    }
    // Current Item in Cart
    // Checking the index of
    for (int i = 0 ; i< newCurrentItems.length ; i++ ) {
      var idx = newCurrentCartItems.indexWhere((element) => element.itemId == newCurrentItems.elementAt(i).itemId) ;
      if (idx != -1 ) {
        newCurrentItemInCart.add(true) ;
        newCurrentItemsInCartCount.add(newCurrentCartItems.elementAt(idx).count) ;
      }
      else{
        newCurrentItemInCart.add(false) ;
        newCurrentItemsInCartCount.add(0) ;
      }
    }

    setState(() {
      users = currentUser ;
      currentCartItems = newCurrentCartItems ;
      currentItemsInCart = newCurrentItemInCart ;
      currentItemsInCartCount = newCurrentItemsInCartCount ;
      itemCount = newItemCount ;
      amount = newAmount ;
    });

  }

  removeItemCart(Item item) async {
    List<Item> newCurrentItems = <Item> [] ;
    List<Item> newCurrentCartItems = <Item> [] ;
    List<bool> newCurrentItemInCart = <bool> [] ;
    List<int> newCurrentItemsInCartCount = <int> [] ;
    int newItemCount = 0 ;
    double newAmount = 0 ;
    Users currentUser = await removeItemFromCart(users , item ) ;
    // Current Cart Items
    if (currentUser != null ) {
      print(currentUser.cart) ;
      if (currentUser.cart != null ) {
        if (currentUser.cart.items != null ) {
          newCurrentCartItems = users.cart.items ;
          for (int i = 0 ; i <newCurrentCartItems.length ; i++ ) {
            print(newCurrentCartItems.elementAt(i).count) ;
            if (newCurrentCartItems.elementAt(i).count != null && newCurrentCartItems.elementAt(i).discountPrice != null ) {
              newItemCount += newCurrentCartItems.elementAt(i).count ;
              newAmount += newCurrentCartItems.elementAt(i).count * newCurrentCartItems.elementAt(i).discountPrice ;
            }
          }
        }
      }
    }

    // Loading all the categories field
    items = await loadItemsByVendorShop(vendorId: widget.vendor.vendorId , shopId:  widget.shop.shopId ) ;
    newCurrentItems = items   ;

    // Current Item in Cart
    // Checking the index of
    for (int i = 0 ; i< newCurrentItems.length ; i++ ) {
      var idx = newCurrentCartItems.indexWhere((element) => element.itemId == newCurrentItems.elementAt(i).itemId) ;
      if (idx != -1 ) {
        newCurrentItemInCart.add(true) ;
        newCurrentItemsInCartCount.add(currentCartItems.elementAt(idx).count) ;
      }
      else{
        newCurrentItemInCart.add(false) ;
        newCurrentItemsInCartCount.add(0) ;
      }
    }

    setState(() {
      users = currentUser ;
      currentCartItems = newCurrentCartItems ;
      currentItemsInCart = newCurrentItemInCart ;
      currentItemsInCartCount = newCurrentItemsInCartCount ;
      itemCount = newItemCount ;
      amount = newAmount ;
    });
  }

  FutureOr refresh(dynamic value) async {
    setState(() {
      initData = true ;
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
        future:  loadInitData() ,
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                appBar: AppBar(
                  title: Text(
                    widget.shop.shopName,
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                body: Stack(
                  children: [
                    ListView(
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
                                    hintText: 'Search Product',
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              flex : 2 ,
                                              child : Row(
                                                children : [
                                                  currentItems.elementAt(index).image == null
                                                      ? CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                                                    child: CircleAvatar(
                                                      radius: 28.0,
                                                      backgroundColor: Colors.white,
                                                      backgroundImage: AssetImage(
                                                          'assets/images/person_profile_photo.jpg'),
                                                    ),
                                                  )
                                                      : CircleAvatar(
                                                    radius: 30.0,
                                                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                                                    child: CircleAvatar(
                                                      radius: 28.0,
                                                      backgroundColor: Colors.white,
                                                      backgroundImage:NetworkImage(currentItems.elementAt(index).image),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          currentItems.elementAt(index).productName,
                                                          style: GoogleFonts.lato(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.fade,
                                                        ),
                                                        Text(
                                                          currentItems.elementAt(index).productDescription,
                                                          style: GoogleFonts.lato(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.fade,
                                                        ),
                                                        Text(
                                                            'Unit : ' + currentItems.elementAt(index).quantity.toString() + ' ' + currentItems.elementAt(index).quantityType ,
                                                          style: GoogleFonts.lato(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.fade,
                                                        ),
                                                        Text(
                                                            'MRP: ' + currentItems.elementAt(index).originalPrice.toString(),
                                                          style: GoogleFonts.lato(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                            decoration: TextDecoration.lineThrough,
                                                          ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.fade,
                                                        ),
                                                        Text(
                                                            'Best Price: ' + currentItems.elementAt(index).discountPrice.toString(),
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

                                                      ],
                                                    ),
                                                  ),
                                                ] ,
                                              )
                                            ) ,
                                            Expanded(
                                              flex : 1 ,
                                              child : Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  currentItemsInCart.elementAt(index) == false ? IconButton(
                                                      icon: Icon(
                                                        Icons.add_box,
                                                      ),
                                                      iconSize: 26,
                                                      color: Colors.black,
                                                      onPressed : () {
                                                        addItemInCart(currentItems.elementAt(index)) ;
                                                      }
                                                  ) : Row(
                                                    children: [
                                                      IconButton(
                                                          icon: Icon(
                                                            Icons.indeterminate_check_box,
                                                          ),
                                                          iconSize: 26,
                                                          color: Colors.black,
                                                          onPressed : () {
                                                            removeItemCart(currentItems.elementAt(index)) ;
                                                          }
                                                      ) ,
                                                      Text(
                                                        currentItemsInCartCount.elementAt(index).toString() ,
                                                        style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.bold ,
                                                          color : Colors.black ,
                                                        ),
                                                      ),
                                                      IconButton(
                                                          icon: Icon(
                                                            Icons.add_box,
                                                          ),
                                                          iconSize: 26,
                                                          color: Colors.black,
                                                          onPressed : () {
                                                            addItemInCart(currentItems.elementAt(index)) ;
                                                          }
                                                      ) ,


                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),

                                          ],
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                        SizedBox(
                          height: 150,
                        ),
                      ],
                    ),
                    Align(
                      alignment:  Alignment.bottomCenter ,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin : EdgeInsets.fromLTRB(5,5,5,5),
                            child: Card(
                              color : Theme.of(context).secondaryHeaderColor ,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10,15,10,15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Cart : ' +  itemCount.toString() ,
                                          style: GoogleFonts.lato(
                                              fontSize : 14 ,
                                              fontWeight: FontWeight.bold ,
                                              color: Colors.white
                                          ),),
                                        Text('Amount : ' + amount.toString() , style: GoogleFonts.lato(
                                            fontSize : 14 ,
                                            fontWeight: FontWeight.bold ,
                                            color: Colors.white
                                        ),),
                                      ],
                                    ),
                                    RaisedButton(
                                      color: Colors.white,
                                      child: Text(
                                        'View Cart' ,
                                        style: GoogleFonts.lato(
                                          fontSize: 16 ,
                                          fontWeight: FontWeight.bold ,
                                          color : Theme.of(context).primaryColor ,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage())).then(refresh);
                                      },
                                    ),
                                  ],

                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
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

