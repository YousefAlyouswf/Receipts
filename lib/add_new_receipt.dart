import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receipt/loaded.dart';
import 'database/db_helper.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

import 'models/receipt_model.dart';

class AddNewReceipt extends StatefulWidget {
  @override
  _AddNewReceiptState createState() => _AddNewReceiptState();
}

class _AddNewReceiptState extends State<AddNewReceipt> {
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  File imageStored;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  _takePicture() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      preferredCameraDevice: CameraDevice.rear,
    );
    setState(() {
      imageStored = imageFile;
    });
  }

  _takeFromGalary() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    setState(() {
      imageStored = imageFile;
    });
  }

  Future<String> getDate() async {
    var now = new DateTime.now();
    String dateReceipt = '${now.day}/${now.month}/${now.year}';
    return dateReceipt;
  }

  List<ReceiptModel> storesModels = [];
  List<String> stores = [];
  Future<void> fetchStore() async {
    final storeList = await DBHelper.getData('receipts', '');
    setState(() {
      storesModels = storeList
          .map(
            (item) => ReceiptModel(
              store: item['store'],
            ),
          )
          .toList();
    });
    for (var i = 0; i < storesModels.length; i++) {
      stores.add(storesModels[i].store);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStore();
  }

  bool visiable = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("أدخل الفاتورة"),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        onPressed: _takePicture,
                        icon: Icon(Icons.camera),
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        onPressed: _takeFromGalary,
                        icon: Icon(Icons.image),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: imageStored != null
                    ? SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 6,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Image.file(
                                  imageStored,
                                  fit: BoxFit.fill,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: TextField(
                                      controller: controllerPrice,
                                      keyboardType: TextInputType.number,
                                      textDirection: TextDirection.rtl,
                                      decoration: InputDecoration(
                                        labelText: 'ر.س',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: SimpleAutoCompleteTextField(
                     
                                      
                                      key: key,
                                      controller: controllerName,
                                      suggestions: stores,
                                      decoration: InputDecoration(
                                          labelText: 'المتجر',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            FlatButton(
                              onPressed: () {
                                print("--->>${key.currentContext}");
                                if (controllerName.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "أسم المتجر",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else if (controllerPrice.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "إجمالي الفاتورة",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  getDate().then((date) {
                                    DBHelper.insert(
                                      'receipts',
                                      {
                                        'store': controllerName.text,
                                        'price': controllerPrice.text,
                                        'image': imageStored.path,
                                        'date': '4/5/2020',
                                      },
                                    );
                                  });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Loaded(),
                                    ),
                                  );
                                  Fluttertoast.showToast(
                                      msg: "تم حفظ الفاتورة",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.green,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              },
                              child: Text('تخزين'),
                            ),
                          ],
                        ),
                      )
                    : Text(""),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
