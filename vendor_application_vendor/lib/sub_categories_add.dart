import 'dart:async';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/items.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'app_theme.dart';

class SubCategoriesAdd extends StatefulWidget {
  @override
  _SubCategoriesAddState createState() => _SubCategoriesAddState();
}

class _SubCategoriesAddState extends State<SubCategoriesAdd> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;

  String category = 'Grocery' ;
  List<String> categories = ['Grocery' , 'Bakery and Kirana'] ;

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
        title: Text('Add SubCategory'),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.asset('assets/images/person_profile_photo.jpg' , height: 100, width: 100,) ,
              FlatButton(
                onPressed: null,
                child: Card(
                  color: Theme.of(context).secondaryHeaderColor,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    child: Text('Add Images' , style: GoogleFonts.lato(
                      fontStyle: FontStyle.normal ,
                      fontWeight: FontWeight.bold ,
                      color: Colors.white
                    ),),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Category' , style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal ,
                  fontWeight: FontWeight.bold ,
                  color: Colors.black
              ),),
              DropdownButton<String>(
                value: category,
                items: categories.map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (String v) {
                  setState(() {
                    category = v ;
                  });
                },
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Sub-Category',
                hintText: 'Enter Sub-Category',
              ),
              style: GoogleFonts.lato(
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              controller: null,
            ),
          ),
          FlatButton(
            onPressed: null,
            child: Card(
              color: Theme.of(context).secondaryHeaderColor,
              child: Padding(
                padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                child: Text('Add Sub-Category' , style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal ,
                    fontWeight: FontWeight.bold ,
                    color: Colors.white
                ),),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
