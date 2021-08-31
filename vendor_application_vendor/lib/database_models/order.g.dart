// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) {
  return Order(
    json['userId'] as String,
    json['vendorId'] as String,
    json['shopId'] as String,
    json['paymentType'] as String,
    (json['paymentTotal'] as num)?.toDouble(),
    (json['deliveryCharges'] as num)?.toDouble(),
    (json['paymentPayable'] as num)?.toDouble(),
    json['slotStartTime'],
    json['slotEndTime'],
    json['slotDate'],
    json['orderStatus'] as String,
    (json['items'] as List)
        ?.map(
            (e) => e == null ? null : Item.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['address'] == null
        ? null
        : UserAddress.fromJson(json['address'] as Map<String, dynamic>),
    json['homeDeliveryToUser'] as bool,
  )
    ..orderId = json['orderId'] as String
    ..deliveryBoy = json['deliveryBoy'] == null
        ? null
        : VendorDeliveryBoy.fromJson(
            json['deliveryBoy'] as Map<String, dynamic>);
}

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderId': instance.orderId,
      'userId': instance.userId,
      'vendorId': instance.vendorId,
      'shopId': instance.shopId,
      'paymentType': instance.paymentType,
      'paymentTotal': instance.paymentTotal,
      'deliveryCharges': instance.deliveryCharges,
      'paymentPayable': instance.paymentPayable,
      'slotStartTime': instance.slotStartTime,
      'slotEndTime': instance.slotEndTime,
      'slotDate': instance.slotDate,
      'orderStatus': instance.orderStatus,
      'address': instance.address?.toJson(),
      'items': instance.items?.map((e) => e?.toJson())?.toList(),
      'homeDeliveryToUser': instance.homeDeliveryToUser,
      'deliveryBoy': instance.deliveryBoy?.toJson(),
    };
