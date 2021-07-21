import 'package:hive/hive.dart';
import 'package:product_price_notify/localdb/model.dart';

class Db {
  void adddata(Data data) async {
    await Hive.openBox('product');
    var box = Hive.box('product');
    box.add(data);
  }

  void deletedata(int index) async {
    await Hive.openBox('product');
    var box = Hive.box('product');
    box.deleteAt(index);
  }
}
