import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide Users;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:vendor_application_client/database_models/cart.dart';
import 'package:vendor_application_client/database_models/item.dart';
import 'package:vendor_application_client/database_models/rating.dart';
import 'package:vendor_application_client/database_models/user_address.dart';
import 'package:vendor_application_client/database_models/user.dart';
import 'package:vendor_application_client/database_models/geolocation.dart';
import 'package:vendor_application_client/database_models/category.dart';
import 'package:vendor_application_client/database_models/vendor.dart';
import 'package:vendor_application_client/database_models/shop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:vendor_application_client/database_models/order.dart' ;

final FirebaseFirestore fireStore = FirebaseFirestore.instance;

//==============================================================================================

// Users functions

//==============================================================================================


Future<bool> createUser(Users user) async {
  try {
    final snapShot = await FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .get() ;
    if (!snapShot.exists) {
      user.userId = FirebaseAuth.instance.currentUser.uid;
      var userJson = user.toJson() ;
      userJson.remove('address') ;
      userJson.remove('orderPending') ;
      print(userJson) ;
      await fireStore.collection('user').doc(user.userId).set(userJson);
      return true ;
    }
    return null ;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<Users> getUserProfile({String uid}) async{
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(uid).get() ;
  Map<String , dynamic> data = doc.data() ;
  Users users = new Users.fromJson(data) ;
  return Future.value(users) ;
}


Future<bool> updateUserProfile({String userID,String name,String email,String phone,String password}) async{
  try {
    await fireStore.collection('user').doc(userID).update({
      'name' : name,
      'emailId':email,
      'password':password,
      'phoneNumber':phone
    });
    return true ;
  }catch (exception) {
    print('Profile Not Updated') ;
    return false ;
  }
}

Future<dynamic> updateUserImage({Users user,var image}) async{   //   image =>  orignal image with path
  File file = File(image.path);
  try {
    var snapshot = await FirebaseStorage.instance.ref().child('userProfileImages/${user.userId}').putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    await fireStore.collection('user').doc(user.userId).update({
      'image': downloadUrl.toString(),
    });
    return downloadUrl;         // returns a URl for image
  } on FirebaseException catch (e) {
    print(e.toString());
    return null;
  }

}


//===================================================================================================

//           Users Address  Functions of Users

//===================================================================================================

Future<bool> addAddress({String uid ,UserAddress address}) async{
  try {
    var addressJson = address.toJson() ;
    var snapshot = await fireStore
    .collection('user')
    .doc(uid)
    .collection('address')
    .where('streetArea' , isEqualTo: address.streetArea)
    .get() ;

    if (snapshot.docs.length == 0 ) {
      var addressId = await fireStore
          .collection('user')
          .doc(uid)
          .collection('address')
          .add(addressJson) ;

      await fireStore
      .collection('user')
      .doc(uid)
      .collection('address')
      .doc(addressId.id)
      .update({'addressId' : addressId.id }) ;

      address.addressId = addressId.id ;
      return true ;
    } else {
      print("Shop with same Shop Address Alredady Exits");
      return false ;
    }
  } catch(e){
    print("=========Address Not Added ===========");
    return false;
  }
}

Future<List<UserAddress>> getUserAddresses({String uid}) async {
  QuerySnapshot result = await FirebaseFirestore.instance
      .collection('user')
      .doc(uid)
      .collection('address')
      .get();
  List<DocumentSnapshot> docs = result.docs;
  List<UserAddress> addresses = <UserAddress>[];
  for (int i = 0 ; i < docs.length ; i++ ) {
    Map<String, dynamic> data = docs.elementAt(i).data();
    UserAddress userAddress = new UserAddress.fromJson(data) ;
    addresses.add(userAddress) ;
  }
  return Future.value(addresses) ;
}

Future<bool> deleteAddress({String uid ,UserAddress address}) async{
  try {
    await fireStore.collection('user')
        .doc(uid)
        .collection('address')
        .doc(address.addressId)
        .delete() ;
    return Future.value(true);
  }catch(e){
    print("=========Address Not Removed ===========");
    return false;
  }
}

Future<bool> updateAddress({String uid , UserAddress oldAddress,UserAddress newAddress}) async{ //{Users user,UsersAddress address}
  try {
    newAddress.addressId = oldAddress.addressId ;
    var newAddressJson = newAddress.toJson() ;

    await fireStore
    .collection('user')
    .doc(uid)
    .collection('address')
    .doc(oldAddress.addressId)
    .update(newAddressJson) ;

    return true;
  } catch(e){
    print("=========Address Not edited ===========");
    return false;
  }
}


Future<List<Category>> loadCategory() async {
  try {
    QuerySnapshot categories =
    await fireStore.collection('category').get();
    List<Category> t =
    categories.docs.map((doc) => Category.fromJson(doc.data())).toList();
    return t;
  } catch (e) {
    return null;
  }
}

Future<List<String>> loadItemNames() async {
  try{
    List<String> itemsNames= [] ;
    QuerySnapshot itemDocs = await fireStore.collection('items').get();
    List<Item> items = itemDocs.docs.map((doc) => Item.fromJson(doc.data())).toList() ;
    for (int i =0 ; i < items.length ; i++) {
      itemsNames.add(items.elementAt(i).productName) ;
    }
    return itemsNames ;
  } catch (e) {
    return null ;
  }
}


Future<List<String>> loadItemNamesByTrigrams(String string) async {
  List<String> itemsNames= [];
  List<String> names;
  List<String> searchNames;

  if (string.contains(" ")) names = string.split(" ");
  else names = [string];

  for(int i = 0;i<names.length;i++){
      if (names[i].length <= 3)
        searchNames.add(names[i]);
      else{
        for(i = 0;i<names[i].length -2;i++) searchNames.add(names[i].substring(i,i+3));
      }
  }


  try {
    QuerySnapshot itemDocs = await fireStore.collection('items').where(
        'trigram', arrayContainsAny: searchNames).get();
    List<Item> items = itemDocs.docs.map((doc) => Item.fromJson(doc.data()))
        .toList();
    for (int i = 0; i < items.length; i++) {
      itemsNames.add(items
          .elementAt(i)
          .productName);
    }
    return itemsNames;
  }catch(e){
    print(e.toString());
  }
}



Future<List<Vendor>> loadVendorsByCategory({String categoryName}) async {
  try{
    // get all vendor ids
    List<String> vendorIds = <String> [] ; 
    QuerySnapshot itemDocs = await fireStore.collection('items').where( 'category', isEqualTo: categoryName ).get() ;
    List<Item> items = itemDocs.docs.map((doc) => Item.fromJson(doc.data())).toList() ;
    for (int i=0 ; i < items.length ; i++ ) {
      vendorIds.add(items.elementAt(i).vendorId) ;
    }
    // get all vendor list
    vendorIds = vendorIds.toSet().toList() ;
    List<Vendor> vendors = <Vendor> [] ;
    for (int i = 0 ; i< vendorIds.length ; i++ ) {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('vendor').doc(vendorIds.elementAt(i)).get();
      Map<String, dynamic> data = doc.data();
      Vendor vendor = new Vendor.fromJson(data);
      vendors.add(vendor) ;
    }
    return vendors;
  } catch (e) {
    return null ;
  }
}

Future<List<Shop>> loadShopsByVendor({String vendorId}) async {
  QuerySnapshot result = await FirebaseFirestore.instance
      .collection('vendor')
      .doc(vendorId)
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

Future<List<Item>> loadItemsByVendorShop({String vendorId , String shopId}) async {
  try {
    List<Item> items = <Item>[];
    QuerySnapshot itemResult = await fireStore
        .collection('items')
        .where('vendorId', isEqualTo: vendorId )
        .where('shopId', isEqualTo: shopId).get() ;
    List<DocumentSnapshot> itemDocs = itemResult.docs;
    for (int i = 0 ; i < itemDocs.length ; i++ ) {
      Map<String, dynamic> data = itemDocs.elementAt(i).data();
      Item item = Item.fromJson(data);
      print(item);
      items.add(item);
    }
    print(items) ;
    return items ;
  }catch (e) {
    print('Items not loaded') ;
    return null ;
  }
}

//===================================================================================================

//           Cart Functions of Users

//===================================================================================================


Future<Users> updateCart(Users user, Item item, BuildContext context) async {
  if (user.cart == null)
    return createCart(user, item , context);
  else
    return addItemToCart(user, item , context);
}

Future<Users> createCart(Users user,Item item , BuildContext context ) async{
  item.count = 1 ;
  Cart cart = Cart(item.vendorId, item.shopId, item.originalPrice , item.discountPrice , [item]);

  try {
    await fireStore.collection('user').doc(user.userId).update({'cart': cart.toJson()});
    user.cart = cart;
    return user;
  }catch (e){
    return null;
  }
}

Future<Users> addItemToCart(Users user,Item item, BuildContext context) async{
  bool exists = false;
  Cart cart = user.cart;
  if (cart.shopId != item.shopId){
    showDialog(
        context: context ,
        builder: (BuildContext context) {
          return alertDialog(context, 'Items', 'Selected items are not from same shop !! Please clear cart') ;
        }
    );
    return null ;
  }

  cart.discountPrice += item.discountPrice;
  cart.originalPrice += item.originalPrice;

  for( int  i = 0 ; i<cart.items.length; i++ ) {
    if( cart.items[i].productName == item.productName) {
      cart.items[i].count +=  1 ;
      exists = true;
    }
  }

  for (int i = 0 ; i< cart.items.length ; i++ ) {
    print(cart.items.elementAt(i).count) ;
  }

  if (!exists) {
    item.count = 1;
    cart.items.add(item);
  }

  try {
    await fireStore.collection('user').doc(user.userId).update({'cart' : cart.toJson()});
    user.cart = cart;
    return await getUserProfile(uid : FirebaseAuth.instance.currentUser.uid);
  }catch(e){
    print(e.toString());
    return null ;
  }

}

Future<Users> removeItemFromCart(Users user,Item item) async {
  Cart cart = user.cart;
  bool remove = true;
  cart.discountPrice -= item.discountPrice;
  cart.originalPrice -= item.originalPrice;
  for (var i = 0; i < cart.items.length; i++) {
    if (cart.items[i].productName == item.productName) {
      if (cart.items[i].count > 1) {
        //delItem = cart.items[i] ;
        await fireStore.collection('user').doc(user.userId).update({
          'cart.items': FieldValue.arrayRemove([cart.items[i].toJson()])});
        cart.items[i].count -= 1;
        await fireStore.collection('user').doc(user.userId).update({
          'cart.discountPrice': cart.discountPrice,
          'cart.originalPrice': cart.originalPrice,
          'cart.items': FieldValue.arrayUnion([cart.items[i].toJson()])});
        remove = false;
        break;
      }
    }
  }

  if (remove) {
    item.count = 1 ;
    if (cart.items.length != 1 ) {
      await fireStore.collection('user').doc(user.userId).update({
        'cart.discountPrice': cart.discountPrice,
        'cart.originalPrice': cart.originalPrice,
        'cart.items': FieldValue.arrayRemove([item.toJson()])});
    }
    else {
      await fireStore.collection('user').doc(user.userId).update({'cart' : null}) ;
    }

  }



  return await getUserProfile(uid : FirebaseAuth.instance.currentUser.uid);
}

Future<bool> clearCart({Users user}) async{
  try {
    await fireStore.collection('user').doc(user.userId).update({'cart': null});
    return true;
  }catch(e){
    print(e.toString());
    return false;
  }
}

Widget alertDialog(BuildContext context, String title , String content) {
  return AlertDialog(
    title: Text(title , style: GoogleFonts.lato(
      fontWeight : FontWeight.bold ,
      fontSize : 16 ,
      fontStyle : FontStyle.normal ,
    ),),
    content: Text(content , style: GoogleFonts.lato(
      fontWeight: FontWeight.bold ,
      fontSize : 16 ,
      fontStyle : FontStyle.normal ,
    ),),
    actions: [
      FlatButton(
        child: Text('OK' , style: GoogleFonts.lato(
          fontWeight: FontWeight.bold ,
          fontSize: 14 ,
          fontStyle: FontStyle.normal ,
          color: Theme.of(context).primaryColor ,
        ),),
        onPressed: () {
          Navigator.pop(context) ;
        },
      )
    ],
  );
}

//===================================================================================================

//           Shop Functions of Users

//===================================================================================================

Future<Shop> loadShop(String vendorId,String shopId) async{
  DocumentSnapshot shopRef = await fireStore.collection('vendor').doc(vendorId).collection('shops').doc(shopId).get();
  Shop shop = Shop.fromJson(shopRef.data());
  return shop;
}

Future<List<Shop>> getShopsByCategory({String categoryName}) async {
  Set itemSet = new Set();
  Set<Shop> shops = new Set() ;

  var items = await fireStore.collection('items').where(
      'category', isEqualTo: categoryName).get();
  List<Item> itemList = items.docs.map((doc) => Item.fromJson(doc.data()))
      .toList();

  for (int i = 0; i < itemList.length; i++) {
    itemSet.add(jsonEncode([itemList[i].vendorId.toString() , itemList[i].shopId.toString()]));
  }

  print(itemSet.length) ;
  for (int i = 0 ; i < itemSet.length ; i++) {
    print(jsonDecode(itemSet.elementAt(i))) ;
  }

  for (int i = 0; i < itemSet.length; i++) {
    var shop = await fireStore.collection('vendor').doc(jsonDecode(itemSet.elementAt(i))[0])
        .collection('shops')
        .doc(jsonDecode(itemSet.elementAt(i))[1]).get();
    shops.add(Shop.fromJson(shop.data()));
  }
  print(shops.length) ;
  return shops.toList() ;
}

Future<List<Order>> getOrders({String userUid}) async {
  QuerySnapshot result = await FirebaseFirestore.instance
      .collection('order')
      .where('userId' , isEqualTo: userUid)
      .get();
  List<DocumentSnapshot> docs = result.docs;
  List<Order> orders = <Order>[] ;
  for (int i = 0 ; i <docs.length ; i++) {
    Map<String, dynamic> data = docs.elementAt(i).data();
    Order order = new Order.fromJson(data) ;
    orders.add(order) ;
  }
  return Future.value(orders) ;
  // for (int i =0;i<itemList.length;i++)
  //   print(shops[i].toJson().toString());
}

Future<Vendor> getVendorOfShop({Shop shop}) async{
  var vendor = await fireStore.collection('vendor').doc(shop.vendorId).get();
  return Vendor.fromJson(vendor.data());
}

Future<List<Order>> getOrdersForUser({String userUid}) async{
  QuerySnapshot ordersRef = await fireStore.collection('order').where('userId',isEqualTo: userUid).limit(25).get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}

Future<List<Order>> getPendingOrders({String userUid}) async{
  QuerySnapshot ordersRef = await fireStore.collection('user').doc(userUid).collection('ordersPending').get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}

Future<List<Order>> getPreviousOrders({String userUid}) async{
  QuerySnapshot ordersRef = await fireStore.collection('order').where('userId',isEqualTo: userUid)
      .where('orderStatus',isEqualTo: 'Delivered').limit(25).get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}



Future<List<Order>> getAllOrders({String vendorUid , String shopUid}) async{
  QuerySnapshot ordersRef = await fireStore.collection('order').where('shopId',isEqualTo: shopUid).get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
}

Future<List<Order>> getAllOrdersByVendorId({String vendorUid}) async{
  QuerySnapshot ordersRef = await fireStore.collection('order').where('vendorId',isEqualTo: vendorUid).get();
  List<Order> orders = ordersRef.docs.map((doc) => Order.fromJson(doc.data())).toList();
  return orders;
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
  Set<Shop> shops = new Set() ;
  try {
    QuerySnapshot itemRef = await fireStore.collection('items').where(
        'productName', isEqualTo: productName).get();
    List<Item> items = itemRef.docs.map((doc) => Item.fromJson(doc.data()))
        .toList();

    for (int i = 0; i < items.length; i++) {
      DocumentSnapshot shop = await fireStore.collection('vendor').doc(
          items[i].vendorId)
          .collection('shops').doc(items[i].shopId).get();
      shops.add(Shop.fromJson(shop.data()));
    }
    return shops.toList();
  }catch(e){
    print(e.toString());
    return shops.toList();
  }

}

Future<Shop> getShop({String vendorId,String shopId}) async{
  DocumentSnapshot shopRef = await fireStore.collection('vendor').doc(vendorId).collection('shops').doc(shopId).get();
  Shop shop = Shop.fromJson(shopRef.data());
  return shop;
}

Future<Item> getItem({String itemId}) async {
  QuerySnapshot snapshot = await fireStore.collection('items').where('itemId' , isEqualTo: itemId).get();
  List<Item> itemDocs = snapshot.docs.map((doc) => Item.fromJson(doc.data())).toList();
  return itemDocs.elementAt(0);
}



//============================================================================================================

// Rating Related

//===========================================================================================================


Future<bool> rateOrder(Order order,Rating rating) async{
  try{
    DocumentReference shopReference = fireStore.collection('vendor').doc(order.vendorId)
                                        .collection('shops').doc(order.shopId);

    fireStore.runTransaction((transaction) async {
          DocumentSnapshot shopDoc = await transaction.get(shopReference);
          DocumentSnapshot orderDoc = await transaction.get(fireStore.collection('order').doc(order.orderId));


          Shop shop = Shop.fromJson(shopDoc.data());
          if (shop.rating == null) {
            rating.count = 1;
            rating.overallRating = (rating.punctuality
                +rating.timelyCompletion
                +rating.satisfaction
                +rating.behaviour
                +rating.quality)/5;
            shop.rating = rating;
          }
          else{
            shop.rating.rate(rating);
          }

          print(shop.toJson().toString());

          transaction.update(shopReference,{'rating':shop.rating.toJson()});


          Order currentOrder = Order.fromJson(orderDoc.data());
          currentOrder.isRated = true;
          transaction.update(fireStore.collection('order').doc(order.orderId),{'isRated':true});
    });


    return true;
  }catch(e){
    return false;
  }
}


Future<Rating> getRating(String vendorId,String shopId) async{
  DocumentSnapshot getShop = await fireStore.collection('vendor').doc(vendorId)
      .collection('shops').doc(shopId).get();

  Shop shop =  Shop.fromJson(getShop.data());
  return shop.rating;

}


//============================================================================================================

// FCM Token Related

//===========================================================================================================

Future<String> getToken() async{
  try{
    String token = await FirebaseMessaging.instance.getToken();
    return token;
  }catch(e){
    print(e.toString());
    return null;
  }
}

Future<bool> updateTokenUser(Users user) async{
  try {
    String token = await getToken();
    fireStore.collection('user').doc(user.userId).update({
      'token': token
    });
    return true;
  }catch(e){
    print(e.toString());
    return false;
  }
}

Future<bool> updateTokenVendor(Vendor vendor) async{
  try {
    String token = await getToken();
    fireStore.collection('vendor').doc(vendor.vendorId).update({
      'token': token
    });
    return true;
  }catch(e){
    print(e.toString());
    return false;
  }
}












