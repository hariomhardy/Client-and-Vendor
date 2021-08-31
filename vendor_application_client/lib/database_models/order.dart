
import 'package:json_annotation/json_annotation.dart';
import 'package:vendor_application_client/database_models/deliveryBoy.dart';
import 'user_address.dart';
import 'item.dart';
part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order{
  String orderId;
  String userId;
  String vendorId;
  String shopId;
  String paymentType;
  double paymentTotal;
  double deliveryCharges;
  double paymentPayable;
  String slotStartTime;
  String slotEndTime;
  String slotDate;
  String orderStatus;
  UserAddress address;
  bool isRated;
  List<Item> items;
  bool homeDeliveryToUser ;
  VendorDeliveryBoy deliveryBoy;

  Order( this.userId, this.vendorId, this.shopId, this.paymentType,
      this.paymentTotal, this.deliveryCharges, this.paymentPayable,
      this.slotStartTime, this.slotEndTime, this.slotDate, this.orderStatus,this.items,this.address ,this.homeDeliveryToUser);

  Order.full( this.userId, this.vendorId, this.shopId, this.paymentType,
      this.paymentTotal, this.deliveryCharges, this.paymentPayable,
      this.slotStartTime, this.slotEndTime, this.slotDate, this.orderStatus,this.items,this.address ,this.homeDeliveryToUser,this.deliveryBoy);

  factory Order.fromJson(Map<String,dynamic> data) => _$OrderFromJson(data);

  Map<String,dynamic> toJson() => _$OrderToJson(this);

}