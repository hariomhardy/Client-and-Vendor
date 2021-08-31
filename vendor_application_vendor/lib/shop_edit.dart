import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_application_vendor/database_functions/vendor_functions.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'package:vendor_application_vendor/utilities_functions/input_utilities.dart';
import 'package:vendor_application_vendor/utilities_functions/widgit_utilities.dart';
import 'app_theme.dart';
import 'database_models/address.dart';
import 'database_models/geolocation.dart';
import 'database_models/shop.dart';
import 'database_models/vendor.dart';
import 'shop.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopEditPage extends StatefulWidget {
  final Vendor vendor ;
  final Shop shop ;
  ShopEditPage({Key key, this.vendor ,  this.shop}) : super(key: key);

  @override
  _ShopEditPageState createState() => _ShopEditPageState();
}

class _ShopEditPageState extends State<ShopEditPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  TextEditingController name = new TextEditingController();
  TextEditingController mobile = new TextEditingController();
  TextEditingController shopNumber = new TextEditingController();
  TextEditingController landMark = new TextEditingController();
  TextEditingController description = new TextEditingController();
  TextEditingController minimumAmountPurchase = new TextEditingController();
  bool deliveryAvailable = true;
  File image;
  String openTime = 'Select Time';
  String closeTime = 'Select Time';
  String imageUrl ;
  Shop oldShop ;
  bool initData = true ;

  Future getImage({bool isCamera}) async {
    var imagePicker;
    if (isCamera == true) {
      imagePicker = await ImagePicker().getImage(source: ImageSource.camera , imageQuality: 30);
    } else {
      imagePicker = await ImagePicker().getImage(source: ImageSource.gallery , imageQuality: 30);
    }
    setState(() {
      image = File(imagePicker.path);
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      /// both default to 16
      marginEnd: 18,
      marginBottom: 20,
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.remove,
      buttonSize: 56.0,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => null,
      onClose: () => null,
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Theme.of(context).secondaryHeaderColor,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.camera,
            color: Colors.white,
          ),
          backgroundColor: Colors.purple,
          label: 'Camera',
          labelStyle: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
          onTap: () => getImage(isCamera: true),
          onLongPress: () => getImage(isCamera: true),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.image,
            color: Colors.white,
          ),
          backgroundColor: Colors.purple,
          label: 'Gallery',
          labelStyle: TextStyle(
              fontSize: 18.0,
              color: Colors.black,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold),
          onTap: () => getImage(isCamera: false),
          onLongPress: () => getImage(isCamera: false),
        ),
      ],
    );
  }

  Widget alertDialog(BuildContext context, String title , String content) {
    return AlertDialog(
      title: Text(title , style: GoogleFonts.lato(
        fontWeight : FontWeight.bold ,
        fontSize : 16 ,
        fontStyle : FontStyle.normal ,
      ),),
      content: Text(content , style: GoogleFonts.lato(
        fontWeight: FontWeight.bold ,
        fontSize : 16 ,
        fontStyle : FontStyle.normal ,
      ),),
      actions: [
        FlatButton(
          child: Text('OK' , style: GoogleFonts.lato(
            fontWeight: FontWeight.bold ,
            fontSize: 14 ,
            fontStyle: FontStyle.normal ,
            color: Theme.of(context).primaryColor ,
          ),),
          onPressed: () {
            Navigator.pop(context) ;
          },
        )
      ],
    );
  }

  Future<void> saveChanges() async {
    print('Shop Name : ' + name.text);
    print('Mobile Number : ' + mobile.text);
    print('Shop Number : ' + shopNumber.text);
    print('Landmark : ' + landMark.text);
    print('Description : ' + description.text);
    print('Minimum Amount : ' + minimumAmountPurchase.text);
    print('Opening Time : ' + openTime);
    print('Close Time : ' + closeTime);
    print('Delivery Available : ' + deliveryAvailable.toString());
    print('Image File Path : ' + image.toString());

    bool val = await validation() ;
    if (val) {
      // ALl Values
      String shopNameValue = capitalize(name.text.trim()) ;
      String mobileValue = mobile.text.trim() ;
      String shopNumberValue = capitalize(shopNumber.text.trim()) ;
      String landmarkValue = capitalize(landMark.text.trim()) ;
      String descriptionValue = description.text.trim() ;
      String miniAmtValue = minimumAmountPurchase.text.trim() ;
      String openTimeValue = openTime ;
      String closeTimeValue = closeTime ;
      // Database Update
      // TODO : Task Geo - location functinoality remaining
      Geolocation geolocation = new Geolocation('0', '0');
      Address address = new Address(shopNumberValue,
          landmarkValue,descriptionValue , geolocation);
      Shop newShop = new Shop.withVendor(
        vendorId : FirebaseAuth.instance.currentUser.uid,
        shopName : shopNameValue,
        shopMobile: mobileValue ,
        shopNumber: shopNumberValue ,
        minAmount: double.parse(miniAmtValue) ,
        deliveryOptions: deliveryAvailable ,
        address: address ,
        openTime: openTimeValue ,
        closeTime: closeTimeValue ,
      );
      dynamic shopId = await updateShop(vendor: widget.vendor , oldShop: oldShop , newShop:  newShop ) ;
      newShop.shopId = shopId ;
      if (shopId != null && image != null ) {
        await updateImageShop(
            vendor: widget.vendor, shopId : shopId, image: image);
      }
      if (shopId != null ) {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            text: "Shop updated Successfully !",
            onConfirmBtnTap: () {
              Navigator.pop(context) ;
              Navigator.pop(context) ;
            }
        );
      }
      else {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: 'Shop is not updated ! Please Try Again'
        );
      }
    }
  }

  Future<bool> validation() async {
    // Image Field cant be null
    /*
    if (image == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog(context, 'Image', 'Please Select Image');
          }
      );
      return;
    }
     */

    // Shop name can't be null
    if (name.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Shop-name Input Field',
        content: 'Please enter a valid shop name \n It can\'t be left null',
      );
      return false;
    }

    // Mobile Field can't be null
    if (mobile.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Mobile Input Field',
        content: 'Please enter a valid mobile number\n It can\'t be left null',
      );
      return false;
    }
    // Valid mobile field
    if (mobile.text.trim().length != 0 && !validMobile(mobile.text.trim())) {
      await warningDialog(
        context: context,
        title: 'Mobile Input Field',
        content:
        'Please enter a valid mobile number\n Your mobile number is not matched with the general expression',
      );
      return false;
    }

    // Shop number & address can't be null
    if (shopNumber.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Shop-Number/Address Input Field',
        content: 'Please enter a valid shop number/area \n It can\'t be left null',
      );
      return false;
    }
    // Open Time
    if (openTime.trim() == 'Select Time') {
      await warningDialog(
        context: context,
        title: 'Please Select Opening Time for Shop',
        content: 'Please click to select a valid open time for shop number/area \n It can\'t be left null',
      );
      return false;
    }

    // Close Time
    if (closeTime.trim() == 'Select Time') {
      await warningDialog(
        context: context,
        title: 'Please Select Closing Time for Shop',
        content: 'Please click to select a valid close time for shop number/area \n It can\'t be left null',
      );
      return false;
    }

    // Minimum amount purchase
    try {
      double.parse(minimumAmountPurchase.text) ;
    }
    on Exception catch ( exception )  {
      await warningDialog(
        context: context,
        title: 'Minimum Amount Purchase Field',
        content: 'Please click to select a valdi amount \n It can\'t be left null \n Value should be in decimal format',
      );
      return false;
    }

    return true ;
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
    if (initData) {
      name.text = widget.shop.shopName ;
      mobile.text=  widget.shop.shopMobile ;
      shopNumber.text = widget.shop.shopNumber ;
      landMark.text = widget.shop.address.landmark ;
      description.text = widget.shop.address.description ;
      minimumAmountPurchase.text = widget.shop.minAmount.toString() ;
      if (widget.shop.openTime != null) {
        openTime = widget.shop.openTime ;
      }
      if (widget.shop.closeTime != null) {
        closeTime = widget.shop.closeTime ;
      }
      deliveryAvailable = widget.shop.deliveryOptions ;
      imageUrl = widget.shop.image ;
      oldShop = widget.shop ;
      initData = false ;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Shop'),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView(
          children: [
            SizedBox(
              height: 10,
            ),
            image == null
                ? imageUrl == null ? CircleAvatar(
              radius: 60.0,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              child: CircleAvatar(
                radius: 58.0,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage(
                    'assets/images/person_profile_photo.jpg'),
              ),
            ) : CircleAvatar(
              radius: 50.0,
              backgroundColor: Theme.of(context).secondaryHeaderColor,
              child: CircleAvatar(
                radius: 48.0,
                backgroundColor: Colors.white,
                backgroundImage:NetworkImage(imageUrl),
              ),
            )
                : Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill, image: FileImage(image)),
                    border: Border.all(color: Colors.black, width: 2))),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Shop Name',
                  hintText: 'Enter Shop Name',
                ),
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                controller: name,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(2, 0, 30, 0),
              child: TextField(
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Phone Number' , labelText: 'Phone Number'),
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                controller: mobile,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Shop No./Street/Area',
                  hintText: 'Shop No./Street/Area',
                ),
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                controller: shopNumber,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Landmark',
                  hintText: 'Landmark',
                ),
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                controller: landMark,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Description',
                  hintText: 'Description',
                ),
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                controller: description,
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Minimum Amount : ',
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: 'Minimum Amt.',
                    ),
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    controller: minimumAmountPurchase,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Opening Time : ',
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    shape: StadiumBorder(),
                    onPressed: () async {
                      await DatePicker.showTimePicker(context,
                          showTitleActions: true,
                          currentTime: DateTime.now(), onChanged: (dateTime) {
                            print('Change $dateTime');
                          }, onConfirm: (dateTime) {
                            print('Confirm $dateTime');
                            if (dateTime.hour < 10) {
                              openTime = '0' +  dateTime.hour.toString() + ':' ;
                            }
                            else {
                              openTime = dateTime.hour.toString() + ':' ;
                            }
                            if (dateTime.minute < 10) {
                              openTime = openTime + '0' + dateTime.minute.toString() ;
                            }
                            else {
                              openTime = openTime +  dateTime.minute.toString() ;
                            }
                          }, locale: LocaleType.en);
                      setState(() {
                        this.openTime = openTime;
                      });
                    },
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Text(
                          openTime,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Closing Time : ',
                    style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    shape: StadiumBorder(),
                    onPressed: () async {
                      await DatePicker.showTimePicker(context,
                          showTitleActions: true,
                          currentTime: DateTime.now(), onChanged: (dateTime) {
                            print('Change $dateTime');
                          }, onConfirm: (dateTime) {
                            print('Confirm $dateTime');
                            if (dateTime.hour < 10) {
                              closeTime = '0' +  dateTime.hour.toString() + ':' ;
                            }
                            else {
                              closeTime = dateTime.hour.toString() + ':' ;
                            }
                            if (dateTime.minute < 10) {
                              closeTime = closeTime + '0' + dateTime.minute.toString() ;
                            }
                            else {
                              closeTime = closeTime +  dateTime.minute.toString() ;
                            }
                          }, locale: LocaleType.en);
                      setState(() {
                        this.closeTime = closeTime;
                      });
                    },
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Text(
                          closeTime,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  checkColor: Colors.white,
                  value: deliveryAvailable,
                  onChanged: (bool value) {
                    setState(() {
                      deliveryAvailable = value;
                    });
                  },
                ),
                Text(
                  'Delivery Available',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: FlatButton(
                onPressed: () {
                  saveChanges();
                },
                color: Theme.of(context).secondaryHeaderColor,
                child: Text(
                  'UPDATE SHOP',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: buildSpeedDial(),
    );
  }
}
