import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:http/http.dart' as http;
import 'package:receipt/show_other_receipt/other_receipt.dart';

import '../loaded.dart';

class ShowReceipts extends StatefulWidget {
  final String textCode;
  final String name;
  final bool saved;
  ShowReceipts({Key key, this.textCode, this.name, this.saved})
      : super(key: key);

  @override
  _ShowReceiptsState createState() => _ShowReceiptsState();
}

class _ShowReceiptsState extends State<ShowReceipts> {
  List<ReceiptModel> receipts = [];
  var map = Map();
  void fetch() async {
    try {
      String url =
          "https://receipt-49fc2.firebaseio.com/${widget.textCode}.json";
      final responce = await http.get(url);
      final data = json.decode(responce.body) as Map<String, dynamic>;
      List<ReceiptModel> testModel = [];

      data.forEach((key, value) {
        testModel.add(ReceiptModel(
          store: key,
        ));
      });
      setState(() {
        receipts = testModel;
      });
      List<String> store = [];

      List<ReceiptModel> toGetAllReceipts = [];
      for (var i = 0; i < receipts.length; i++) {
        String url1 =
            "https://receipt-49fc2.firebaseio.com/${widget.textCode}/${receipts[i].store}.json";
        final responce1 = await http.get(url1);
        final data1 = json.decode(responce1.body) as Map<String, dynamic>;
        List<ReceiptModel> testModel1 = [];
        data1.forEach((key, value) {
          testModel1.add(ReceiptModel(
            store: value['store'],
          ));
        });
        setState(() {
          toGetAllReceipts = testModel1;
        });
        for (var j = 0; j < toGetAllReceipts.length; j++) {
          store.add(toGetAllReceipts[j].store);
        }
        toGetAllReceipts = [];
      }
      print(store);
      store.forEach((element) {
        if (!map.containsKey(element)) {
          map[element] = 1;
        } else {
          map[element] += 1;
        }
      });

      if (widget.saved) {
      } else {
        DBHelper.insertFriend(
          'friend',
          {
            'code': widget.textCode,
            'name': widget.name,
          },
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "المحفظة فارغة",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black12,
          textColor: Colors.red,
          fontSize: 24.0);
      Navigator.of(context).pop();
    }
  }

  List<Color> colorList;
  @override
  void initState() {
    super.initState();
    fetch();
    colorList = [
      Color(0xFFF7DC6F),
      Color(0xFFA2D9CE),
      Color(0xFFEDBB99),
      Color(0xFFcddaab),
      Color(0xFF7cae0f),
      Color(0xFF2e84d5),
      Color(0xFFe88b4b),
      Color(0xFF0B84A5),
      Color(0xFFF6C85F),
      Color(0xFF6F4E7C),
      Color(0xFF9DD866),
      Color(0xFFCA472F),
      Color(0xFFFFA056),
      Color(0xFF8DDDD0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Loaded(),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "محفظة ${widget.name}",
            textDirection: TextDirection.rtl,
          ),
          centerTitle: true,
        ),
        body: GridView.builder(
          itemCount: receipts.length,
          gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, i) {
            return Container(
              decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(Radius.circular(15)),
                image: DecorationImage(
                    colorFilter:
                        ColorFilter.mode(colorList[i], BlendMode.srcATop),
                    image: AssetImage(
                      'assets/images/wallet.png',
                    ),
                    fit: BoxFit.fitHeight),
              ),
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OtherReceipt(
                        storeName: receipts[i].store,
                        textCode: widget.textCode,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          receipts[i].store,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "الفواتير ${map[receipts[i].store]}",
                      textDirection: TextDirection.rtl,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
