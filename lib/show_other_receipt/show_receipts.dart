import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:http/http.dart' as http;
import 'package:receipt/show_other_receipt/other_receipt.dart';

import '../loaded.dart';

class ShowReceipts extends StatefulWidget {
  final String textCode;
  final String name;
  final bool saved;
  final Map<String, double> dataMap;
  ShowReceipts({Key key, this.textCode, this.name, this.saved, this.dataMap})
      : super(key: key);

  @override
  _ShowReceiptsState createState() => _ShowReceiptsState();
}

class _ShowReceiptsState extends State<ShowReceipts> {
  List<ReceiptModel> receipts = [];
  List<Items> allItems = [];
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
      for (var i = 0; i < receipts.length; i++) {
        allItems.add(Items(receipts[i].store, map[receipts[i].store]));
      }

      allItems.sort((b, a) => a.count.compareTo(b.count));
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
      Color(0xFFe88b4b),
      Color(0xFF38085C),
      Color(0xFFA19600),
      Color(0xFF081C63),
      Color(0xFF9B6701),
      Color(0xFF013D73),
      Color(0xFF994F06),
      Color(0xFF006E6F),
      Color(0xFF972D1D),
      Color(0xFF006C3B),
      Color(0xFF8F0407),
      Color(0xFF3E7927),
      Color(0xFF69015A),
      Color(0xFFe88b4b),
      Color(0xFF38085C),
      Color(0xFFA19600),
      Color(0xFF081C63),
      Color(0xFF9B6701),
      Color(0xFF013D73),
      Color(0xFF994F06),
      Color(0xFF006E6F),
      Color(0xFF972D1D),
      Color(0xFF006C3B),
      Color(0xFF8F0407),
      Color(0xFF3E7927),
      Color(0xFF69015A),
      Color(0xFFe88b4b),
      Color(0xFF38085C),
      Color(0xFFA19600),
      Color(0xFF081C63),
      Color(0xFF9B6701),
      Color(0xFF013D73),
      Color(0xFF994F06),
      Color(0xFF006E6F),
      Color(0xFF972D1D),
      Color(0xFF006C3B),
      Color(0xFF8F0407),
      Color(0xFF3E7927),
      Color(0xFF69015A),
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
          backgroundColor: Colors.blue[800],
          title: Text(
            "محفظة ${widget.name}",
            style: Theme.of(context).textTheme.headline1,
            textDirection: TextDirection.rtl,
          ),
          centerTitle: true,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          heroTag: "btn1",
          onPressed: () {
            showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => Container(
                color: Colors.white54,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: PieChart(
                  chartLegendSpacing: 20,
                  dataMap: widget.dataMap,
                  colorList: colorList,
                  showLegends: true,
                  chartValueStyle: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
          child: Icon(Icons.pie_chart),
        ),
        body: allItems.length < 1
            ? Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: LinearProgressIndicator(),
                ),
              )
            : GridView.builder(
                itemCount: allItems.length,
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
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
                              storeName: allItems[i].storeName,
                              textCode: widget.textCode,
                              color: colorList[i],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(),
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              allItems[i].storeName,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2
                                  .copyWith(color: colorList[i]),
                            ),
                          ),
                          allItems[i].count == null
                              ? CircularProgressIndicator(
                                  backgroundColor: colorList[i],
                                )
                              : Text(
                                  "(${allItems[i].count})",
                                  textDirection: TextDirection.rtl,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .copyWith(color: colorList[i]),
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

class Items {
  final String storeName;
  final int count;

  Items(this.storeName, this.count);
}
