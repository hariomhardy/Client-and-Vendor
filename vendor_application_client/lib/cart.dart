import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:vendor_application_client/database_functions/user_functions.dart';
import 'package:vendor_application_client/database_models/item.dart';
import 'package:vendor_application_client/utilites.dart';
import 'app_theme.dart';
import 'database_models/shop.dart';
import 'home.dart';
import 'database_models/cart.dart';
import 'database_models/user.dart';
import 'order_invoice.dart' hide Item;
import 'package:cool_alert/cool_alert.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  bool initData = true;
  Users users;
  Cart cart;
  List<Item> currentCartItems = <Item>[];
  List<Item> items = [];
  List<Shop> currentShops = [];
  double deliveryCharges = 50;
  bool homeDeliveryOption = false;
  double subTotal = 0;

  loadInitData() async {
    if (initData) {
      subTotal = 0.0;
      // loading the user profile
      users = await getUserProfile(uid: FirebaseAuth.instance.currentUser.uid);
      items = <Item>[];
      currentShops = <Shop>[];
      if (users != null) {
        if (users.cart != null) {
          if (users.cart.items != null) {
            items = users.cart.items;
            cart = users.cart;
            subTotal = cart.discountPrice;
            deliveryCharges = 50;
            currentShops.add(await loadShop(cart.vendorId, cart.shopId));
            print('===========================================');
            print(currentShops[0].toJson());
          }
        } else {
          deliveryCharges = 0;
        }
      }
    }
  }

  addItemInCart(Item item) async {
    List<Item> newCurrentCartItems = <Item>[];

    Users currentUser = await updateCart(users, item, context);
    // Current Cart Items
    if (currentUser != null) {
      print(currentUser.cart);
      if (currentUser.cart != null) {
        if (currentUser.cart.items != null)
          newCurrentCartItems = users.cart.items;
      }
    }

    setState(() {
      users = currentUser;
      items = newCurrentCartItems;
      cart = users.cart;
      subTotal = cart.discountPrice;
    });
  }

  removeItemCart(Item item) async {
    List<Item> newCurrentCartItems = List.of(currentCartItems);
    Users currentUser = await removeItemFromCart(users, item);
    double subTotalPrice = 0;
    List<Shop> newCurrentShop = [];

    // Current Cart Items
    if (currentUser != null) {
      print(currentUser.cart);
      if (currentUser.cart != null) {
        subTotalPrice = currentUser.cart.discountPrice;
        if (currentUser.cart.items != null) {
          newCurrentCartItems = users.cart.items;
          newCurrentShop.add(currentShops[0]);
        }
      } else {
        subTotalPrice = 0.00;
        newCurrentShop = [];
      }
    }

    setState(() {
      users = currentUser;
      items = newCurrentCartItems;
      cart = users.cart;
      subTotal = subTotalPrice;
      currentShops = newCurrentShop;
    });
  }

  deleteCart() async {
    Users users =
        await getUserProfile(uid: FirebaseAuth.instance.currentUser.uid);
    bool val = await clearCart(user: users);
    if (val == true) {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.success,
          text: "Cart got clear ! Shop with your convience",
          onConfirmBtnTap: () {
            Navigator.pop(context);
            setState(() {
              initData = true;
            });
          });
    } else {
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          text: 'Cart is not cleared ! Please Try Again');
    }
  }

  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                color: Theme.of(context).primaryColor)));
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
                title: Text('Cart'),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_shopping_cart,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      deleteCart();
                    },
                  )
                ],
              ),
              body: Stack(
                children: [
                  ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      currentShops.length != 0
                          ? Container(
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
                                    currentShops.elementAt(0).image == null
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
                                        backgroundImage:NetworkImage(currentShops.elementAt(0).image),
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
                                            currentShops.elementAt(0).shopName,
                                            style: GoogleFonts.lato(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            maxLines: 3,
                                            overflow: TextOverflow.fade,
                                          ),
                                          Text(
                                            currentShops.elementAt(0).shopNumber,
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.fade,
                                          ),
                                          Text(
                                              currentShops.elementAt(0).rating != null?
                                            'Rating : ${currentShops.elementAt(0).rating.overallRating/currentShops.elementAt(0).rating.count}':
                                            'Not Rated Yet',
                                            style: GoogleFonts.lato(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.fade,
                                          ),
                                          Text(
                                            currentShops.elementAt(0).rating != null?
                                            'Rating\'s Count by Users: ${currentShops.elementAt(0).rating.count}':
                                            'Rating\'s Count by Users: 0',
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
                                            children: [
                                              Text('Slot : ') ,
                                              Icon(
                                                Icons.access_time,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(currentShops.elementAt(0).openTime.toString() +
                                                  '-' +
                                                  currentShops.elementAt(0).closeTime.toString()),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text('Delivery : ') ,
                                              Icon(
                                                Icons.bike_scooter,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              currentShops.elementAt(0).deliveryOptions == true ? Text ('Yes') : Text('No')
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
                              ],
                            ),
                          ),
                        ),
                      )
                          : SizedBox(height: 5),
                      ListView.builder(
                          primary: false,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: items.length,
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
                                          Expanded(
                                              flex : 2 ,
                                              child : Row(
                                                children : [
                                                  items.elementAt(index).image == null
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
                                                      backgroundImage:NetworkImage(items.elementAt(index).image),
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
                                                          items.elementAt(index).productName,
                                                          style: GoogleFonts.lato(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.fade,
                                                        ),
                                                        Text(
                                                          items.elementAt(index).productDescription,
                                                          style: GoogleFonts.lato(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.fade,
                                                        ),
                                                        Text(
                                                          'Unit : ' + items.elementAt(index).quantity.toString() + ' ' + items.elementAt(index).quantityType ,
                                                          style: GoogleFonts.lato(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.black,
                                                          ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.fade,
                                                        ),
                                                        Text(
                                                          'MRP: ' + items.elementAt(index).originalPrice.toString(),
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
                                                          'Best Price: ' + items.elementAt(index).discountPrice.toString(),
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
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons
                                                              .indeterminate_check_box,
                                                        ),
                                                        iconSize: 26,
                                                        color: Colors.black,
                                                        onPressed: () {
                                                          removeItemCart(items
                                                              .elementAt(index));
                                                        }),
                                                    Text(
                                                      items
                                                          .elementAt(index)
                                                          .count
                                                          .toString(),
                                                      style: GoogleFonts.lato(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    IconButton(
                                                        icon: Icon(
                                                          Icons.add_box,
                                                        ),
                                                        iconSize: 26,
                                                        color: Colors.black,
                                                        onPressed: () {
                                                          addItemInCart(items
                                                              .elementAt(index));
                                                        }),

                                                  ],
                                                ),
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
                        height: 500,
                      )
                    ],
                  ),
                  Row(children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Card(
                              color: Colors.white,
                              elevation: 5,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sub Total Price',
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          subTotal.toString(),
                                          style: GoogleFonts.lato(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Delivery Charges',
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          deliveryCharges.toString(),
                                          style: GoogleFonts.lato(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      height: 1,
                                      width: double.infinity,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Grand Total',
                                          style: GoogleFonts.lato(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          (subTotal + deliveryCharges)
                                              .toString(),
                                          style: GoogleFonts.lato(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                          checkColor: Colors.white,
                                          value: homeDeliveryOption,
                                          onChanged: (bool value) {
                                            setState(() {
                                              homeDeliveryOption = value;
                                            });
                                          },
                                        ),
                                        Text(
                                          'Home Delivery',
                                          style: GoogleFonts.lato(
                                            fontSize: 12,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Note : If you want to self pick up to the '
                                      'products from store you need to uncheck the above button...',
                                      style: GoogleFonts.lato(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(30, 15, 30, 15),
                            child: FlatButton(
                              color: Theme.of(context).secondaryHeaderColor,
                              child: Container(
                                width: double.infinity,
                                child: Text(
                                  'PROCEED',
                                  style: GoogleFonts.lato(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              onPressed: () async {
                                Users user = await getUserProfile(
                                    uid: FirebaseAuth
                                        .instance.currentUser.uid);
                                print(user.toJson()) ;
                                if (user.name != null  ) {
                                  if (cart != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OrderInvoice(
                                              cart: user.cart,
                                              deliveryCharges: deliveryCharges,
                                              homeDeliveryToUser:
                                              homeDeliveryOption)),
                                    );
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return alertDialog(context, 'No Item',
                                              'in the cart to be purchased');
                                        });
                                  }
                                }
                                else {
                                  CoolAlert.show(
                                      context : context ,
                                      type: CoolAlertType.error ,
                                      text : 'Please update the user profile and address field in accounts section ! Please Try Again' ,
                                    onConfirmBtnTap: () {
                                        Navigator.pop(context) ;
                                    }

                                  );
                                }

                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            );
          } else {
            return progressIndicator();
          }
        });
  }
}
