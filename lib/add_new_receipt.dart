import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receipt/loaded.dart';
import 'database/db_helper.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'models/receipt_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gallery_saver/gallery_saver.dart';

class AddNewReceipt extends StatefulWidget {
  @override
  _AddNewReceiptState createState() => _AddNewReceiptState();
}

class _AddNewReceiptState extends State<AddNewReceipt> {
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  File imageStored;
  String urlImage;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  _takePicture() async {
    ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      preferredCameraDevice: CameraDevice.rear,
    ).then((value) {
      if (value != null && value.path != null) {
        GallerySaver.saveImage(value.path, albumName: "فواتيري");
        setState(() {
          imageStored = value;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("أدخل الفاتورة"),
        centerTitle: true,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: _takeFromGalary,
            child: Icon(Icons.image),
          ),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: _takePicture,
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
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
                              onPressed: () async {
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
                                  uploadImage();
                                  getDate().then((date) async {
                                    DBHelper.insert(
                                      'receipts',
                                      {
                                        'store': controllerName.text,
                                        'price': controllerPrice.text,
                                        'image': imageStored.path,
                                        'date': date,
                                      },
                                    );
                                  }).catchError((onError) {
                                    print(onError);
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
                    : Center(
                        child: Text(
                          "أختر صورة الفاتورة",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future uploadImage() async {
    String fileName = '${DateTime.now()}.png';

    StorageReference firebaseStorage =
        FirebaseStorage.instance.ref().child(fileName);

    StorageUploadTask uploadTask = firebaseStorage.putFile(imageStored);
    await uploadTask.onComplete;
    urlImage = await firebaseStorage.getDownloadURL() as String;

    if (urlImage.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      getDate().then((date) {
        if (prefs.getString('uuid') == null || prefs.getString('uuid') == '') {
          var uuid = Uuid();
          prefs.setString('uuid', uuid.v1());
          String userID = prefs.getString('uuid');
          String url =
              "https://receipt-49fc2.firebaseio.com/$userID/${controllerName.text}.json";
          http.post(
            url,
            body: json.encode(
              {
                'store': controllerName.text,
                'price': controllerPrice.text,
                'image': urlImage,
                'date': date,
              },
            ),
          );
        } else {
          String userID = prefs.getString('uuid');
          String url =
              "https://receipt-49fc2.firebaseio.com/$userID/${controllerName.text}.json";
          http.post(
            url,
            body: json.encode(
              {
                'store': controllerName.text,
                'price': controllerPrice.text,
                'image': urlImage,
                'date': date,
              },
            ),
          );
        }
      });
    }
  }
}
