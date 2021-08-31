import 'package:json_annotation/json_annotation.dart';
import 'address.dart';
import 'order.dart';


part 'deliveryBoy.g.dart';
@JsonSerializable(explicitToJson: true)
class VendorDeliveryBoy {
  String deliveryBoyId;
  String name;
  String emailId;
  String phoneNumber;
  String password;
  Address address;
  String image;
  List<String> orders;          //stores only order ID
  List<Order> ordersPending;   //current orders to delivered

  VendorDeliveryBoy.custom({this.name , this.phoneNumber , this.address , this.emailId} ) ;

  VendorDeliveryBoy(this.deliveryBoyId, this.name, this.emailId,
      this.phoneNumber, this.password, this.address, this.image,this.orders);

  factory VendorDeliveryBoy.fromJson(Map<String,dynamic> data) => _$VendorDeliveryBoyFromJson(data);

  Map<String,dynamic> toJson() => _$VendorDeliveryBoyToJson(this);

}