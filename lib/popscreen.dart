import 'package:beautifulsoup/beautifulsoup.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:product_price_notify/localdb/db.dart';
import 'package:product_price_notify/localdb/model.dart';
import 'package:toast/toast.dart';

class Popscreen extends StatefulWidget {
  @override
  _PopscreenState createState() => _PopscreenState();
}

class _PopscreenState extends State<Popscreen> {
  final myController = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add data'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter amazon product url'),
            keyboardType: TextInputType.url,
            controller: myController,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
                height: 30,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      var res = await http.get(Uri.parse(myController
                          .text)); //url === https://www.amazon.in/New-Apple-iPhone-11-64GB/dp/B08L8CHS2X/ref=mp_s_a_1_1_sspa?dchild=1&keywords=iphone&qid=1623634884&sr=8-1-spons&psc=1&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUFJUU1QRFNaR0ZKRzkmZW5jcnlwdGVkSWQ9QTEwMTY5OThOWEVGMUxSQzhJWEwmZW5jcnlwdGVkQWRJZD1BMDQ4OTUyNTEzTzlTUTlHRlZVTUEmd2lkZ2V0TmFtZT1zcF9waG9uZV9zZWFyY2hfYXRmJmFjdGlvbj1jbGlja1JlZGlyZWN0JmRvTm90TG9nQ2xpY2s9dHJ1ZQ==

                      var soup = Beautifulsoup(res.body);
                      var producttd = soup('title').text;
                      var productpr =
                          soup.find_all('#priceblock_ourprice').first.text;

                      double productprice = double.parse(
                          productpr.substring(2).replaceAll(',', ''));

                      if (myController.text != '' &&
                          producttd != '' &&
                          productprice.toString() != '') {
                        Db().adddata(
                            Data(myController.text, producttd, productprice));
                        Navigator.pop(context);
                      }
                    } catch (e) {
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
                    }
                  },
                  child: Text('add product'),
                  autofocus: true,
                )),
          )
        ],
      ),
    );
  }
}
