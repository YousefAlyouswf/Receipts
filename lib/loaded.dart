import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:receipt/stores_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'database/db_helper.dart';
import 'models/receipt_model.dart';

class Loaded extends StatefulWidget {
  @override
  _LoadedState createState() => _LoadedState();
}

class _LoadedState extends State<Loaded> {
  List<ReceiptModel> stores = [];

  Map<String, double> dataMap;
  void fetchStore() async {
    final storeList = await DBHelper.getDataPie('receipts');
    setState(() {
      stores = storeList
          .map(
            (item) => ReceiptModel(
              store: item['store'],
              price: item['price'],
            ),
          )
          .toList();
    });
    List<String> stor = [];
    List<double> price = [];

    for (var i = 0; i < stores.length; i++) {
      stor.add(stores[i].store);
      price.add(double.parse(stores[i].price));
    }

    List<double> newPrice = [];
    List<String> newStore = [];
    for (var i = 0; i < stor.length; i++) {
      bool x = newStore.contains(stor[i]);
      if (!x) {
        newStore.add(stor[i]);
        double x = 0;
        for (var j = 0; j < stor.length; j++) {
          if (stor[i] == stor[j]) {
            x += price[j];
          }
        }
        newPrice.add(x);
      }
    }

    for (var i = 0; i < newStore.length; i++) {
      dataMap.putIfAbsent(newStore[i], () => newPrice[i]);
    }
  }

  void setUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('uuid') == null) {
      try {
        var uuid = Uuid();
        String uid = uuid.v1();
        String shortUid = uid.substring(0, 8);

        String url = "https://receipt-49fc2.firebaseio.com/$shortUid.json";
        final responce = await http.get(url);
        final data = json.decode(responce.body) as Map<String, dynamic>;
        if (data == null) {
          prefs.setString('uuid', shortUid);
        } else {
          setUserId();
        }
      } catch (e) {}
    }
  }

  @override
  void initState() {
    super.initState();
    dataMap = new Map();
    fetchStore();
    setUserId();
  }

  Widget waitLoaded() {
    if (stores.length > 0) {
      print('not Empty');
    } else {
      return StoresScreen(
        dataMap: dataMap,
      );
    }
    if (dataMap.isNotEmpty) {
      return StoresScreen(
        dataMap: dataMap,
      );
    } else {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: LinearProgressIndicator(
              value: 0.5,
              backgroundColor: Colors.red[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return waitLoaded();
  }
}
