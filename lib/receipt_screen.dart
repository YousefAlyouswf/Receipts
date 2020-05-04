import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';

import 'loaded.dart';

class ReceiptScreen extends StatefulWidget {
  final String storeName;

  ReceiptScreen({Key key, this.storeName}) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  List<ReceiptModel> receipts = [];

  Future<void> fetchReceipts() async {
    final dataList = await DBHelper.getData('receipts', widget.storeName);
    setState(() {
      receipts = dataList
          .map((item) => ReceiptModel(
              id: item['id'],
              store: item['store'],
              price: item['price'],
              image: File(item['image']),
              date: item['date']))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    fetchReceipts();
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
          title: Text(widget.storeName),
        ),
        body: GridView.builder(
          itemCount: receipts.length,
          gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, i) {
            return Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: InkWell(
                onLongPress: () {
                  DBHelper.deleteItem('receipts', receipts[i].id).then((value) {
                     if (receipts.length == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Loaded(),
                      ),
                    );
                  }
                  });
                 
                },
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: Image.file(
                          receipts[i].image,
                          fit: BoxFit.fill,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Text(
                      " ${receipts[i].price} ريال",
                      textDirection: TextDirection.rtl,
                    ),
                    Text(receipts[i].date),
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
