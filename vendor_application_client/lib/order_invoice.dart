import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/promo_code.dart';
import 'package:vendor_application_client/database_functions/user_functions.dart';
import 'package:vendor_application_client/utilites.dart';
import 'database_models/item.dart';
import 'database_models/shop.dart';
import 'database_models/user.dart';
import 'database_models/user_address.dart';
import 'database_models/cart.dart' ;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import 'database_functions/order_functions.dart' ;
import 'database_functions/user_functions.dart' ;
import 'package:cool_alert/cool_alert.dart' ;
import 'main.dart' ;

class OrderInvoice extends StatefulWidget {
  final Cart cart ;
  final double deliveryCharges ;
  final bool homeDeliveryToUser ;
  OrderInvoice({Key  key , this.cart , this.deliveryCharges ,this.homeDeliveryToUser }) : super(key : key) ;
  @override
  _OrderInvoiceState createState() => _OrderInvoiceState();
}

class _OrderInvoiceState extends State<OrderInvoice> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  bool initData = true;
  String promoCode = 'No Promo Code Applied' ;
  double totalAmount = 0 ;
  double deliveryCharges = 0 ;
  double totalPayAmount = 0 ;
  String slotDate ;
  String timeStart ;
  String timeEnd ;
  Shop shop;
  Users users;
  List<Item> items = <Item>[];
  UserAddress userCurrentAddress ;
  List<UserAddress> userAddresses = <UserAddress> [] ;
  bool otherPaymentOption = false ;
  bool codOption = true ;
  String paymentType ;

  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(
                indicatorType: Indicator.ballRotateChase,
                color: Theme
                    .of(context)
                    .primaryColor)));
  }

  loadInitData() async{
    if (initData) {
      List<UserAddress> addresses;
      users = await getUserProfile(uid: FirebaseAuth.instance.currentUser.uid);
      if (users != null) {
        if (users.cart != null) {
          if (users.cart.items != null) {
            shop = await loadShop(users.cart.vendorId,users.cart.shopId);
            items = users.cart.items;
            addresses = await getUserAddresses(uid:users.userId);
            userCurrentAddress = addresses[0];
            totalAmount = users.cart.discountPrice ;
            deliveryCharges = widget.deliveryCharges ;
            totalPayAmount = totalAmount + deliveryCharges ;
          }
        }
      }
      DateTime now = new DateTime.now() ;
      slotDate = now.day.toString() + '/' + now.month.toString() + '/' + now.year.toString() ;
      timeStart = '8:00' ;
      timeEnd = '20:00' ;
      initData = false ;
    }
  }

  placeOrder() async{
    // Get User
    Users user = await getUserProfile(uid: FirebaseAuth.instance.currentUser.uid) ;
    Cart cart = user.cart ;
    double deliveryCharges = widget.deliveryCharges ;
    if (codOption == true ) {
      paymentType = 'Cash on Delivery' ;
    }
    else {
      // TODO : part if integrate
      paymentType = 'Online Payment Gateway' ;
    }

    print('User : ' + user.toJson().toString()) ;
    print('Cart : ' + cart.toJson().toString()) ;
    print('Delivery Charges : ' + deliveryCharges.toString()) ;
    print('Payment Type : ' + paymentType) ;
    print('Slot Start Time : ' +  timeStart) ;
    print('Slot End Time : ' + timeEnd) ;
    print('Slot Date : ' + slotDate ) ;
    print('User Address' + userCurrentAddress.toJson().toString()) ;

    // Create Order
    bool isOrderCreated = await createOrder(
      user: user , cart : cart , deliveryCharges: deliveryCharges ,
      paymentType: paymentType , slotStartTime: timeStart , slotEndTime: timeEnd ,
      slotDate: slotDate , userAddress: userCurrentAddress ,
      homeDeliveryToUser: widget.homeDeliveryToUser
    );

    if (isOrderCreated) {
      // Clear the cart
      await clearCart(user : user ) ;
      CoolAlert.show(
        context: context ,
        type: CoolAlertType.success ,
        text : "Order Created Successfully !",
        onConfirmBtnTap: () {
          Navigator.pop(context) ;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => Home()),
                  (Route<dynamic> route) => false
          );
        }
      );
    }
    else {
      CoolAlert.show(
          context : context ,
          type: CoolAlertType.error ,
          text : 'Order is not created ! Please Try Again'
      );
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
                title: Text('Order Summary'),
              ),
              body: ListView(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 5, 5, 5),
                    child: Text(
                      'Shop',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 5,
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          shop.image == null
                              ? CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Theme
                                .of(context)
                                .secondaryHeaderColor,
                            child: CircleAvatar(
                              radius: 28.0,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(
                                  'assets/images/person_profile_photo.jpg'),
                            ),
                          )
                              : CircleAvatar(
                            radius: 30.0,
                            backgroundColor: Theme
                                .of(context)
                                .secondaryHeaderColor,
                            child: CircleAvatar(
                              radius: 28.0,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                  shop.image),
                            ),
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shop.shopName,
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.fade,
                                ),
                                Text(
                                  'Address : ',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.fade,
                                ),
                                Text(
                                  'Shop/Street/Area : ' +  shop.address.streetArea,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.fade,
                                ),
                                Text(
                                  'Description : ' + shop.address.description,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.fade,
                                ),
                                Text(
                                  'Landmark : ' + shop.address.landmark,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.fade,
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 5, 5, 5),
                    child: Text(
                      'Products',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      items
                                          .elementAt(index)
                                          .image == null
                                          ? CircleAvatar(
                                        radius: 30.0,
                                        backgroundColor: Theme
                                            .of(context)
                                            .secondaryHeaderColor,
                                        child: CircleAvatar(
                                          radius: 28.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage: AssetImage(
                                              'assets/images/person_profile_photo.jpg'),
                                        ),
                                      )
                                          : CircleAvatar(
                                        radius: 30.0,
                                        backgroundColor: Theme
                                            .of(context)
                                            .secondaryHeaderColor,
                                        child: CircleAvatar(
                                          radius: 28.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                              items
                                                  .elementAt(index)
                                                  .image),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              items.elementAt(index).productName,
                                              style: GoogleFonts.lato(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                              maxLines: 5,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              items.elementAt(index).productDescription,
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              'Unit : ' + items.elementAt(index).count.toString(),
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              'MRP : ' +  items.elementAt(index).originalPrice.toString(),
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.fade,
                                            ),
                                            Text(
                                              'Best Price : ' + items.elementAt(index).discountPrice.toString(),
                                              style: GoogleFonts.lato(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                              maxLines: 5,
                                              overflow: TextOverflow.fade,
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Total Amt - ' , style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold ,
                                        fontSize: 14 ,
                                        color: Colors.black ,
                                      ),),
                                      Text((items.elementAt(index).discountPrice * items.elementAt(index).count).toString() , style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold ,
                                        fontSize: 14 ,
                                        color: Colors.black ,
                                      ),),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  // TODO : Apply Promo Code Discussion
                  /*
                  Card(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 5,
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Apply Promo Code',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),

                              Text(
                                promoCode,
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          IconButton(icon: Icon(
                            Icons.edit_outlined ,
                            color: Colors.black,
                            size: 18,
                          ), onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) => PromoCodePage()),);
                          }),
                        ],
                      ),
                    ),
                  ),

                   */
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 5,
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment' , style: GoogleFonts.lato(
                            fontSize: 16 ,
                            fontWeight: FontWeight.bold ,
                            color: Colors.black,
                          ),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Toatl Amount' , style: GoogleFonts.lato(
                                fontSize: 12 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text(totalAmount.toString() , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Charges' , style: GoogleFonts.lato(
                                fontSize: 12 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text(deliveryCharges.toString() , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 2,
                            width: double.infinity,
                            color: Colors.black,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Grand Total' , style: GoogleFonts.lato(
                                fontSize: 12 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text(totalPayAmount.toString() , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 5,
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Slot' , style: GoogleFonts.lato(
                                fontSize: 18 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              /*
                              IconButton(icon: Icon(
                                Icons.edit_outlined ,
                                color: Colors.black,
                                size: 18,
                              ), onPressed: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => Slot()),);
                              }),
                               */
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Date',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              FlatButton(
                                shape: StadiumBorder(),
                                onPressed: () async {
                                  await DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(2020, 1, 1), onChanged: (date) {
                                        print('Change $date');
                                      }, onConfirm: (date) {
                                        print('Confirm $date');
                                        slotDate = date.day.toString() + '/' + date.month.toString() + '/' + date.year.toString() ;
                                      }, currentTime: DateTime.now(), locale: LocaleType.en);
                                  setState(() {
                                    slotDate = slotDate ;
                                  });
                                },
                                child: Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    child: Text(
                                      slotDate,
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Slot Time Interval - Start',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              FlatButton(
                                shape: StadiumBorder(),
                                onPressed: () async {
                                  await DatePicker.showTimePicker(context,
                                      showTitleActions: true,
                                      currentTime: DateTime.now(), onChanged: (dateTime) {
                                        print('Change $dateTime');
                                      }, onConfirm: (dateTime) {
                                        print('Confirm $dateTime');
                                        timeStart = dateTime.hour.toString() +
                                            ':' +
                                            dateTime.minute.toString();
                                      }, locale: LocaleType.en);
                                  setState(() {
                                    timeStart = timeStart;
                                  });
                                },
                                child: Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    child: Text(
                                      timeStart,
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Slot Time Interval - End',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              FlatButton(
                                shape: StadiumBorder(),
                                onPressed: () async {
                                  await DatePicker.showTimePicker(context,
                                      showTitleActions: true,
                                      currentTime: DateTime.now(), onChanged: (dateTime) {
                                        print('Change $dateTime');
                                      }, onConfirm: (dateTime) {
                                        print('Confirm $dateTime');
                                        timeEnd = dateTime.hour.toString() +
                                            ':' +
                                            dateTime.minute.toString();
                                      }, locale: LocaleType.en);
                                  setState(() {
                                    timeEnd = timeEnd;
                                    print("######");
                                  });
                                },
                                child: Card(
                                  elevation: 5,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                    child: Text(
                                      timeEnd,
                                      style: GoogleFonts.lato(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),

                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 5,
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Contact Details' , style: GoogleFonts.lato(
                                fontSize: 16 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              IconButton(icon: Icon(
                                Icons.edit_outlined ,
                                color: Colors.black,
                                size: 18,
                              ), onPressed: () async {
                                userAddresses = await getUserAddresses(uid: FirebaseAuth.instance.currentUser.uid) ;
                                print(userAddresses.length) ;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("My Address"),
                                      content: Container(
                                        width: 300,
                                        height: 500,
                                        child: ListView.builder(
                                            itemCount: userAddresses.length ,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            physics: AlwaysScrollableScrollPhysics(),
                                            itemBuilder: (BuildContext context , int index) {
                                              return FlatButton(
                                                onPressed: () {
                                                  print(userAddresses.elementAt(index).toJson()) ;
                                                  Navigator.pop(context, userAddresses.elementAt(index));
                                                },
                                                child: Card(
                                                  elevation: 5,
                                                  child: Padding(
                                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(userAddresses.elementAt(index).addressType , style : GoogleFonts.lato(
                                                              fontWeight: FontWeight.bold ,
                                                              fontSize: 16 ,
                                                              fontStyle: FontStyle.normal ,
                                                              color: Colors.black ,
                                                            )),
                                                          ],
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        ),
                                                        Text(userAddresses.elementAt(index).name , style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.bold ,
                                                          fontSize: 16 ,
                                                          fontStyle: FontStyle.normal ,
                                                          color: Colors.black ,
                                                        ),),
                                                        Text(userAddresses.elementAt(index).mobile , style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.bold ,
                                                          fontSize: 16 ,
                                                          fontStyle: FontStyle.normal ,
                                                          color: Colors.black ,
                                                        ),),
                                                        Text(userAddresses.elementAt(index).streetArea , style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.bold ,
                                                          fontSize: 14 ,
                                                          fontStyle: FontStyle.normal ,
                                                          color: Colors.black ,
                                                        ),),
                                                        Text(userAddresses.elementAt(index).landmark , style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.bold ,
                                                          fontSize: 14 ,
                                                          fontStyle: FontStyle.normal ,
                                                          color: Colors.black ,
                                                        ),),
                                                        Text(userAddresses.elementAt(index).description , style: GoogleFonts.lato(
                                                          fontWeight: FontWeight.bold ,
                                                          fontSize: 14 ,
                                                          fontStyle: FontStyle.normal ,
                                                          color: Colors.black ,
                                                        ),),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    );
                                  },
                                ).then((val) {
                                  setState(() {
                                    if (val != null) {
                                      userCurrentAddress = val ;
                                    }
                                  });
                                });
                              }),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userCurrentAddress.name , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Phone : ' + userCurrentAddress.mobile , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('House/Street/Area - ' + userCurrentAddress.streetArea , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Landmark - ' + userCurrentAddress.landmark , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Address Type - ' + userCurrentAddress.addressType , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Description - ' + userCurrentAddress.description, style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),

                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),

                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
                    elevation: 5,
                    color: Colors.white,
                    child: Container(
                        padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: Column(
                          children: [
                            Text('Payment Options' , style: GoogleFonts.lato(
                              color: Colors.black ,
                              fontWeight: FontWeight.bold ,
                              fontSize: 16 ,
                            ),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex : 1 ,
                                  child: FlatButton(
                                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                    color: otherPaymentOption == true  ? Colors.grey : Colors.white ,
                                    onPressed: () {
                                      setState(() {
                                        otherPaymentOption = true ;
                                        codOption = false ;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.credit_card_outlined ,
                                          size: 32,
                                          color: Colors.black,
                                        ) ,
                                        AutoSizeText('Other Payment Options' , style: GoogleFonts.lato(
                                          fontSize: 12 ,
                                          fontWeight: FontWeight.bold ,
                                          color: Colors.black ,
                                        ),),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex : 1 ,
                                  child: FlatButton(
                                    padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                                    color: codOption == true  ? Colors.grey : Colors.white ,
                                    onPressed: () {
                                      setState(() {
                                        otherPaymentOption = false ;
                                        codOption = true ;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined ,
                                          size: 32,
                                          color: Colors.black,
                                        ) ,
                                        AutoSizeText('Cash on Delivery' , style: GoogleFonts.lato(
                                          fontSize: 12 ,
                                          fontWeight: FontWeight.bold ,
                                          color: Colors.black ,
                                        ),),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
                    padding: EdgeInsets.fromLTRB(10,10,10,10),
                    child: FlatButton(
                      onPressed: () {
                        placeOrder() ;
                      },
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Text('CONFIRM' , style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold ,
                        fontSize: 16 ,
                        color: Colors.white,
                      ),),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            );
          } else {
            return progressIndicator();
          }
        });
  }
}

