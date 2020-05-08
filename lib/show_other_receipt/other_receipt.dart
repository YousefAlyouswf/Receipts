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
  const OtherReceipt({Key key, this.storeName, this.textCode})
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
      testModel.add(ReceiptModel(
        store: key,
        price: value['price'],
        date: value['date'],
        onlineImage: value['image'],
      ));
    });
    setState(() {
      receipts = testModel;
    });
    sumPrice = 0;
    for (var i = 0; i < receipts.length; i++) {
      sumPrice += double.parse(receipts[i].price);
    }
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
                    onLongPress: () async {
              

                      _save(receipts[i].onlineImage);
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
                                    imageProvider: NetworkImage(
                                      receipts[i].onlineImage,
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
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
    print(result);
  }
}
