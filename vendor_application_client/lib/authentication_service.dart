import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendor_application_client/utilities_functions/widgit_utilities.dart';
import 'home.dart';
import 'main.dart';

FirebaseAuth auth = FirebaseAuth.instance ;

Future<bool> signIn(String email, String password, BuildContext context) async {
  print(email + '#') ;
  print(password);
  String errorMessage ;
  try {
    var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password);
    print('User Credentials : ' + user.credential.toString());
    return Future.value(true);
  } catch (error) {
    switch (error.code) {
      case "ERROR_INVALID_EMAIL":
        errorMessage = "Your email address appears to be malformed.";
        break;
      case "ERROR_WRONG_PASSWORD":
        errorMessage = "Your password is wrong.";
        break;
      case "ERROR_USER_NOT_FOUND":
        errorMessage = "User with this email doesn't exist.";
        break;
      case "ERROR_USER_DISABLED":
        errorMessage = "User with this email has been disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        errorMessage = "Too many requests. Try again later.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        errorMessage = "Signing in with Email and Password is not enabled.";
        break;
      default:
        errorMessage = "An undefined Error happened.";
    }
    await errorDialog(
        context: context ,
        title: 'User Login In Error' ,
        content: errorMessage + '\n Try to give right credentials or Sign Up \n Try to retrive password using Forget Password \n Please Try Again '
    );
    return Future.value(false);
  }
}

Future<bool> signUp(String email, String password, BuildContext context) async {
  String errorMessage ;
  try {
    var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);
    print(user.credential);
    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => Home()
    ));
    return Future.value(true);
    // return Future.value(true);
  } catch (error) {
    print(error.toString());
    switch (error.code) {
      case "ERROR_OPERATION_NOT_ALLOWED":
        errorMessage = "Anonymous accounts are not enabled";
        break;
      case "ERROR_WEAK_PASSWORD":
        errorMessage = "Your password is too weak";
        break;
      case "ERROR_INVALID_EMAIL":
        errorMessage = "Your email is invalid";
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        errorMessage = "Email is already in use on different account";
        break;
      case "ERROR_INVALID_CREDENTIAL":
        errorMessage = "Your email is invalid";
        break;

      default:
        errorMessage = "An undefined Error happened.";
    }
    await errorDialog(
        context: context ,
        title: 'User Sign Up In Error' ,
        content: errorMessage + '\n Try to give right credentials for  Sign Up \n Try to retrive password using Forget Password \n Please Try Again '
    );
    return Future.value(false);
  }
}

Future<bool> signOutUser() async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance ;
    //User user = auth.currentUser ;
    //print(user.providerData[1].providerId);
    await auth.signOut();
    return true;
  }catch (e) {
    return false ;
  }

}

Future<bool> resetPassword(String email , BuildContext context) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.sendPasswordResetEmail(email: email);
    return true;
  } catch (e) {
    await errorDialog(
        context: context ,
        title: 'User Sign Up In Error' ,
        content: 'Please check the Email Id & Internet Connection  \n Please Try Again '
    );
    return Future.value(false);
  }
}

Future<bool> updatePassword(String password) async{
  try {
    User currentUser = auth.currentUser;
    currentUser.updatePassword(password) ;
    return true ;
  }catch (e) {
    return false ;
  }
}
