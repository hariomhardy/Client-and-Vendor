
import 'package:json_annotation/json_annotation.dart';
import 'order.dart';
import 'user_address.dart';
import 'cart.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User{
  String userId;
  String name;
  String emailId;
  String password;
  String phoneNumber;
  String image;
  List<UserAddress> address;
  Cart cart;
  List<Order> orderPending;
  List<String> orders;

  User.create(this.name, this.emailId, this.password, this.phoneNumber,
      this.image, this.address);

  User.custom() ;

  User(this.userId,this.name, this.emailId, this.password, this.phoneNumber,
      this.image, this.address, this.cart, this.orderPending, this.orders);

  factory User.fromJson(Map<String,dynamic> data) => _$UserFromJson(data);

  Map<String,dynamic> toJson() => _$UserToJson(this);
}