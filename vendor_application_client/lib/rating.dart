import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_client/database_models/rating.dart';
import 'package:vendor_application_client/orders.dart';

import 'database_models/order.dart';
import 'main.dart';
import 'package:vendor_application_client/database_functions/user_functions.dart';

class RatingPage extends StatefulWidget {
  final Order order;

  RatingPage({Key key, this.order}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double punctuality = 3, quality =3, behaviour= 3, satisfaction=3, timelyCompletion=3;

  saveRating() async{
    print('Order : ' + widget.order.toJson().toString());
    print('Punctuality : ' + punctuality.toString()) ;
    print('Quality : ' + quality.toString()) ;
    print('Behaviour : ' + behaviour.toString()) ;
    print('Satisfaction : ' + satisfaction.toString()) ;
    print('Timely Completion : ' + timelyCompletion.toString()) ;
    Rating rating = Rating(punctuality, quality, behaviour, satisfaction, timelyCompletion);
    await rateOrder(widget.order,rating);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Rating',
        style: GoogleFonts.lato(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      )),
      body: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        children: [
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Punctuality',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (r) {
                    setState(() {
                      punctuality = r ;
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quality',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (r) {
                    setState(() {
                      quality = r ;
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Behaviour',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (r) {
                    setState(() {
                      behaviour = r ;
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Satisfaction',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (r) {
                    setState(() {
                      satisfaction = r ;
                    });
                  },
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timely Completion',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (r) {
                    setState(() {
                      timelyCompletion = r ;
                    });
                  },
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                onPressed: () {
                  saveRating() ;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Home()));
                },
                color: Theme.of(context).secondaryHeaderColor,
                child: Text(
                  'Rate Shop' ,
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold ,
                    fontSize: 20 ,
                    color: Colors.white ,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
