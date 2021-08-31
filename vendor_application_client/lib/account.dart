import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/profile.dart';
import 'package:vendor_application_client/utilites.dart';

import 'address.dart';
import 'app_theme.dart';
import 'authentication_service.dart';
import 'login.dart';
import 'main.dart';
import 'database_functions/user_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' ;
import 'database_models/user.dart' ;
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:async';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  StreamSubscription connectivitySubscription ;
  ConnectivityResult previous ;
  bool internetStatus = true ;
  bool progressIndicatorValue = true ;
  Widget progressIndicator() {
    return Center(
        child: Container(
            width: 100,
            height: 100,
            child: LoadingIndicator(indicatorType: Indicator.ballRotateChase , color: Theme.of(context).primaryColor ))) ;
  }
  Users users ;
  String imageUrl ;
  String name ;
  String email ;
  String phoneNumber ;

  FutureOr refreshScreen(dynamic value) async {
    users = await getUserProfile(uid : FirebaseAuth.instance.currentUser.uid) ;
    imageUrl = users.image ;
    name = users.name ;
    email = users.emailId ;
    phoneNumber = users.phoneNumber ;
    if (imageUrl == null ) {
      imageUrl = null ;
    }
    if (name == null ) {
      name = ' --- ' ;
    }
    if (phoneNumber == null) {
      phoneNumber = ' --- ' ;
    }
    if (email == null ) {
      email = ' --- ' ;
    }
    setState(() {
      this.users = users ;
      this.name = name ;
      this.email = email ;
      this.phoneNumber = phoneNumber ;
    });
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
    return FutureBuilder(
        future: getUserProfile(uid : FirebaseAuth.instance.currentUser.uid),
        builder: (context , AsyncSnapshot<dynamic> snapshot ) {
          if (snapshot.hasError) {
            return Text('Something Went Wrong') ;
          }
          if (snapshot.connectionState == ConnectionState.done) {
            users = snapshot.data ;
            imageUrl = users.image ;
            name = users.name ;
            email = users.emailId ;
            phoneNumber = users.phoneNumber ;
            if (imageUrl == null ) {
              imageUrl = null ;
            }
            if (name == null ) {
              name = ' --- ' ;
            }
            if (phoneNumber == null) {
              phoneNumber = ' --- ' ;
            }
            if (email == null ) {
              email = ' --- ' ;
            }
            return ListView(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: AutoSizeText(
                    'Profile' ,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold ,
                      fontSize: 18 ,
                      color: Colors.black ,
                    ),
                    maxLines: 1,
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Card(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex : 1 ,
                          child: imageUrl == null
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
                              backgroundImage:NetworkImage(imageUrl),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                name ,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),maxLines: 1,
                              ),

                              AutoSizeText(
                                email ,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),maxLines: 1,
                              ),
                              AutoSizeText(
                                phoneNumber ,
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: Colors.black,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.push(context , MaterialPageRoute(
                                    builder: (context) => ProfilePage(users : users)
                                )).then(refreshScreen) ;
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed : () {
                      Navigator.push(context , MaterialPageRoute(
                          builder: (context) => AddressPage()
                      )) ;
                    } ,
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading:
                      Icon(Icons.location_on_outlined, color: Colors.white, size: 24),
                      title: Text(
                        'My Address',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  // TODO : Have to update the Admin Phone and Contact Number
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed: () {
                      showDialog(context: context,
                          builder: (BuildContext context){
                            return contactUs() ;
                          }
                      );
                    },
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading:
                      Icon(Icons.contact_page_outlined, color: Colors.white, size: 24),
                      title: Text(
                        'Contact Us',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed: () {},
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading: Icon(Icons.share, color: Colors.white, size: 24),
                      title: Text(
                        'Share',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                  child: FlatButton(
                    onPressed: () {},
                    child: ListTile(
                      tileColor: Theme.of(context).secondaryHeaderColor,
                      leading: Icon(Icons.star, color: Colors.white, size: 24),
                      title: Text(
                        'Rate Us',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(5 , 5, 5, 10),
                  child: FlatButton(
                    onPressed: () async {
                      bool val = await signOutUser();
                      if (val) {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: "Logout Successfully !",
                            onConfirmBtnTap: () {
                              Navigator.pop(context) ;
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (BuildContext context) => EmailLoginPage()),
                                      (Route<dynamic> route) => false
                              );
                            }
                        );
                      }
                      else {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text: 'Logout is not succeeded ! Please Try Again' ,
                            onConfirmBtnTap: () {
                              Navigator.pop(context) ;
                            }
                        );
                      }
                    },
                    color: Theme.of(context).secondaryHeaderColor,
                    child: Text(
                      'Logout',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          else {
            return progressIndicator() ;
          }

        }
    );
  }
}

Widget contactUs() {
  return Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    child: Container(
      height: 200,
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: ListView(
            children: [
              Text('Contact Us' , style: GoogleFonts.lato(
                fontWeight: FontWeight.bold ,
                fontSize: 20 ,
              ),
              textAlign: TextAlign.center,),
              ListTile(
                leading: Icon(Icons.phone , color: Colors.green, size: 24,),
                title: Text(
                  'Phone' ,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold ,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  '+910000000001' ,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold ,
                    color: Colors.black,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.email , color: Colors.black54, size: 24,),
                title: Text(
                  'Email' ,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold ,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  'abc@gmail.com' ,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold ,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
  );
}

class RateUs extends StatefulWidget {
  @override
  _RateUsState createState() => _RateUsState();
}

class _RateUsState extends State<RateUs> {
  double rating = 3 ;
  @override
  Widget build(BuildContext context) {
    return  Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          height: 200,
          child: Card(
            elevation: 5,
            color: Colors.white,
            child: Align(
              alignment: Alignment.center,
              child: ListView(
                children: [
                  SmoothStarRating(
                      allowHalfRating: false,
                      onRated: (v) {
                        setState(() {
                          rating = v;
                        });
                      },
                      starCount: 5,
                      rating: rating,
                      size: 40.0,
                      isReadOnly:true,
                      filledIconData: Icons.blur_off,
                      halfFilledIconData: Icons.blur_on,
                      color: Colors.green,
                      borderColor: Colors.green,
                      spacing:0.0
                  ),

                ],
              ),
            ),
          ),
        )
    );
  }
}

