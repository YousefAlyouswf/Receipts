import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:receipt/widgets/grid_view_date_screen.dart';
import 'package:receipt/widgets/pick_date.dart';
import 'add_new_receipt.dart';
import 'loaded.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptScreen extends StatefulWidget {
  final String storeName;
  final Color color;
  ReceiptScreen({Key key, this.storeName, this.color}) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  List<ReceiptModel> receipts = [];
  double sumPrice = 0;
  String _datePicked;
  Future<void> fetchReceipts(String _datePicked) async {
    final dataList =
        await DBHelper.getData('receipts', widget.storeName, _datePicked);
    setState(() {
      receipts = dataList
          .map(
            (item) => ReceiptModel(
              id: item['id'],
              store: item['store'],
              price: item['price'],
              image: File(item['image']),
              date: item['date'],
              itemID: item['key'],
              dateTime: item['dateTime'],
            ),
          )
          .toList();
    });

    sumPrice = 0;
    for (var i = 0; i < receipts.length; i++) {
      sumPrice += double.parse(receipts[i].price);
    }
    loadList();
  }

  Future<void> deleteFromFirebase(String itemID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('uuid');

    String urlget =
        "https://receipt-49fc2.firebaseio.com/$userID/${widget.storeName}.json";
    final responce = await http.get(urlget);
    final data = json.decode(responce.body) as Map<String, dynamic>;
    List<ReceiptModel> testModel = [];
    data.forEach((key, value) {
      testModel.add(ReceiptModel(
        key: key,
        price: value['price'],
        date: value['date'],
        itemID: value['id'],
      ));
    });
    for (var i = 0; i < testModel.length; i++) {
      if (testModel[i].itemID == itemID) {
        String key = testModel[i].key;
        String url =
            "https://receipt-49fc2.firebaseio.com/$userID/${widget.storeName}/$key.json";
        await http.delete(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
      }
    }
  }

  List<ReceiptModel> itemList = [];
  List<ReceiptModel> selectedList = [];
  bool isSelected = false;
  loadList() {
    itemList = List();
    selectedList = List();

    List.generate(receipts.length, (index) {
      itemList.add(
        ReceiptModel(
          store: receipts[index].store,
          image: receipts[index].image,
          price: receipts[index].price,
          date: receipts[index].date,
          itemID: receipts[index].itemID,
          id: receipts[index].id,
          selectID: index + 1,
          dateTime: receipts[index].dateTime,
        ),
      );
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    fetchReceipts(_datePicked);
  }

  bool presstheSelect = false;
  void pressToSelect() {
    setState(() {
      presstheSelect = !presstheSelect;
    });
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
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewReceipt(
                  storeName: widget.storeName,
                  color: widget.color,
                ),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: widget.color,
          title: Text(
            "${widget.storeName} ($sumPrice ريال) ",
            style: Theme.of(context).textTheme.headline1,
            textDirection: TextDirection.rtl,
          ),
          centerTitle: true,
          actions: [
            FlatButton(
              onPressed: pressToSelect,
              child: presstheSelect?
              Text(
                'إلغاء',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )
              : Text(
                'تحديد',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              PickDateWidget(fetchReceipts, widget.color),
              GridViewDateScreen(itemList, selectedList, widget.color, receipts,
                  deleteFromFirebase, fetchReceipts, _datePicked, presstheSelect)
            ],
          ),
        ),
      ),
    );
  }
}
