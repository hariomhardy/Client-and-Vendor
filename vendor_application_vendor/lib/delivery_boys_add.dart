import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:vendor_application_vendor/database_functions/delivery_boy_functions.dart';
import 'package:vendor_application_vendor/delivery_boys.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'package:vendor_application_vendor/utilities_functions/input_utilities.dart';
import 'package:vendor_application_vendor/utilities_functions/widgit_utilities.dart';

import 'database_models/address.dart';
import 'database_models/deliveryBoy.dart';
import 'database_models/vendor.dart';
import 'database_functions/vendor_functions.dart';

class DeliveryBoysAddPage extends StatefulWidget {
  final Vendor vendor ;
  DeliveryBoysAddPage({Key key , this.vendor}) : super(key: key) ;
  @override
  _DeliveryBoysAddPageState createState() => _DeliveryBoysAddPageState();
}

class _DeliveryBoysAddPageState extends State<DeliveryBoysAddPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  TextEditingController name = new TextEditingController();

  TextEditingController email = new TextEditingController();

  TextEditingController mobile = new TextEditingController();

  TextEditingController address = new TextEditingController();

  File image;

  String countryCode = '+91';

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

  Future<void> saveChanges() async {

    print('Name : ' + name.text);
    print('Mobile Number : ' + countryCode + mobile.text);
    print('Email Id : ' + email.text);
    print('Address : ' + address.text);
    print('Image File Path : ' + image.toString());

    bool val = await validation() ;
    if (val) {
      // All the Field Values
      String nameValue = capitalize(name.text.trim()) ;
      String mobileValue = countryCode + mobile.text.trim() ;
      String addressValue = capitalize(address.text.trim()) ;
      String emailValue = email.text.trim() ;
      // Database Update
      Address addressObj = new Address.custom(addressValue) ;
      VendorDeliveryBoy deliveryBoy = new VendorDeliveryBoy.custom(name: nameValue , phoneNumber: mobileValue , address: addressObj , emailId: emailValue) ;
      dynamic deliveryBoyId = await addDeliveryBoy(widget.vendor , deliveryBoy) ;
      deliveryBoy.deliveryBoyId = deliveryBoyId.toString() ;
      if (deliveryBoyId  != null && image != null ) {
        await updateImageDeliveryBoy(vendor: widget.vendor , deliveryBoy: deliveryBoy , image: image ) ;
      }
      if ( deliveryBoyId != null  ) {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            text: "Delivery Boy added Successfully !",
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
            text: 'Delivery Boy not added ! Please Try Again' ,
            onConfirmBtnTap: () {
              Navigator.pop(context) ;
            }
        );
      }
    }
  }

  Future<bool> validation() async{
    // Name Field can't be null
    if (name.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Name Input Field',
        content: 'Please enter a valid name \n It can\'t be left null',
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
    if (mobile.text.trim().length != 0 && !validMobile(countryCode + mobile.text.trim())) {
      await warningDialog(
        context: context,
        title: 'Mobile Input Field',
        content:
        'Please enter a valid mobile number\n Your mobile number is not matched with the general expression',
      );
      return false;
    }
    // Valid Address Check
    if (mobile.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Address Input Field',
        content: 'Please enter a valid address\n It can\'t be left null',
      );
      return false;
    }
    // Email Field has a valid regex expression
    if (email.text.trim().length != 0 && !validEmail(email.text.trim())) {
      await warningDialog(
        context: context,
        title: 'Email Input Field',
        content:
        'Please enter a valid email name \n Either left email field blank or enter the valid email Id',
      );
      return false;
    }
    // Image Field can't be null
    if (image == null) {
      await warningDialog(
        context: context,
        title: 'Image Field',
        content: 'Please give a unique image to be recognized ',
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Delivery Boy'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: ListView(
          children: [
            SizedBox(
              height: 10,
            ),
            image == null
                ? CircleAvatar(
                    radius: 60.0,
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    child: CircleAvatar(
                      radius: 58.0,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/images/person_profile_photo.jpg'),
                    ),
                  )
                : Container(
                    width: 120.0,
                    height: 120.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.contain, image: FileImage(image)),
                        border: Border.all(color: Colors.black, width: 2))),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Name',
                  hintText: 'Enter Name',
                ),
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                controller: name,
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CountryCodePicker(
                    onChanged: (value) {
                      countryCode = value.toString();
                      print(countryCode);
                    },
                    initialSelection: '+91',
                    favorite: ['+91', 'IND'],
                    showCountryOnly: false,
                    showOnlyCountryWhenClosed: false,
                    alignLeft: false,
                    textStyle: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(2, 0, 30, 0),
                    child: TextField(
                      autocorrect: false,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: 'Phone Number'),
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      controller: mobile,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Address',
                  hintText: 'Enter Address',
                ),
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                controller: address,
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 5, 5, 10),
              child: TextField(
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email',
                  hintText: 'Enter Email',
                ),
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                controller: email,
              ),
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
                  'ADD DELIVERY BOY',
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
