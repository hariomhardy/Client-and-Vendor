import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/account.dart';
import 'package:vendor_application_client/app_bar.dart';
import 'package:vendor_application_client/categories.dart';
import 'package:vendor_application_client/navigation_bottom.dart';
import 'package:vendor_application_client/orders.dart';

import 'app_theme.dart';
import 'home.dart';


class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  List<Notification> notifications = <Notification> [
    Notification(message: 'Hello XYZ , your booking request with ID XX , '
        'has been DELIVERED by Grocery SHop 11 , which was schedule , ',
        date: '2020-11-05', time: '07:29:35'),
    Notification(message: 'Hello XYZ , your booking request with ID XX , '
        'has been DELIVERED by Grocery SHop 11 , which was schedule , ',
        date: '2020-11-05', time: '07:29:35')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.lato(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Card(
              margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: ListTile(
                leading: Icon(
                  Icons.notifications_outlined,
                  size: 32,
                  color: Colors.black,
                ),
                title: Text(notifications
                    .elementAt(index)
                    .message,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(notifications
                    .elementAt(index)
                    .date + ' ' + notifications
                    .elementAt(index)
                    .time,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold ,
                  ),
                textAlign: TextAlign.right,),
              ),
            ),
          );
        },

      ),
    );
  }
}

class Notification {
  String message, date, time;

  Notification({this.message, this.date, this.time});
}