import 'package:flutter/material.dart';
import 'address.dart';
import 'package:google_fonts/google_fonts.dart';
import 'database_models/user_address.dart' ;

class AddressDetailPage extends StatefulWidget {
  final UserAddress address ;
  AddressDetailPage({Key  key , this.address}) : super(key : key) ;
  @override
  _AddressDetailPageState createState() => _AddressDetailPageState();
}

class _AddressDetailPageState extends State<AddressDetailPage> {
  Widget customText({String title}) {
    return Text(title , style: GoogleFonts.lato(
      fontSize: 16 ,
      fontWeight: FontWeight.bold ,
      color: Colors.black ,
    ),);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Address Edit Page', style : GoogleFonts.lato(
          fontWeight : FontWeight.bold ,
          fontSize : 20 ,
          color: Colors.white
        ))
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
              customText(title:  'Name : ' + widget.address.name),
              customText(title: 'Mobile : ' + widget.address.mobile),
              customText(title: 'House / Street / Area : ' + widget.address.streetArea),
              customText(title: 'Landmark : ' + widget.address.landmark),
              customText(title: 'Description : ' + widget.address.description),
              customText(title: 'Pin Code : ' + widget.address.pincode),
              customText(title: 'Address Type : ' + widget.address.addressType),
            ],
          ),
        ),
      ),
    );
  }
}
