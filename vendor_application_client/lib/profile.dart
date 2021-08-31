import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:vendor_application_client/utilites.dart';
import 'package:vendor_application_client/utilities_functions/input_utilities.dart';
import 'app_theme.dart';
import 'main.dart';
import 'package:image_picker/image_picker.dart';
import 'database_models/user.dart';
import 'package:cool_alert/cool_alert.dart';
import 'database_functions/user_functions.dart';
import 'authentication_service.dart';
import 'utilities_functions/widgit_utilities.dart';

class ProfilePage extends StatefulWidget {
  Users users;

  ProfilePage({Key key, this.users}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  StreamSubscription connectivitySubscription;

  ConnectivityResult previous;

  bool internetStatus = true;
  bool initData = true ;
  TextEditingController name = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController mobile = new TextEditingController();
  TextEditingController password = new TextEditingController();
  String imageUrl;

  File image;
  bool _obscuredText = true;

  _toggle() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }

  Future getImage({bool isCamera}) async {
    var imagePicker;
    if (isCamera == true) {
      imagePicker = await ImagePicker().getImage(source: ImageSource.camera);
    } else {
      imagePicker = await ImagePicker().getImage(source: ImageSource.gallery);
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

  void saveChanges() async {
    print("Details of Users : ");
    print("Name : " + name.text);
    print("Email : " + email.text);
    print("Mobile : " + mobile.text);
    print("Password : " + password.text);
    print('Image : ' + image.toString());

    bool val = await validation() ;
    if (val) {
      String nameValue = capitalize(name.text.trim()) ;
      String emailValue = email.text.trim() ;
      String mobileValue = mobile.text.trim() ;
      String passwordValue = password.text.trim() ;
      // Update User Password
      await updatePassword(password.text.trim());
      // Database Update
      Users user = new Users.create(
          name: nameValue,
          emailId: emailValue,
          phoneNumber: mobileValue,
          password: passwordValue);
      user.userId = widget.users.userId;
      if (val && image != null) {
        await updateUserImage(user: user, image: image);
      }
      if (val == true) {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.success,
            text: "Profile Updated Successfully !",
            onConfirmBtnTap: () {
              print('ok');
              Navigator.pop(context);
              Navigator.pop(context);
            });
      } else {
        CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            text: 'Profile is not updated ! Please Try Again');
      }
    }

  }

  Future<bool> validation() async {
    // Name field can't be null
    if (name.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Name Input Field',
        content: 'Please enter a valid name \n It can\'t be left null',
      );
      return false;
    }
    // Email Field can't be null
    if (email.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Email Input Field',
        content: 'Please enter a valid email name \n It can\'t be left null',
      );
      return false;
    }
    // Email Field has a valid regex expression
    if (email.text.trim().length != 0 && !validEmail(email.text.trim())) {
      await warningDialog(
        context: context,
        title: 'Email Input Field',
        content:
        'Please enter a valid email name \n Your email is not matched with the general expression ',
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
    // Password field can't be null
    if (password.text.trim().length == 0) {
      await warningDialog(
        context: context,
        title: 'Password Input Field',
        content: 'Please enter a valid password \n It can\'t be left null ',
      );
      return false;
    }
    // Password filed has the following syntax
    if (password.text.trim().length != 0 &&
        !validPassword(password.text.trim())) {
      await warningDialog(
        context: context,
        title: 'Password Input Field',
        content:
        'Please enter a valid password \n Minimum 1 Upper case \n Minimum 1 lowercase \n Minimum 1 Numeric Number \n  Minimum 1 Special Character \n  Common Allow Character ( ! @ # \$ & * ~ )  ',
      );
      return false;
    }
    // Image Field can't be null
    if (image == null && imageUrl == null) {
      await warningDialog(
        context: context,
        title: 'Image Field',
        content: 'Please give a unique image to be recognized ',
      );
      return false;
    }
    return true;

  }

  @override
  void initState() {
    super.initState();
    print('Home Pages Called');
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult now) {
      if (now == ConnectivityResult.none) {
        print('Not Connected');
        internetStatus = false;
        noInternetConnectionDialog(context);
      } else if (previous == ConnectivityResult.none) {
        print('Connected');
        if (internetStatus == false) {
          internetStatus = true;
          Navigator.pop(context);
        }
      }
      previous = now;
    });
  }

  @override
  void dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (initData) {
      if (widget.users.image != null) {
        imageUrl = widget.users.image;
      }
      if (widget.users.name != null) {
        name.text = widget.users.name;
      }
      if (widget.users.emailId != null) {
        email.text = widget.users.emailId;
      }
      if (widget.users.phoneNumber != null) {
        mobile.text = widget.users.phoneNumber;
      }
      if (widget.users.password != null) {
        password.text = widget.users.password;
      }
      initData = false ;
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile Page',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: ListView(
            children: [
              SizedBox(
                height: 10,
              ),
              image == null
                  ? imageUrl == null
                      ? CircleAvatar(
                          radius: 60.0,
                          backgroundColor:
                              Theme.of(context).secondaryHeaderColor,
                          child: CircleAvatar(
                            radius: 58.0,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                                'assets/images/person_profile_photo.jpg'),
                          ),
                        )
                      : CircleAvatar(
                          radius: 50.0,
                          backgroundColor:
                              Theme.of(context).secondaryHeaderColor,
                          child: CircleAvatar(
                            radius: 48.0,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(imageUrl),
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
                height: 5,
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
              Container(
                margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Email',
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
                margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextField(
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Mobile',
                    hintText: 'Mobile',
                  ),
                  style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  controller: mobile,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: TextField(
                  obscureText: _obscuredText,
                  decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Password',
                      suffixIcon: FlatButton(
                          onPressed: _toggle,
                          child: Icon(Icons.remove_red_eye,
                              color: _obscuredText
                                  ? Colors.black12
                                  : Colors.black54))),
                  style: GoogleFonts.lato(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  controller: password,
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
        ),
        floatingActionButton: buildSpeedDial());
  }
}
