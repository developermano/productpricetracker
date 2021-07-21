import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:product_price_notify/localdb/model.dart';
import 'package:product_price_notify/popscreen.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(DataAdapter());
  await Hive.openBox('product');

  runApp(MaterialApp(
    home: Firstscreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class Firstscreen extends StatefulWidget {
  @override
  _FirstscreenState createState() => _FirstscreenState();
}

class _FirstscreenState extends State<Firstscreen> {
  double productprice;
  BannerAd myBanner;
  bool isloaded;
  @override
  void initState() {
    super.initState();
    myBanner = BannerAd(
      adUnitId: "ca-app-pub-6812988945725571/4918663224",
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(onAdLoaded: (_) {
        setState(() {
          isloaded = true;
        });
      }, onAdFailedToLoad: (_, error) {
        print(error);
      }),
    );

    myBanner.load();
  }

  Widget ad() {
    if (isloaded == true) {
      return Container(
          alignment: Alignment.center,
          child: AdWidget(ad: myBanner),
          width: myBanner.size.width.toDouble(),
          height: myBanner.size.height.toDouble());
    } else {
      return Text('ad');
    }
  }

  void dispose() {
    myBanner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('product price drop notify'),
      ),
      body: FutureBuilder(
        future: Hive.openBox('product'),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError)
            return Center(child: Text(snapshot.error.toString()));
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'no data found',
                style: TextStyle(fontSize: 30),
              ),
            );
          } else {
            return buildlist();
          }
        },
      ),
      bottomNavigationBar: ad(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_circle),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Popscreen()));
        },
      ),
    );
  }

  Widget buildlist() {
    final box = Hive.box('product');
    return WatchBoxBuilder(
        box: box,
        builder: (context, box) {
          return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final data = box.getAt(index) as Data;
                return ListTile(
                  onTap: () async {
                    try {
                      var res = await http.get(Uri.parse(data
                          .producturl)); //url === https://www.amazon.in/New-Apple-iPhone-11-64GB/dp/B08L8CHS2X/ref=mp_s_a_1_1_sspa?dchild=1&keywords=iphone&qid=1623634884&sr=8-1-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUFJUU1QRFNaR0ZKRzkmZW5jcnlwdGVkSWQ9QTEwMTY5OThOWEVGMUxSQzhJWEwmZW5jcnlwdGVkQWRJZD1BMDQ4OTUyNTEzTzlTUTlHRlZVTUEmd2lkZ2V0TmFtZT1zcF9waG9uZV9zZWFyY2hfYXRmJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ==

                      var soup = Beautifulsoup(res.body);
                      var productpr =
                          soup.find_all('#priceblock_ourprice').first.text;

                      productprice = double.parse(
                          productpr.substring(2).replaceAll(',', ''));
                    } catch (e) {
                      print('used catch methoad');
                      if (e.toString().startsWith('Bad state')) {
                        Toast.show('it is not amazon url', context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                      }
                      if (e.toString().startsWith('SocketException')) {
                        Toast.show('can\'t add product while offline', context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                      } else {
                        Toast.show(e.toString(), context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
                      }
                      productprice = data.price;
                    }
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(data.producttitle),
                            content: Container(
                              height: 70,
                              child: Center(
                                  child: Text('new price : ' +
                                      productprice.toString())),
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('close'))
                            ],
                          );
                        });
                  },
                  title: Text(data.producttitle),
                  subtitle: Text(data.price.toString()),
                  leading: Icon(Icons.thumb_up_alt_outlined),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      box.deleteAt(index);
                    },
                  ),
                );
              });
        });
  }
}
