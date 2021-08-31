import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor_application_client/database_models/cart.dart';
import 'package:vendor_application_client/database_models/order.dart';
import 'package:vendor_application_client/database_models/user.dart';
import 'package:vendor_application_client/database_models/user_address.dart';



final FirebaseFirestore fireStore = FirebaseFirestore.instance;

Future<bool> createOrder({Users user,Cart cart,double deliveryCharges,String paymentType,
    String slotStartTime,String slotEndTime,String slotDate,
    UserAddress userAddress , bool homeDeliveryToUser }) async{

  String orderStatus = "Pending";

  Order order = Order( user.userId , cart.vendorId , cart.shopId,
      paymentType, cart.discountPrice , deliveryCharges , cart.discountPrice + deliveryCharges,
      slotStartTime, slotEndTime, slotDate, orderStatus,cart.items,userAddress , homeDeliveryToUser );

  try{
    fireStore.runTransaction((transaction) async {

      DocumentReference uid = fireStore.collection('order').doc();
      order.orderId = uid.id;

      transaction.set(fireStore.collection('order').doc(order.orderId),
          order.toJson());

      transaction.set(fireStore.collection('user').doc(user.userId).collection('ordersPending').doc(order.orderId),
          order.toJson());

      transaction.set(fireStore.collection('vendor').doc(cart.vendorId).collection('shops').doc(cart.shopId)
          .collection('ordersPending').doc(order.orderId), order.toJson());
    });

    return true;

  }catch(e){
    print("Error in transaction");
    return false;
  }
}


Future<bool> cancelOrder(Users user,Order order) async{

  try {
    fireStore.runTransaction((transaction) async {

      transaction.update(fireStore.collection('order').doc(order.orderId), {"orderStatus": 'Cancelled'});

      transaction.delete(fireStore.collection('user').doc(user.userId).collection('ordersPending').doc(order.orderId));

      transaction.delete(fireStore.collection('vendor').doc(order.vendorId).collection('shops').doc(order.shopId)
          .collection('ordersPending').doc(order.orderId));

    });

    return true;
  }catch(e){
    return false;
  }

}


Future<bool> changeOrderStatus(Order order,String status) async{

  try{
    fireStore.runTransaction((transaction) async {

      if (status != "Delivered") {
        transaction.update(fireStore.collection('order').doc(order.orderId),
            {'orderStatus': status});

        transaction.update(
            fireStore.collection('user').doc(order.userId).collection(
                'ordersPending').doc(order.orderId),
            {'orderStatus': status});

        transaction.update(
            fireStore.collection('vendor').doc(order.vendorId).collection(
                'shops').doc(order.shopId)
                .collection('ordersPending').doc(order.orderId),
            {'orderStatus': status});
      }

      else{
        transaction.update(fireStore.collection('order').doc(order.orderId),
            {'orderStatus': status});

        transaction.delete(fireStore.collection('user').doc(order.userId).collection(
            'ordersPending').doc(order.orderId));

        transaction.update(fireStore.collection('user').doc(order.userId),
            {'orders':FieldValue.arrayUnion([{'orderId':order.orderId}])});

        transaction.delete(fireStore.collection('vendor').doc(order.vendorId).collection(
            'shops').doc(order.shopId)
            .collection('ordersPending').doc(order.orderId));

        transaction.update(fireStore.collection('vendor').doc(order.vendorId).collection(
            'shops').doc(order.shopId),
            {'orders':FieldValue.arrayUnion([{'orderId':order.orderId}])});

      }

    });
    return true;
  }catch(e){
    print("Error occurred");
    return false;
  }
}


Future<bool> changeOrderAddress(Order order,UserAddress userAddress) async{

  try{
    fireStore.runTransaction((transaction) async {
      transaction.update(fireStore.collection('order').doc(order.orderId),{'address':userAddress.toJson()});

      transaction.update(fireStore.collection('user').doc(order.userId).collection('ordersPending').doc(order.orderId),
          {'address':userAddress.toJson()});

      transaction.update(fireStore.collection('vendor').doc(order.vendorId).collection('shops').doc(order.shopId)
          .collection('ordersPending').doc(order.orderId),{'address':userAddress.toJson()});

      print('==========================================');

    });
    return true;
  }catch(e){
    print("Error occurred");
    return false;
  }
}


Future<bool> changeOrderTime(Order order,String date,String slotStartTime,String slotEndTime) async{
  try{
    fireStore.runTransaction((transaction) async {


      transaction.update(fireStore.collection('order').doc(order.orderId),{'slotStartTime':slotStartTime,
        'slotEndTime':slotEndTime,
        'slotDate':date});

      transaction.update(fireStore.collection('user').doc(order.userId).collection('ordersPending').doc(order.orderId),
          {'slotStartTime':slotStartTime,
            'slotEndTime':slotEndTime,
            'slotDate':date});

      transaction.update(fireStore.collection('vendor').doc(order.vendorId).collection('shops').doc(order.shopId)
          .collection('ordersPending').doc(order.orderId),{'slotStartTime':slotStartTime,
        'slotEndTime':slotEndTime,
        'slotDate':date});

    });
    return true;
  }catch(e){
    print("Error occurred");
    return false;
  }
}


Future<void> sendPushMessage({String token,String body,String title}) async {
  if (token == null) {
    print('Unable to send FCM message, no token exists.');
    return;
  }

  try {
    http.Response value = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AAAA0jYjfJE:APA91bE_LreuS0KJMrNUr-peXOG28sSqFkWypmhGs4QL5kc01V4bynfjcNMUtSk6WIFiEBQGTFE1YOae9nagKrqetH1tQcD4DnIRDL4GPL7l6PtR10LRtiRd3o1FsJQE0mzEdoGOxg8y',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '$body',
            'title': '$title'
          },
          'priority': 'high',
          'to': token,
        },
      ),
    );

    print(value.statusCode.toString());
    if (value.statusCode.toString() == '200')
        print('FCM request for device sent!');
    else
        print('Error Occurred');
  } catch (e) {
    print(e);
  }
}