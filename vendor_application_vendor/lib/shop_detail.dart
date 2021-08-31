import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:vendor_application_vendor/shop_add.dart';
import 'package:vendor_application_vendor/utilites.dart';
import 'app_theme.dart';
import 'database_models/shop.dart';
import 'shop.dart';

class ShopDetailPage extends StatefulWidget {
  final Shop shop;

  ShopDetailPage({Key key, this.shop}) : super(key: key);

  @override
  _ShopDetailPageState createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  StreamSubscription connectivitySubscription;

  ConnectivityResult previous;

  bool internetStatus = true;

  Widget customText({String title}) {
    return AutoSizeText(
      title,
      style: GoogleFonts.lato(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.black,
      ),
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Details'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 5),
        child: ListView(
          children: [
            widget.shop.image == null
                ? CircleAvatar(
                    radius: 60.0,
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    child: CircleAvatar(
                      radius: 58.0,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/images/person_profile_photo.jpg'),
                    ),
                  )
                : CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Theme.of(context).secondaryHeaderColor,
                    child: CircleAvatar(
                      radius: 48.0,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(widget.shop.image),
                    ),
                  ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 1, child: customText(title: 'Name : ')),
                Flexible(
                    flex: 1, child: customText(title: widget.shop.shopName)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 1, child: customText(title: 'Mobile : ')),
                Flexible(
                    flex: 1, child: customText(title: widget.shop.shopMobile)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 1, child: customText(title: 'Shop/ Street/ Area : ')),
                Flexible(
                    flex: 1, child: customText(title: widget.shop.shopNumber)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 1, child: customText(title: 'Landmark : ')),
                Flexible(
                    flex: 1,
                    child: customText(title: widget.shop.address.landmark)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 1, child: customText(title: 'Description : ')),
                Flexible(
                    flex: 1,
                    child: customText(title: widget.shop.address.description)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    flex: 1, child: customText(title: 'Minimum Amount : ')),
                Flexible(
                    flex: 1,
                    child: customText(title: widget.shop.minAmount.toString())),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 1, child: customText(title: 'Open Time : ')),
                Flexible(
                    flex: 1,
                    child: customText(
                        title: widget.shop.openTime == null
                            ? '---'
                            : widget.shop.openTime)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(flex: 1, child: customText(title: 'Close Time : ')),
                Flexible(
                    flex: 1,
                    child: customText(
                        title: widget.shop.closeTime == null
                            ? '---'
                            : widget.shop.closeTime)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: Theme.of(context).primaryColor,
                  checkColor: Colors.white,
                  value: widget.shop.deliveryOptions,
                  onChanged: (bool value) {
                    setState(() {});
                  },
                ),
                Text(
                  'Delivery Available',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
