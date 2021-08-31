import 'dart:io';

import 'package:flutter/material.dart' ;
import 'package:flutter/services.dart';

dynamic noInternetConnectionDialog(BuildContext context ){
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      title: Text('ERROR'),
      content: Text("No Internet Detected."),
      actions: <Widget>[
        FlatButton(
          // method to exit application programitacally
          onPressed: () => SystemChannels.platform.invokeMethod('Systemnavigator.pop'),
          child: Text("Exit"),
        ),
      ],
    ),
  );
}


