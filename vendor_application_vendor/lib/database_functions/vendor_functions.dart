import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_application_vendor/database_models/deliveryBoy.dart';
import 'package:vendor_application_vendor/database_models/geolocation.dart';
import 'package:vendor_application_vendor/database_models/item.dart';
import 'package:vendor_application_vendor/database_models/vendor.dart';
import '../database_models/item.dart';
import '../database_models/order.dart';
import '../database_models/order.dart';
import '../database_models/shop.dart';
import '../database_models/vendor.dart';
import 'package:vendor_application_vendor/database_models/category.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

Future<bool> createVendor(Vendor vendor) async {
  try {
    final snapShot = await FirebaseFirestore.instance
        .collection('vendor')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    if (!snapShot.exists) {
      vendor.vendorId = FirebaseAuth.instance.currentUser.uid;
      var vendorJson = vendor.toJson();
      vendorJson.remove(['shops', 'deliveryBoy']);
      await firebaseFirestore
          .collection('vendor')
          .doc(vendor.vendorId)
          .set(vendorJson);
    }
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<bool> updateVendorProfile({String name, String businessName, String email, String mobileNumber,
  String password}) async {
  try {
    String uid = FirebaseAuth.instance.currentUser.uid;
    firebaseFirestore.collection('vendor').doc(uid).update({
      'name': name,
      'businessName': businessName,
      'email': email,
      'mobile': mobileNumber,
      'password': password
    });
    return true;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<dynamic> updateImage({Vendor vendor, var image}) async {
  //   image =>  orignal image with path, jo picker se milta hai
  File file = File(image.path);
  try {
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child('profileImages/${vendor.vendorId}')
        .putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    await firebaseFirestore.collection('vendor').doc(vendor.vendorId).update({
      'image': downloadUrl.toString(),
    });
    return downloadUrl; // returns a URl for image
  } on FirebaseException catch (e) {
    print(e.toString());
    return null;
  }
}

Future<Vendor> getVendorProfile({String uid}) async {
  DocumentSnapshot doc =
  await FirebaseFirestore.instance.collection('vendor').doc(uid).get();
  Map<String, dynamic> data = doc.data();
  Vendor vendor = new Vendor.fromJson(data);
  return Future.value(vendor);
}

//==============================================================================================

// Shop functions

//==============================================================================================

Future<dynamic> addShop({Vendor vendor, Shop shop,BuildContext context}) async {
  try {
    var shopJson = shop.toJson();
    shopJson.remove('items');
    shopJson.remove('ordersPending');

    var snapshot = await firebaseFirestore
        .collection('vendor')
        .doc(vendor.vendorId)
        .collection('shops')
        .where("shopNumber", isEqualTo: shop.shopNumber)
        .get();

    print("${snapshot.docs.length}");

    if (snapshot.docs.length == 0) {
      var dbShopId = await firebaseFirestore
          .collection('vendor')
          .doc(vendor.vendorId)
          .collection('shops')
          .add(shopJson);

      await firebaseFirestore
          .collection('vendor')
          .doc(vendor.vendorId)
          .collection('shops')
          .doc(dbShopId.id)
          .update({'shopId': dbShopId.id});

      shop.shopId = dbShopId.id;
      return shop.shopId;
    } else {
      print("Shop with same Shop Number Already Exits");
      // TODO : show error message ==================> Done
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog(context, 'Sho not added', 'Shop with same shop number already exits');
          });

      return null;
    }
  } catch (e) {
    print("=========Shop Not Added ===========");
    return null;
  }
}

Future<dynamic> updateShop({Vendor vendor, Shop oldShop, Shop newShop}) async {
  try {
    newShop.shopId = oldShop.shopId;
    newShop.image = oldShop.image;
    var newShopJson = newShop.toJson();
    newShopJson.remove('items');
    await firebaseFirestore
        .collection('vendor')
        .doc(vendor.vendorId)
        .collection('shops')
        .doc(oldShop.shopId)
        .update(newShopJson);
    return newShop.shopId;
  } catch (e) {
    print("=========Shop Not edited ===========");
    return null;
  }
}

Future<bool> deleteShop(Vendor vendor, Shop shop) async {
  try {
    await firebaseFirestore
        .collection('vendor')
        .doc(vendor.vendorId)
        .collection('shops')
        .doc(shop.shopId)
        .delete();
    return true;
  } catch (e) {
    print("=========Shop Not Removed ===========");
    return false;
  }
}

Future<dynamic> updateImageShop(
    {Vendor vendor, String shopId, var image}) async {
  //   image =>  orignal image with path, jo picker se milta hai
  File file = File(image.path);
  try {
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child('ShopImages/${shopId}')
        .putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();

    await firebaseFirestore
        .collection('vendor')
        .doc(vendor.vendorId)
        .collection('shops')
        .doc(shopId)
        .update({
      'image': downloadUrl.toString(),
    });
    return downloadUrl; // returns a URl for image
  } on FirebaseException catch (e) {
    print(e.toString());
    return null;
  }
}

Future<List<Shop>> getVendorShops({String uid}) async {
  QuerySnapshot result = await FirebaseFirestore.instance
      .collection('vendor')
      .doc(uid)
      .collection('shops')
      .get();
  List<DocumentSnapshot> docs = result.docs;
  List<Shop> shops = <Shop>[];
  for (int i = 0; i < docs.length; i++) {
    Map<String, dynamic> data = docs.elementAt(i).data();
    Shop shop = new Shop.fromJson(data);
    shops.add(shop);
  }
  return Future.value(shops);
}

//==============================================================================================

// item functions

//==============================================================================================

Future<String> addItem({Item item}) async {
  List<String> names;
  List<String> trigram;
  String string;


  try {

    QuerySnapshot checkItem = await firebaseFirestore.collection('items').where('vendorId',isEqualTo: item.vendorId)
        .where('shopId',isEqualTo: item.shopId).where('productName',isEqualTo: item.productName).
          where('quantity',isEqualTo: item.quantity).get();

    if (checkItem.docs.length < 1) {
      var itemID = firebaseFirestore.collection('items').doc();
      item.itemId = itemID.id;

      // Trigram Logic start
          string = item.productName;

          if (string.contains(" ")) names = string.split(" ");
          else names = [string];

          for(int i = 0;i<names.length;i++){

            if (names[i].length <= 3)
              trigram.add(names[i]);

            else{
              for(i = 0;i<names[i].length -2;i++)
                trigram.add(names[i].substring(i,i+3));
            }

          }
      // Logic End
      item.trigram = trigram;

      await firebaseFirestore.collection('items').doc(item.itemId).set(item.toJson());
      return itemID.id;

    } else {
      print("This item already exists");
    }
    return null;
  } catch (e) {
    print(e.toString());
    print("=========Item Not Added===========");
    return null;
  }
}

Future<bool> updateItem(
    {Item newItem, Item oldItem}) async {
  try {
    newItem.image = oldItem.image;
    newItem.itemId = oldItem.itemId;
    print(newItem.toJson()) ;
    print(oldItem.itemId) ;
    await firebaseFirestore
        .collection('items')
        .doc(oldItem.itemId)
        .set(newItem.toJson());
    return true;
  } catch (e) {
    print("=========Item Not Updated ===========");
    return false;
  }
}

Future<bool> deleteItem({Item item}) async {
  try {
    await firebaseFirestore
        .collection('items')
        .doc(item.itemId)
        .delete();
    return true;
  } catch (e) {
    print("=========Item Not Removed ===========");
    return false;
  }
}

Future<dynamic> updateImageItem({Item item, var image}) async {
  //   image =>  orignal image with path, jo picker se milta hai
  //TODO : Harshit update Image Item not workiing in the add Item section
  File file = File(image.path);
  try {
    var snapshot = await FirebaseStorage.instance
        .ref()
        .child('ItemImages/${item.itemId}')
        .putFile(file);
    print('Ok Image');
    var downloadUrl = await snapshot.ref.getDownloadURL();
    print(downloadUrl);
    await firebaseFirestore.collection('items').doc(item.itemId).update({
      'image': downloadUrl.toString(),
    });
    return downloadUrl; // returns a URl for image
  } on FirebaseException catch (e) {
    print(e.toString());
    return null;
  }
}

Future<List<Item>> loadingVendorCategoryItems (
    {String uid, Category category}) async {
  List<Item> items = <Item>[];
  QuerySnapshot itemResult = await firebaseFirestore
      .collection('items')
      .where('vendorId', isEqualTo: uid)
      .where('category', isEqualTo: category.categoryName).get() ;
  List<DocumentSnapshot> itemDocs = itemResult.docs;
  print(itemDocs);
  for (int j = 0; j < itemDocs.length; j++) {
    Map<String, dynamic> data = itemDocs.elementAt(j).data();
    Item item = Item.fromJson(data);
    print(item);
    items.add(item);
  }
  print(items);
  return items;
}

//==============================================================================================

// category functions

//==============================================================================================

Future<dynamic> addCategory(String name, var image, BuildContext context) async {
  File file = File(image.path);

  try {// TODO : Harshit check nahi ho raha hai ki category already exits hai ki nahi   =======> Done and check

    DocumentSnapshot checkCategory = await firebaseFirestore.collection('category').doc(name).get();

    if (!checkCategory.exists) {
      var snapshot = await FirebaseStorage.instance.ref().child('CategoryImages/$name').putFile(file);
      var downloadUrl = await snapshot.ref.getDownloadURL();

      await firebaseFirestore.collection('category').doc(name).set({
        'categoryName': name,
        'image': downloadUrl.toString(),
      });

      return downloadUrl;
    }// returns a URl for
    else{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alertDialog(context, 'Category not added', 'This category exist');
          });
    }// image
  } on FirebaseException catch (e) {
    print(e.toString());
    return null;
  }
}

Future<bool> updateCategoryName(Category category, String name) async {
  try {
    await firebaseFirestore.collection('category').doc(name).update({
      'categoryName': name,
    });
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> updateCategoryImage(Category category, var image) async {
  File file = File(image.path);
  try {
    await FirebaseStorage.instance
        .ref()
        .child('CategoryImages/${category.categoryName}')
        .putFile(file);
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> removeCategory(Category category) async {
  try {
    await FirebaseStorage.instance
        .ref()
        .child('CategoryImages/${category.categoryName}')
        .delete();
    await firebaseFirestore
        .collection('category')
        .doc(category.categoryName)
        .delete();
    return true;
  } catch (e) {
    return false;
  }
}

Future<List<Category>> loadCategory() async {
  try {
    QuerySnapshot categories =
    await firebaseFirestore.collection('category').get();
    List<Category> t =
    categories.docs.map((doc) => Category.fromJson(doc.data())).toList();
    return t;
  } catch (e) {
    return null;
  }
}

Future<Category> loadingCategoryByName(String categoryName) async {
  QuerySnapshot categoryResult = await firebaseFirestore
      .collection('category')
      .where('categoryName', isEqualTo: categoryName).get() ;
  List<DocumentSnapshot> categoryDocs = categoryResult.docs;
  for (int i = 0 ; i < categoryDocs.length ; i++ ) {
    Map<String, dynamic> data = categoryDocs.elementAt(i).data();
    Category category = Category.fromJson(data) ;
    return category ;
  }
  return null ;

}

//==============================================================================================

// Query functions

//==============================================================================================


Future<Shop> getShop({String vendorId,String shopId}) async{

    DocumentSnapshot shopRef = await firebaseFirestore.collection('vendor').doc(vendorId).collection('shops').doc(shopId).get();
    print(shopRef.data().toString());
    Shop shop = Shop.fromJson(shopRef.data());
    return shop;

}

Future<List<Shop>> getShopsByCategory({String categoryName}) async{
  Set itemSet = new  Set();
  List<Shop> shops = [];

  var items = await firebaseFirestore.collection('items').where('category',isEqualTo: categoryName).get();
  List<Item> itemList = items.docs.map((doc) => Item.fromJson(doc.data())).toList();

  for (int i =0;i<itemList.length;i++)
    itemSet.add([itemList[i].vendorId,itemList[i].shopId]);

  for(int i =0;i<itemSet.length;i++){
    var shop = await firebaseFirestore.collection('vendor').doc(itemSet.elementAt(i)[0])
        .collection('shops')
        .doc(itemSet.elementAt(i)[1]).get();

    shops.add(Shop.fromJson(shop.data()));
  }

  // for (int i =0;i<itemList.length;i++)
  //   print(shops[i].toJson().toString());

  return shops;
}

Future<Vendor> getVendorOfShop({Shop shop}) async{
  var vendor = await firebaseFirestore.collection('vendor').doc(shop.vendorId).get();
  return Vendor.fromJson(vendor.data());
}


Future<List<Order>> getOrders({String userUid}) async{
  QuerySnapshot ordersRef = await firebaseFirestore.collection('order').where('userId',isEqualTo: userUid).limit(25).get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}

Future<List<Order>> getPendingOrders({String userUid}) async{
  QuerySnapshot ordersRef = await firebaseFirestore.collection('user').doc(userUid).collection('ordersPending').get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}

Future<List<Order>> getPreviousOrders({String userUid}) async{
  QuerySnapshot ordersRef = await firebaseFirestore.collection('order').where('userId',isEqualTo: userUid)
      .where('orderStatus',isEqualTo: 'Delivered').limit(25).get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}



Future<List<Order>> getAllOrders({String vendorUid , String shopUid}) async{
  QuerySnapshot ordersRef = await firebaseFirestore.collection('order').where('shopId',isEqualTo: shopUid).get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}

Future<List<Order>> getAllOrdersByVendorId({String vendorUid}) async{
  try {
    QuerySnapshot ordersRef = await firebaseFirestore.collection('order').where(
        'vendorId', isEqualTo: vendorUid).get();
    List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data()))
        .toList();
    return orders;
  }catch(e){
    print(e.toString);
    return [];
  }
}

List<Order> getOrderByStatus({String statusType , List<Order> order}) {
  List<Order> statusOrder = [];
  for (int i =0;i<order.length;i++){
    if(order[i].orderStatus == statusType)
      statusOrder.add(order[i]);
  }
  return statusOrder;
}

Future<List<Shop>> getShopsByItem({String productName}) async{
  List<Shop> shops = [];
  try {
    QuerySnapshot itemRef = await firebaseFirestore.collection('items').where(
        'productName', isEqualTo: productName).get();
    List<Item> items = itemRef.docs.map((doc) => Item.fromJson(doc.data()))
        .toList();

    for (int i = 0; i < items.length; i++) {
      DocumentSnapshot shop = await firebaseFirestore.collection('vendor').doc(
          items[i].vendorId)
          .collection('shops').doc(items[i].shopId).get();
      shops.add(Shop.fromJson(shop.data()));
    }
    return shops;
  }catch(e){
    print(e.toString());
    return shops;
  }


}

//===================================================================================================

//Widget Section

//===================================================================================================

Widget alertDialog(BuildContext context, String title, String content) {
  return AlertDialog(
    title: Text(
      title,
      style: GoogleFonts.lato(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        fontStyle: FontStyle.normal,
      ),
    ),
    content: Text(
      content,
      style: GoogleFonts.lato(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        fontStyle: FontStyle.normal,
      ),
    ),
    actions: [
      FlatButton(
        child: Text(
          'OK',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontStyle: FontStyle.normal,
            color: Theme.of(context).primaryColor,
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ],
  );
}

//===================================================================================================

//API call Section

//===================================================================================================

Future<Geolocation> getLocation(String streetArea) async{

  List<Location> locations = await locationFromAddress(streetArea);

  print("length of location list ${locations.length}");
  for (int i = 0;i<locations.length;i++)
    print("${locations[i].latitude},${locations[i].longitude}");

  Geolocation location = Geolocation(locations[0].latitude.toString(),locations[0].longitude.toString());

  return location;

}