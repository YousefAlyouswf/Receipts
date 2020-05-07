import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:http/http.dart' as http;
import 'package:receipt/show_other_receipt/other_receipt.dart';

import '../loaded.dart';

class ShowReceipts extends StatefulWidget {
  final String textCode;
  ShowReceipts({Key key, this.textCode}) : super(key: key);

  @override
  _ShowReceiptsState createState() => _ShowReceiptsState();
}

class _ShowReceiptsState extends State<ShowReceipts> {
  List<ReceiptModel> receipts = [];

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
          price: value['price'],
          date: value['date'],
        ));
      });
      setState(() {
        receipts = testModel;
      });
    } catch (e) {
      Fluttertoast.showToast(
          msg: "خطأ في إدخال الكود",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.of(context).pop();
    }
  }

  List<Color> colorList;
  @override
  void initState() {
    super.initState();
    fetch();
    colorList = [
      Color(0xFF0B84A5),
      Color(0xFFF6C85F),
      Color(0xFF6F4E7C),
      Color(0xFF9DD866),
      Color(0xFFCA472F),
      Color(0xFFFFA056),
      Color(0xFF8DDDD0),
      Color(0xFFF7DC6F),
      Color(0xFFA2D9CE),
      Color(0xFFEDBB99),
      Color(0xFFcddaab),
      Color(0xFF7cae0f),
      Color(0xFF2e84d5),
      Color(0xFFe88b4b),
    ];
  }

  @override
  Widget build(BuildContext context) {
    fetch();
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
          title: Text('فواتير الغير'),
          centerTitle: true,
        ),
        body: GridView.builder(
          itemCount: receipts.length,
          gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, i) {
            return Container(
              decoration: new BoxDecoration(
                color: colorList[i],
                borderRadius: new BorderRadius.all(
                  Radius.circular(5),
                ),
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
                child: Center(
                  child: Text(
                    receipts[i].store,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
