import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class Data extends HiveObject {
  @HiveField(0)
  String producturl;

  @HiveField(1)
  String producttitle;

  @HiveField(2)
  double price;

  Data(this.producturl, this.producttitle, this.price);
}
