import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:convert';

import 'package:receipt/models/receipt_model.dart';

class OtherReceipt extends StatefulWidget {
  final String storeName;
  final String textCode;
  final Color color;
  const OtherReceipt({Key key, this.storeName, this.textCode, this.color})
      : super(key: key);

  @override
  _OtherReceiptState createState() => _OtherReceiptState();
}

class _OtherReceiptState extends State<OtherReceipt> {
  List<ReceiptModel> receipts = [];
  double sumPrice = 0;
  void fetch() async {
    String url =
        "https://receipt-49fc2.firebaseio.com/${widget.textCode}/${widget.storeName}.json";
    final responce = await http.get(url);
    final data = json.decode(responce.body) as Map<String, dynamic>;
    List<ReceiptModel> testModel = [];
    data.forEach((key, value) {
      if (_datePicked == null) {
        testModel.add(ReceiptModel(
          store: key,
          price: value['price'],
          date: value['date'],
          onlineImage: value['image'],
          dateTime: value['dateTime'],
        ));
      } else {
        if (value['date'] == _datePicked) {
          testModel.add(ReceiptModel(
            store: key,
            price: value['price'],
            date: value['date'],
            onlineImage: value['image'],
            dateTime: value['dateTime'],
          ));
        }
      }
    });
    setState(() {
      receipts = testModel;
    });
    sumPrice = 0;
    for (var i = 0; i < receipts.length; i++) {
      sumPrice += double.parse(receipts[i].price);
    }
    receipts.sort((b, a) => a.dateTime.compareTo(b.dateTime));
    for (var i = 0; i < receipts.length; i++) {
      print(receipts[i].date);
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
        fetch();
      }
    });
  }

  void openImage(String image) {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      elevation: 0,
      enableDrag: true,
      barrierColor: Colors.white,
      context: context,
      builder: (context) => PhotoView(
        imageProvider: NetworkImage(
          image,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.color,
        title: Text(
          "${widget.storeName} ($sumPrice ريال) ",
          style: Theme.of(context).textTheme.headline1,
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
              child: Card(
                shadowColor: Theme.of(context).primaryColor,
                color: widget.color.withOpacity(0.3),
                elevation: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _datePicked == null
                        ? Container()
                        : IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _datePicked = null;
                              });
                              fetch();
                            },
                          ),
                    Center(
                      child: Text(
                        _datePicked == null
                            ? 'لم يتم أختيار التاريخ'
                            : '$_datePicked',
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                    FlatButton.icon(
                      onPressed: _presentDatePicker,
                      icon: Icon(Icons.calendar_today),
                      label: Text(
                        'التاريخ',
                        style: Theme.of(context).textTheme.headline3,
                      ),
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
                    borderRadius: new BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onLongPress: () async {
                      _save(receipts[i].onlineImage);
                    },
                    onTap: () {
                      openImage(receipts[i].onlineImage);
                    },
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            child: Image.network(
                              receipts[i].onlineImage,
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
    );
  }

  _save(String image) async {
    var response = await Dio()
        .get(image, options: Options(responseType: ResponseType.bytes));

    await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
  }
}
