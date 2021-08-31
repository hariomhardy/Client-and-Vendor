// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Users _$UsersFromJson(Map<String, dynamic> json) {
  return Users(
    json['userId'] as String,
    json['name'] as String,
    json['emailId'] as String,
    json['password'] as String,
    json['phoneNumber'] as String,
    json['image'] as String,
    (json['address'] as List)
        ?.map((e) =>
            e == null ? null : UserAddress.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['cart'] == null
        ? null
        : Cart.fromJson(json['cart'] as Map<String, dynamic>),
    (json['orderPending'] as List)
        ?.map(
            (e) => e == null ? null : Order.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    (json['orders'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$UsersToJson(Users instance) => <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'emailId': instance.emailId,
      'password': instance.password,
      'phoneNumber': instance.phoneNumber,
      'image': instance.image,
      'address': instance.address?.map((e) => e?.toJson())?.toList(),
      'cart': instance.cart?.toJson(),
      'orderPending': instance.orderPending?.map((e) => e?.toJson())?.toList(),
      'orders': instance.orders,
    };
