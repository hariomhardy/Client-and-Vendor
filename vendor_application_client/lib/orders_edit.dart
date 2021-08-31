import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:vendor_application_client/utilites.dart';
import 'database_models/order.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'database_functions/user_functions.dart' ;
import 'database_models/shop.dart';
import 'database_models/item.dart';
import 'database_models/user_address.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_functions/order_functions.dart';
import 'package:cool_alert/cool_alert.dart';
import 'database_functions/user_functions.dart';

class OrderEditPage extends StatefulWidget {
  final Order order ;
  OrderEditPage({Key key , this.order}) : super(key : key) ;
  @override
  _OrderEditPageState createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
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
  bool initData = true;
  Order order ;
  Shop shop ;
  List<Item> items = [] ;
  UserAddress userAddress ;
  bool homeDeliveryToUser ;
  String orderId ;
  String orderStatus ;
  double totalAmount = 0 ;
  double deliveryCharges = 0 ;
  double totalPayAmount = 0 ;
  String slotDate ;
  String timeStart ;
  String timeEnd ;
  String paymentType ;
  List<UserAddress> userAddresses = <UserAddress> [] ;

  loadInitData() async{
    if (initData) {
      order = widget.order ;
      shop = await getShop(vendorId: order.vendorId , shopId: order.shopId) ;
      items = order.items ;
      userAddress = order.address ;
      deliveryCharges = order.deliveryCharges ;
      totalAmount = order.paymentTotal ;
      totalPayAmount = order.paymentPayable ;
      homeDeliveryToUser = order.homeDeliveryToUser ;
      orderId = order.orderId ;
      orderStatus = order.orderStatus ;
      slotDate = order.slotDate ;
      timeStart = order.slotStartTime ;
      timeEnd = order.slotEndTime ;
      paymentType = order.paymentType ;
      initData = false ;
    }
  }

  placeOrder() async {
      bool val1 = await changeOrderAddress(order , userAddress );
      bool val = await changeOrderTime(order , slotDate , timeStart , timeEnd ) ;
      if (val1) {
        // Clear the cart
        CoolAlert.show(
            context: context ,
            type: CoolAlertType.success ,
            text : "Order Date & Address Updated Successfully !",
          onConfirmBtnTap: () {
              Navigator.pop(context) ;
              Navigator.pop(context) ;
          }
        ) ;
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
                title: Text('Edit Order'),
              ),
              body: ListView(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Id : ' , style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold ,
                            fontSize: 16
                        ),) ,
                        Text(orderId , style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold ,
                            fontSize: 14
                        ),) ,
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Status : ' , style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold ,
                            fontSize: 16
                        ),) ,
                        Text(orderStatus , style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold ,
                            fontSize: 14
                        ),) ,
                      ],
                    ),
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
                                      userAddress = val ;
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
                              Text(userAddress.name , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Phone : ' + userAddress.mobile , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('House/Street/Area - ' + userAddress.streetArea , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Landmark - ' + userAddress.landmark , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Address Type - ' + userAddress.addressType , style: GoogleFonts.lato(
                                fontSize: 14 ,
                                fontWeight: FontWeight.bold ,
                                color: Colors.black,
                              ),),
                              Text('Description - ' + userAddress.description, style: GoogleFonts.lato(
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
                            paymentType == 'Cash on Delivery' ? Column(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined ,
                                  size: 32,
                                  color: Colors.black,
                                ) ,
                                Text('Cash on Delivery' , style: GoogleFonts.lato(
                                  fontSize: 12 ,
                                  fontWeight: FontWeight.bold ,
                                  color: Colors.black ,
                                ),),
                              ],
                            ) : Column(
                              children: [
                                Icon(
                                  Icons.credit_card_outlined ,
                                  size: 32,
                                  color: Colors.black,
                                ) ,
                                Text('Other Payment Options' , style: GoogleFonts.lato(
                                  fontSize: 12 ,
                                  fontWeight: FontWeight.bold ,
                                  color: Colors.black ,
                                ),),
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
                      onPressed: () async {
                        await placeOrder() ;
                      },
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Text('SAVE CHANGES' , style: GoogleFonts.lato(
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

