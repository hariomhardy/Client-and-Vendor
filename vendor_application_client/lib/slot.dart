import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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

class Slot extends StatefulWidget {
  @override
  _SlotState createState() => _SlotState();
}

class _SlotState extends State<Slot> {
  String dateSelect = 'Click Me';
  String timeStart = 'Click Me';
  String timeEnd = 'Click Me';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Slot'),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Date',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              FlatButton(
                shape: StadiumBorder(),
                onPressed: () async {
                  await DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2020, 1, 1), onChanged: (date) {
                    print('Change $date');
                    dateSelect = date.year.toString() +
                        '/' +
                        date.month.toString() +
                        '/' +
                        date.day.toString();
                  }, onConfirm: (date) {
                    print('Confirm $date');
                    dateSelect = date.year.toString() +
                        '/' +
                        date.month.toString() +
                        '/' +
                        date.day.toString();
                  }, currentTime: DateTime.now(), locale: LocaleType.en);
                  setState(() {
                    dateSelect = dateSelect;
                    print("######");
                  });
                },
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(
                      dateSelect,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slot Time Interval - Start',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              FlatButton(
                shape: StadiumBorder(),
                onPressed: () async {
                  await DatePicker.showTimePicker(context,
                      showTitleActions: true,
                      currentTime: DateTime.now(), onChanged: (dateTime) {
                    print('Change $dateTime');
                  }, onConfirm: (dateTime) {
                    print('Confirm $dateTime');
                    timeStart = dateTime.hour.toString() +
                        ':' +
                        dateTime.minute.toString();
                  }, locale: LocaleType.en);
                  setState(() {
                    timeStart = timeStart;
                    print("######");
                  });
                },
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(
                      timeStart,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slot Time Interval - End',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              FlatButton(
                shape: StadiumBorder(),
                onPressed: () async {
                  await DatePicker.showTimePicker(context,
                      showTitleActions: true,
                      currentTime: DateTime.now(), onChanged: (dateTime) {
                        print('Change $dateTime');
                      }, onConfirm: (dateTime) {
                        print('Confirm $dateTime');
                        timeEnd = dateTime.hour.toString() +
                            ':' +
                            dateTime.minute.toString();
                      }, locale: LocaleType.en);
                  setState(() {
                    timeEnd = timeEnd;
                    print("######");
                  });
                },
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Text(
                      timeEnd,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
            padding: EdgeInsets.fromLTRB(10,10,10,10),
            child: FlatButton(
              onPressed: () {

              },
              color: Theme.of(context).secondaryHeaderColor,
              child: Text('SET DATE AND TIME' , style: GoogleFonts.lato(
                fontWeight: FontWeight.bold ,
                fontSize: 16 ,
                color: Colors.white,
              ),),
            ),
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
