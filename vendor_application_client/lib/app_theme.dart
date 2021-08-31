import 'package:flutter/material.dart';

// 0 Blue
// 1 Red
// 2 Orange
var themes = [
  Themes(themeName: 'Blue' , themeData: ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Color(0xff00b3fe),
    secondaryHeaderColor: Color(0xff0163a2),
    accentColor: Colors.white,
    brightness: Brightness.light,
  )),
  Themes(themeName: 'Red' , themeData: ThemeData(
    primarySwatch: Colors.red,
    primaryColor: Color(0xffbe3237),
    secondaryHeaderColor: Color(0xffed1c24),
    accentColor: Colors.white,
    brightness: Brightness.light,
  )),
  Themes(themeName: 'Orange' , themeData: ThemeData(
primarySwatch: Colors.orange,
primaryColor: Color(0xff965d0c),
secondaryHeaderColor: Color(0xffff7200),
accentColor: Colors.white,
brightness: Brightness.light,
)),

];

class Themes {
  String themeName ;
  ThemeData themeData ;
  Themes({this.themeName , this.themeData}) ;

}
