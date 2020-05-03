import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:receipt/receipt_screen.dart';

import 'add_new_receipt.dart';

class StoresScreen extends StatefulWidget {
  @override
  _StoresScreenState createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  List<ReceiptModel> stores = [];
  Future<void> fetchStore() async {
    final storeList = await DBHelper.getData('receipts', '');
    setState(() {
      stores = storeList
          .map((item) => ReceiptModel(
                store: item['store'],
              ))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fetchStore();
    return Scaffold(
      appBar: AppBar(
        title: Text("المحلات"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddNewReceipt()));
            },
          ),
        ],
      ),
      body: GridView.builder(
        itemCount: stores.length,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptScreen(
                      storeName: stores[i].store,
                    ),
                  ),
                );
              },
              child: Center(
                child: Text(
                  stores[i].store,
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
