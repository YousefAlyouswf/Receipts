import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'loaded.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReceiptScreen extends StatefulWidget {
  final String storeName;

  ReceiptScreen({Key key, this.storeName}) : super(key: key);

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  List<ReceiptModel> receipts = [];
  List<String> dateList = [];
  var dateSort = [];
  double sumPrice = 0;
  Future<void> fetchReceipts() async {
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
            ),
          )
          .toList();
    });

    sumPrice = 0;
    for (var i = 0; i < receipts.length; i++) {
      sumPrice += double.parse(receipts[i].price);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReceipts();
  }

  void _showDialog(int id, String idFirebase) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "تأكيد الحذف",
            textDirection: TextDirection.rtl,
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog

            new FlatButton(
              child: new Text("إلغاء"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("حذف"),
              onPressed: () {
                deleteFromFirebase(idFirebase);
                DBHelper.deleteItem('receipts', id).then((value) {
                  if (receipts.length == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Loaded(),
                      ),
                    );
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void openImage(File image) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      elevation: 0,
      enableDrag: true,
      barrierColor: Colors.white,
      context: context,
      builder: (context) => PhotoView(
        imageProvider: FileImage(
          image,
        ),
      ),
    );
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

  String _datePicked;
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime.now(),
      cancelText: "إلغاء",
      confirmText: "تم",
      locale: Locale('ar', 'SA'),
    ).then((date) {
      if (date == null) {
        return;
      } else {
        setState(() {
          _datePicked = "${date.day}/${date.month}/${date.year}";
        });
      }
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
          title: Text(
            "${widget.storeName} ($sumPrice ريال) ",
            textDirection: TextDirection.rtl,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, bottom: 16.0, left: 32, right: 32),
              child: Container(
                width: double.infinity,
                //height: MediaQuery.of(context).size.height * 0.05,
                child: Card(
                  elevation: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Center(
                        child: Text(
                          _datePicked == null
                              ? 'لم يتم أختيار التاريخ'
                              : '$_datePicked',
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                     _datePicked == null?Text(''): IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red,),
                        onPressed: () {
                          setState(() {
                            _datePicked = null;
                          });
                        },
                      ),
                      FlatButton.icon(
                        onPressed: _presentDatePicker,
                        icon: Icon(Icons.calendar_today),
                        label: Text('التاريخ'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: receipts.length,
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
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
                        _showDialog(receipts[i].id, receipts[i].itemID);
                      },
                      onTap: () {
                        //   openImage(receipts[i].image);
                        Navigator.of(context).push(
                          new MaterialPageRoute<Null>(
                            builder: (BuildContext context) {
                              return Container(
                                color: Colors.transparent,
                                child: Dialog(
                                  child: Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    child: PhotoView(
                                      imageProvider: FileImage(
                                        receipts[i].image,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            fullscreenDialog: true,
                          ),
                        );
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
                          Container(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Text(
                                  " ${receipts[i].price} ريال",
                                  textDirection: TextDirection.rtl,
                                ),
                                Text(receipts[i].date),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
