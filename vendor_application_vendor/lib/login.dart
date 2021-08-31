import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:vendor_application_vendor/sub_categories.dart';
import 'package:vendor_application_vendor/utilities_functions/input_utilities.dart';
import 'account.dart';
import 'app_theme.dart';
import 'home.dart';
import 'notification.dart';
import 'orders.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vendor_application_vendor/authentication_service.dart' ;
import 'package:vendor_application_vendor/database_models/vendor.dart' ;
import 'package:vendor_application_vendor/database_functions/vendor_functions.dart';
import 'package:cool_alert/cool_alert.dart';

enum MobileVerificationState { SHOW_MOBILE_FORM_STATE, SHOW_OTP_FORM_STATE }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String countryCode = '+91';
  TextEditingController phoneNumber = new TextEditingController();
  String mobileNumber;
  String verificationId;
  String smsCode;
  bool showLoading = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  void signInWithPhoneAuthCredential(phoneAuthCredential) async {
    var authCredential;
    setState(() {
      showLoading = true;
    });
    try {
      authCredential = await auth.signInWithCredential(phoneAuthCredential);
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(e.message)));
    }
    setState(() {
      showLoading = false;
    });

    if (authCredential?.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  getMobileFormWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xffA7BDEA), Colors.white]),
      ),
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Enter Mobile Number ...',
              style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black),
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
                      fontSize: 18,
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
                        fontSize: 18,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      controller: phoneNumber,
                    ),
                  ),
                ),
              ],
            ),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: RaisedButton(
                  onPressed: () async {
                    setState(() {
                      showLoading = true;
                    });
                    mobileNumber = countryCode + phoneNumber.text;
                    print('Mobile Number : ' + mobileNumber);
                    await auth.verifyPhoneNumber(
                      phoneNumber: mobileNumber,
                      verificationCompleted: (phoneAuthCredential) async {
                        setState(() {
                          showLoading = false;
                        });
                      },
                      verificationFailed: (verificationFailed) async {
                        setState(() {
                          showLoading = false;
                        });
                        scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(verificationFailed.message)));
                      },
                      codeSent: (verificationId, resendingToken) {
                        setState(() {
                          showLoading = false;
                          currentState =
                              MobileVerificationState.SHOW_OTP_FORM_STATE;
                          this.verificationId = verificationId;
                        });
                      },
                      codeAutoRetrievalTimeout: (verificationId) async {},
                    );
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: Text(
                      'Verify Mobile Number',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  getOtpFormWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xffA7BDEA), Colors.white]),
      ),
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Enter OTP',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            OTPTextField(
              length: 6,
              textFieldAlignment: MainAxisAlignment.spaceBetween,
              fieldWidth: 40,
              fieldStyle: FieldStyle.underline,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              onChanged: (value) {
                this.smsCode = value;
                print('OTP value : ' + this.smsCode);
              },
              onCompleted: (value) async {
                this.smsCode = value;
                print('OTP value #### : ' + this.smsCode);
                PhoneAuthCredential phoneAuthCredential =
                    PhoneAuthProvider.credential(
                        verificationId: this.verificationId,
                        smsCode: this.smsCode);
                signInWithPhoneAuthCredential(phoneAuthCredential);
              },
            ),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: RaisedButton(
                  onPressed: () async {
                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: this.verificationId,
                            smsCode: this.smsCode);
                    signInWithPhoneAuthCredential(phoneAuthCredential);
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: Text(
                      'Verify',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      currentState =
                          MobileVerificationState.SHOW_MOBILE_FORM_STATE;
                    });
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: Text(
                      'Change Mobile No.',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  getProgressIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xffA7BDEA), Colors.white]),
      ),
      child: Center(
        child: Container(
            height: 200,
            width: 200,
            child: LiquidCircularProgressIndicator(
              value: 0.25,
              // Defaults to 0.5.
              valueColor: AlwaysStoppedAnimation(Colors.blue),
              // Defaults to the current Theme's accentColor.
              backgroundColor: Colors.white,
              // Defaults to the current Theme's backgroundColor.
              borderColor: Colors.blue,
              borderWidth: 5.0,
              direction: Axis.vertical,
              // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
              center: Text(
                "Loading...",
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        body: showLoading
            ? getProgressIndicator(context)
            : currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                ? getMobileFormWidget(context)
                : getOtpFormWidget(context));
  }
}

class InitializedWidget extends StatefulWidget {
  @override
  _InitializedWidgetState createState() => _InitializedWidgetState();
}

class _InitializedWidgetState extends State<InitializedWidget> {
  FirebaseAuth auth;
  User user;
  bool isLoading = true;

  getProgressIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [Color(0xffA7BDEA), Colors.white]),
      ),
      child: Center(
        child: Container(
            height: 200,
            width: 200,
            child: LiquidCircularProgressIndicator(
              value: 0.25,
              // Defaults to 0.5.
              valueColor: AlwaysStoppedAnimation(Colors.blue),
              // Defaults to the current Theme's accentColor.
              backgroundColor: Colors.white,
              // Defaults to the current Theme's backgroundColor.
              borderColor: Colors.blue,
              borderWidth: 5.0,
              direction: Axis.vertical,
              // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
              center: Text(
                "Loading...",
                style: GoogleFonts.lato(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            )),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    user = auth.currentUser;
    isLoading = false;
    print(auth);
    print(user);
    if (user != null) {
    Vendor vendor = new Vendor(user.uid , null , null , null , null , null , null  ) ;
    createVendor(vendor) ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? getProgressIndicator(context)
        : user == null
            ? EmailLoginPage()
            : Home();
  }
}

class EmailLoginPage extends StatefulWidget {
  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  TextEditingController email = new TextEditingController();

  TextEditingController password = new TextEditingController();

  bool _obscuredText = true;

  _toggle() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xffA7BDEA), Colors.white]),
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Login Here',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextField(
                autocorrect: false,
                autofocus: true,
                decoration:
                    InputDecoration(hintText: 'Email', labelText: 'Email'),
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                controller: email,
              ),
              TextField(
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
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: RaisedButton(
                    onPressed: () async {
                      // Check the password strength
                      print('Email : ' + email.text.trim().toLowerCase() + '##') ;
                      bool  val = await signIn(email.text.trim().toLowerCase().toString() , password.text.toString() , context);
                      if (val == true ) {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: "Login Successfully !",
                            onConfirmBtnTap: () async{
                              Vendor vendor = new Vendor(FirebaseAuth.instance.currentUser.uid  , null , null , null , null , null , null  ) ;
                              await createVendor(vendor) ;
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );                            }
                        );
                      }
                    },
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Text(
                        'Login',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )),
              FlatButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => EmailSignUpPage()
                  ));
                },
                child: Text('Sign Up Here' , style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold ,
                  fontSize: 14 ,
                  color: Colors.black ,
                ),),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => ResetPassword()
                  ));
                },
                child: Text('Forget Password ? ' , style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold ,
                  fontSize: 14 ,
                  color: Colors.black ,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailSignUpPage extends StatefulWidget {
  @override
  _EmailSignUpPageState createState() => _EmailSignUpPageState();
}

class _EmailSignUpPageState extends State<EmailSignUpPage> {
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool _obscuredText = true;
  _toggle() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xffA7BDEA), Colors.white]),
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Sign Up',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextField(
                autocorrect: false,
                autofocus: true,
                decoration:
                InputDecoration(hintText: 'Email', labelText: 'Email'),
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                controller: email,
              ),
              TextField(
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
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: RaisedButton(
                    onPressed: () async {
                      print('Email : ' + email.text.trim().toLowerCase()) ;
                      print('Password : ' + password.text) ;
                      bool val = await signUp(email.text.trim().toLowerCase() , password.text , context) ;
                      if (val == true ) {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: "Sign In Successfully !",
                            onConfirmBtnTap: () async{
                              Vendor vendor = new Vendor(FirebaseAuth.instance.currentUser.uid  , null , null , null , null , null , null  ) ;
                              await createVendor(vendor) ;
                              Navigator.pop(context) ;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );                            }
                        );
                      }
                    },
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )),
              FlatButton(
                onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => EmailLoginPage()
                    ));
                },
                child: Text('Login Here' , style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold ,
                  fontSize: 14 ,
                  color: Colors.black ,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController email = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [Color(0xffA7BDEA), Colors.white]),
        ),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Enter Email',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              TextField(
                autocorrect: false,
                autofocus: true,
                decoration:
                InputDecoration(hintText: 'Email', labelText: 'Email'),
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                controller: email,
              ),
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: RaisedButton(
                    onPressed: () async {
                      print('Email : ' + email.text) ;
                      bool val = await resetPassword(email.text.trim().toLowerCase() , context) ;
                      if (val == true ) {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: "Password Link has been send to email !",
                            onConfirmBtnTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => EmailLoginPage()),
                              );
                            }
                        );
                      }
                    },
                    color: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                      child: Text(
                        'Reset Password',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )),
              FlatButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => EmailLoginPage()
                  ));
                },
                child: Text('Login' , style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold ,
                  fontSize: 14 ,
                  color: Colors.black ,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

