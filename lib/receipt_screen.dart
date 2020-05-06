import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'loaded.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
    final dataList = await DBHelper.getData('receipts', widget.storeName);
    setState(() {
      receipts = dataList
          .map(
            (item) => ReceiptModel(
              id: item['id'],
              store: item['store'],
              price: item['price'],
              image: File(item['image']),
              date: item['date'],
            ),
          )
          .toList();
    });

    dateList = [];
    dateSort = [];
    for (var i = 0; i < receipts.length; i++) {
      dateList.add(receipts[i].date);
    }
    dateSort = dateList.toSet().toList();

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

  void _showDialog(int id) {
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
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
        color: Colors.red,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: PhotoView(
          imageProvider: FileImage(
            image,
          ),
        ),
      ),
    );
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
                  child: Center(
                      child: Text(
                    '$sumPrice ريال ',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )),
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
                        _showDialog(receipts[i].id);
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
