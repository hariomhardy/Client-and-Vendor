import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vendor_application_vendor/database_models/vendor.dart';

import 'package:vendor_application_vendor/database_models/deliveryBoy.dart';

FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;



Future<String> addDeliveryBoy(Vendor vendor,VendorDeliveryBoy deliveryBoy) async{
  try {
    var exist =  await firebaseFirestore.collection('vendor').doc(vendor.vendorId).collection('deliveryBoy')
        .where("phoneNumber", isEqualTo: deliveryBoy.phoneNumber).get();

    print("${exist.docs.length}");

    if (exist.docs.length == 0) {
      var dbdeliveryBoyId = await firebaseFirestore.collection('vendor').doc(vendor.vendorId).collection('deliveryBoy').add(deliveryBoy.toJson());

      await firebaseFirestore.collection('vendor').doc(vendor.vendorId)
          .collection('deliveryBoy').doc(dbdeliveryBoyId.id).update({
        'deliveryBoyId': dbdeliveryBoyId.id
      });

      deliveryBoy.deliveryBoyId = dbdeliveryBoyId.id;
      return Future.value(deliveryBoy.deliveryBoyId);
    }

    else{
      // TODO : show meassage that delivery boy already exits with this phone number
      print("DeliveryBoy with this phone number");
    }

    return null;
  } catch(e){
    print("=========Delivery Boy Not Added ===========");
    return null;
  }
}

Future<bool> updateDeliveryBoy({Vendor vendor,VendorDeliveryBoy oldDeliveryBoy,VendorDeliveryBoy newDeliveryBoy}) async{
  try {
    newDeliveryBoy.deliveryBoyId = oldDeliveryBoy.deliveryBoyId;
    newDeliveryBoy.image = oldDeliveryBoy.image;
    await firebaseFirestore.collection('vendor').doc(vendor.vendorId).collection('deliveryBoy').
    doc(oldDeliveryBoy.deliveryBoyId).update(newDeliveryBoy.toJson());
    return true;
  } catch(e){
    print("=========Delivery Boy Not edited ===========");
    return false;
  }
}

Future<dynamic> updateImageDeliveryBoy({Vendor vendor,VendorDeliveryBoy deliveryBoy,var image}) async{   //   image =>  orignal image with path, jo picker se milta hai
  File file = File(image.path);
  try {
    var snapshot = await FirebaseStorage.instance.ref().child('profileImages/${vendor.vendorId}+${deliveryBoy.phoneNumber}').putFile(file);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    await firebaseFirestore.collection('vendor').doc(vendor.vendorId).collection('deliveryBoy')
        .doc(deliveryBoy.deliveryBoyId).update({
      'image':downloadUrl.toString()
    });
    print(downloadUrl);
    return downloadUrl;         // returns a URl for image
  } on FirebaseException catch (e) {
    print(e.toString());
    return null;
  }
}

Future<bool> deleteDeliveryBoy(Vendor vendor,VendorDeliveryBoy deliveryBoy) async{
  try {
    await firebaseFirestore.collection('vendor').doc(vendor.vendorId).collection('deliveryBoy').
    doc(deliveryBoy.deliveryBoyId).delete();
    return true;
  } catch(e){
    print("=========Delivery Boy Not deleted ===========");
    return false;
  }
}

Future<List<VendorDeliveryBoy>> loadingVendorDeliveryBoys({String uid}) async {
  QuerySnapshot result =  await FirebaseFirestore.instance.collection('vendor').doc(uid).collection('deliveryBoy').get()  ;
  List<VendorDeliveryBoy> deliveryBoys = result.docs.map((doc) => VendorDeliveryBoy.fromJson(doc.data())).toList();
  return deliveryBoys ;
}

Future<bool> assignDeliveryBoyToOrder(String orderDocId,VendorDeliveryBoy vendorDeliveryBoy) async {
  try {
    await firebaseFirestore.collection('order').doc(orderDocId).update({'deliveryBoy': vendorDeliveryBoy.toJson()});
    return true;
  }catch(e){
    print(e.toString());
    return false;
  }
}