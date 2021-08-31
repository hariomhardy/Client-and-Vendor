import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vendor_application_client/app_theme.dart';

import 'main.dart';


class CustomAppBar extends StatefulWidget  {
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  void _selectTheme(Themes theme) {
    setState(() {
      App.setTheme(context, theme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Vendor-Client"),
      actions: [
        IconButton(
          icon : Icon(Icons.add_alert , color: Colors.white,) ,
          onPressed: null,
        ),
        IconButton(
          icon : Icon(Icons.shopping_cart, color: Colors.white,) ,
          onPressed: null,
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert , color : Colors.white),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 1,
              child : PopupMenuButton(
                child: Container(
                  child: Row(
                    children: [
                      Text(
                          'Theme',
                      ),
                    ],
                  ),
                ),
                elevation: 3.2,
                initialValue: themes[0],
                onCanceled: () {
                  print("Nothing  Selected");
                },
                onSelected: _selectTheme,
                itemBuilder: (BuildContext context) {
                  return themes.map((Themes theme) {
                    return PopupMenuItem(
                      value: theme,
                      child: Text(theme.themeName),
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),

      ],
    );
  }
}

Widget customAppBar() {
  CustomAppBar customAppBar = new CustomAppBar() ;
  return customAppBar ;
}
