import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/category_card.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';

import 'app_theme.dart';
import 'main.dart';

class PromoCodePage extends StatefulWidget {
  @override
  _PromoCodePageState createState() => _PromoCodePageState();
}

class _PromoCodePageState extends State<PromoCodePage> {
  List<String> searchItems = <String>[
    "Apple",
    "Armidillo",
    "Actual",
    "Actuary",
    "America",
    "Argentina",
    "Australia",
    "Antarctica",
    "Blueberry",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promo Codes'),
      ),
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(
                flex: 8,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  child: SimpleAutoCompleteTextField(
                    key: null,
                    suggestions: searchItems,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search Product',
                    ),
                    controller: null,
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: IconButton(
                  color: Colors.white,
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).secondaryHeaderColor,
                    size: 28,
                  ),
                  onPressed: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
