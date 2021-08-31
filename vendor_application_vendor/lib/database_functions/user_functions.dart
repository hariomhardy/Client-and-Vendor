import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vendor_application_vendor/database_models/cart.dart';
import 'package:vendor_application_vendor/database_models/item.dart';
import 'package:vendor_application_vendor/database_models/user_address.dart';
import 'package:vendor_application_vendor/database_models/user.dart';
import 'package:vendor_application_vendor/database_models/geolocation.dart';



final FirebaseFirestore fireStore = FirebaseFirestore.instance;


//==============================================================================================

// User functions

//==============================================================================================

Future<User> createUser(User user) async {
  try {
    user.userId = FirebaseAuth.instance.currentUser.uid;
    await fireStore.collection('user').doc(user.userId).set(user.toJson());
    return user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<void> updateProfile({userID,name,email,phone,password}) async{
  await fireStore.collection('user').doc(userID).update({
     'name' : name,
     'emailId':email,
     'password':password,
     'phoneNumber':phone
  });
}

Future<dynamic> updateImage({User user,var image}) async{   //   image =>  orignal image with path
  File file = File(image.path);
  try {
    var snapshot = await FirebaseStorage.instance.ref().child('profileImages/${user.userId}').putFile(file);
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

//           User Address  Functions of User

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

//===================================================================================================

//           Cart Functions of User

//===================================================================================================

//return bool

Future<User> createCart(User user,Item item,String vendorId,String shopId) async{

  Cart cart = Cart(vendorId, shopId,
      (item.originalPrice)*(item.count), (item.discountPrice)*(item.count), [item]);

  try {

    await fireStore.collection('user').doc(user.userId).update({'cart': cart.toJson()});
    user.cart = cart;
    return user;

  }catch (e){
    return null;
  }
}  //Vendor id , Shop id

Future<void> clearCart(User user) async{
  try {
    await fireStore.collection('user').doc(user.userId).update({'cart': null});
  }catch(e){
    print(e.toString());
  }
}

//==============================================================================================

// Search Item functions

//==============================================================================================

Future<List<Item>> searchItemByName(String name) async{
  QuerySnapshot items = await fireStore.collectionGroup('items').where('productName',isEqualTo:name).get();
  List<Item> t = items.docs.map((doc) => Item.fromJson(doc.data())).toList();
  for(int i =0;i<t.length;i++){
    print(t[i].toJson());
  }
  return t;
}










