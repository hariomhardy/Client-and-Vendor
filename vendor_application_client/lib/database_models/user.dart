
import 'package:json_annotation/json_annotation.dart';
import 'order.dart';
import 'user_address.dart';
import 'cart.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class Users{
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

  Users.create({this.name, this.emailId, this.password, this.phoneNumber} );

  Users.custom() ;

  Users(this.userId,this.name, this.emailId, this.password, this.phoneNumber,
      this.image, this.address, this.cart, this.orderPending, this.orders);

  factory Users.fromJson(Map<String,dynamic> data) => _$UsersFromJson(data);

  Map<String,dynamic> toJson() => _$UsersToJson(this);
}