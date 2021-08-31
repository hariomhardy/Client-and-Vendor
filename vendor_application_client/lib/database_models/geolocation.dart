
import 'package:json_annotation/json_annotation.dart';

part 'geolocation.g.dart';

@JsonSerializable()
class Geolocation{
  String lat;
  String long;

  Geolocation(this.lat, this.long);

  factory Geolocation.fromJson(Map<String,dynamic> data) => _$GeolocationFromJson(data);

  Map<String,dynamic> toJson() => _$GeolocationToJson(this);

}