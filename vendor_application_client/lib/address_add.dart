import 'dart:async';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/category_card.dart';
import 'package:vendor_application_client/database_functions/user_functions.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';
import 'package:vendor_application_client/utilites.dart';

import 'app_theme.dart';
import 'main.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'database_models/user_address.dart' ;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cool_alert/cool_alert.dart';


class AddressAddPage extends StatefulWidget {
  @override
  _AddressAddPageState createState() => _AddressAddPageState();
}

class _AddressAddPageState extends State<AddressAddPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  TextEditingController name = new TextEditingController() ;
  TextEditingController mobile = new TextEditingController() ;
  TextEditingController houseNumber = new TextEditingController() ;
  TextEditingController landmark = new TextEditingController() ;
  TextEditingController description = new TextEditingController() ;
  TextEditingController pinCode = new TextEditingController() ;
  List<String> addressTypes = ['Home', 'Work', 'Other'];
  String addressTypeSelect = 'Home';
  String countryCode = '+91';

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

  saveChanges() async {
      print("Name : " + name.text) ;
      print("Mobile : " + countryCode + mobile.text) ;
      print("House Number : " + houseNumber.text) ;
      print("Landmark : " + landmark.text) ;
      print("Description : "  + description.text) ;
      print("Pin Code : " + pinCode.text) ;
      print("Address Type : " + addressTypeSelect) ;

      // Validation
      if (name.text.trim().length == 0  ) {
        showDialog(
            context: context ,
            builder: (BuildContext context) {
              return alertDialog(context, 'Name Field', 'Value can\'t be null') ;
            }
        );
        return ;
      }
      if (mobile.text.trim().length == 0  ) {
        showDialog(
            context: context ,
            builder: (BuildContext context) {
              return alertDialog(context, 'Mobile', 'Value can\'t be null') ;
            }
        );
        return ;
      }
      if (houseNumber.text.trim().length == 0  ) {
        showDialog(
            context: context ,
            builder: (BuildContext context) {
              return alertDialog(context, 'House / Street Area', 'Value can\'t be null') ;
            }
        );
        return ;
      }
      if (landmark.text.trim().length == 0  ) {
        showDialog(
            context: context ,
            builder: (BuildContext context) {
              return alertDialog(context, 'Landmark : some distinct place around you', 'Value can\'t be null') ;
            }
        );
        return ;
      }
      if (pinCode.text.trim().length == 0  ) {
          showDialog(
              context: context ,
              builder: (BuildContext context) {
                return alertDialog(context, 'Pincode', 'Value can\'t be null') ;
              }
          );
        return ;
      }

      // Database Add
      UserAddress userAddress = new UserAddress.custom(
        streetArea: houseNumber.text ,
        landmark: landmark.text ,
        description: description.text ,
        addressType: addressTypeSelect ,
        pincode: pinCode.text ,
        name: name.text ,
        mobile: countryCode + mobile.text ,
      ) ;

      bool val = await addAddress(uid: FirebaseAuth.instance.currentUser.uid , address: userAddress ) ;
      // show message
      if (val == true ) {
        CoolAlert.show(
          context: context ,
          type: CoolAlertType.success ,
          text : "Address added Successfully !",
          onConfirmBtnTap: () {
            Navigator.pop(context);
            Navigator.pop(context) ;
          }
        ) ;
      }
      else {
        CoolAlert.show(
            context : context ,
            type: CoolAlertType.error ,
            text : 'Address is not added ! Please Try Again'

        );
      }
      return ;
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
        title: Text('Add Address'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Name',
                hintText: 'Name',
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
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'House No./ Street Area',
                hintText: 'House NO. / Street Area',
              ),
              style: GoogleFonts.lato(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              controller: houseNumber,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
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
              controller: landmark,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: TextField(
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
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Pin Code',
                hintText: 'Pin Code',
              ),
              style: GoogleFonts.lato(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              controller: pinCode,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Address Type : ' , style: GoogleFonts.lato(
                fontSize: 16 ,
                fontWeight: FontWeight.bold ,
                color : Colors.black
              ),),
              DropdownButton<String>(
                // Not necessary for Option 1
                value: addressTypeSelect,
                items: addressTypes.map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(
                      value,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    addressTypeSelect = value;
                  });

                },
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: FlatButton(
              onPressed: () {
                saveChanges() ;
              },
              color: Theme.of(context).secondaryHeaderColor,
              child: Text(
                'SAVE CHANGES',
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
    );
  }
}
