import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:image_picker/image_picker.dart';

Future<dynamic> warningDialog({BuildContext context, String title , String content}) {
  return CoolAlert.show(
    barrierDismissible:false ,
    context: context,
    type: CoolAlertType.warning,
    title: title,
    text: content,
    onConfirmBtnTap: () {
      Navigator.pop(context) ;
      return true ;
    }
  );
}

Future<dynamic> errorDialog({BuildContext context, String title , String content}) {
  return CoolAlert.show(
      barrierDismissible:false ,
      context: context,
      type: CoolAlertType.error,
      title: title,
      text: content,
      onConfirmBtnTap: () {
        Navigator.pop(context) ;
      }
  );
}
