import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/database_functions/vendor_functions.dart';
import 'package:vendor_application_vendor/database_models/geolocation.dart';
import 'package:vendor_application_vendor/database_models/vendor.dart';
import 'package:vendor_application_vendor/database_models/shop.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'database_models/address.dart';


FirebaseAuth auth = FirebaseAuth.instance ;
///////////////////////////////////////// change done in account.dart , in logout function
class TestingDbms extends StatefulWidget {
  @override
  _TestingDbmsState createState() => _TestingDbmsState();
}


class _TestingDbmsState extends State<TestingDbms> {
  Vendor vendor = Vendor(auth.currentUser.uid, "Hardy", "cencool4@gmail,com", "9415474229", "arebhaibhai", "BaapKidukan",null);
  Address address = Address("Ghar ke pheche", "near medical shop","Home",  Geolocation("19.26", "17.26"));

  Shop shop = Shop("hardyShop", '316451321', 'kholi420', 200, true,
      Address("Ghar ke bagal", "near medical shop","Home",
          Geolocation("19.26", "17.26")
      )
      ,null,null
  );

  Shop shop2 = Shop("hardyShop2", '78675634', 'hi', 400, true,
      Address("Ghar", "near WWE shop","Office",
          Geolocation("19.26", "17.26")
      )
      ,null,null
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            ElevatedButton(
              onPressed: () async{
                await getShopsByCategory(categoryName: 'Grocery');
              },
              child: Text('getShopsByCategory' , style: GoogleFonts.lato(
                fontWeight: FontWeight.bold ,
                fontSize: 14 ,
                color: Colors.black ,
              ),),
            ),

            ElevatedButton(
              onPressed: () async{
                /*
                 shop.shopId = await  addShop(vendor : vendor,shop : shop);
                 shop.shopId = await  addShop(vendor:vendor,shop:shop);
                 */
                print(shop.shopId);

                  //await getVendorOfShop();

              },
              child: Text('getVendorOfShop' , style: GoogleFonts.lato(
                fontWeight: FontWeight.bold ,
                fontSize: 14 ,
                color: Colors.black ,
              ),),
            ),

            ElevatedButton(
              onPressed: () async{

              },
              child: Text('Update Shop' , style: GoogleFonts.lato(
                fontWeight: FontWeight.bold ,
                fontSize: 14 ,
                color: Colors.black ,
              ),),
            ),

            ElevatedButton(
              onPressed: () async{
                await loadCategory();
              },
              child: Text('Delete Shop' , style: GoogleFonts.lato(
                fontWeight: FontWeight.bold ,
                fontSize: 14 ,
                color: Colors.black ,
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}