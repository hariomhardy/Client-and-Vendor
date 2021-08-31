
import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category{
  String categoryName;
  String image;

  Category(this.categoryName, this.image);

  factory Category.fromJson(Map<String,dynamic> data) => _$CategoryFromJson(data);

  Map<String,dynamic> toJson() => _$CategoryToJson(this);

}