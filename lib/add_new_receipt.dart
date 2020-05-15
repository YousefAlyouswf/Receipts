import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:receipt/loaded.dart';
import 'database/db_helper.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'date_screen.dart';
import 'models/receipt_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gallery_saver/gallery_saver.dart';

class AddNewReceipt extends StatefulWidget {
  final String storeName;
  final String price;
  final String date;
  final File image;
  final String itemID;
  final Color color;
  final int dateTime;

  const AddNewReceipt(
      {Key key,
      this.storeName,
      this.price,
      this.image,
      this.date,
      this.itemID,
      this.color,
      this.dateTime})
      : super(key: key);

  @override
  _AddNewReceiptState createState() => _AddNewReceiptState();
}

class _AddNewReceiptState extends State<AddNewReceipt> {
  var uuid = Uuid();
  String itemID;
  GlobalKey<AutoCompleteTextFieldState<String>> keyX = new GlobalKey();
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
    final storeList = await DBHelper.getData('receipts', '', null);
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

  static int currentTimeInSeconds() {
    var ms = (new DateTime.now()).millisecondsSinceEpoch;

    return (ms / 1000).round();
  }

  bool isEdited = false;
  @override
  void initState() {
    super.initState();
    fetchStore();

    if (widget.itemID != null) {
      _datePicked = widget.date;
      imageStored = widget.image;
      controllerName.text = widget.storeName;
      controllerPrice.text = widget.price;
      itemID = widget.itemID;
      isEdited = true;
      _dateTimePicked = widget.dateTime;
    } else if (widget.storeName != null) {
      controllerName.text = widget.storeName;
      itemID = uuid.v1();
    } else {
      itemID = uuid.v1();
    }
  }

  String _datePicked;
  int _dateTimePicked;
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
          _dateTimePicked = date.millisecondsSinceEpoch;
          _dateTimePicked = (_dateTimePicked / 1000).round();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "أدخل الفاتورة",
          style: Theme.of(context).textTheme.headline1,
        ),
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
                                      key: keyX,
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
                            //------Here pick a date
                            FlatButton.icon(
                              onPressed: _presentDatePicker,
                              icon: Icon(Icons.calendar_today),
                              label: Text(
                                _datePicked == null ? 'التاريخ' : _datePicked,
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            //-----------------
                            FlatButton(
                              onPressed: () async {
                                if (controllerName.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "أسم المتجر",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else if (controllerPrice.text.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg: "إجمالي الفاتورة",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                } else {
                                  if (controllerName.text.length > 16) {
                                    Fluttertoast.showToast(
                                        msg: "أسم المتجر أكثر من 15 حرف",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    return;
                                  }
                                  uploadImage();
                                  if (isEdited) {
                                    DBHelper.updateData(
                                        'receipts',
                                        {
                                          'store': controllerName.text,
                                          'price': controllerPrice.text,
                                          'image': imageStored.path,
                                          'date': _datePicked,
                                          'key': itemID,
                                          'dateTime': _dateTimePicked == null
                                              ? currentTimeInSeconds()
                                              : _dateTimePicked,
                                        },
                                        itemID);
                                  } else {
                                    currentTimeInSeconds();
                                    getDate().then((date) async {
                                      DBHelper.insert(
                                        'receipts',
                                        {
                                          'store': controllerName.text,
                                          'price': controllerPrice.text,
                                          'image': imageStored.path,
                                          'date': _datePicked == null
                                              ? date
                                              : _datePicked,
                                          'key': itemID,
                                          'dateTime': _dateTimePicked == null
                                              ? currentTimeInSeconds()
                                              : _dateTimePicked,
                                        },
                                      );
                                    }).catchError((onError) {
                                      print(onError);
                                    });
                                  }

                                  if (widget.color == null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Loaded()),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReceiptScreen(
                                          storeName: controllerName.text,
                                          color: widget.color,
                                        ),
                                      ),
                                    );
                                  }

                                  Fluttertoast.showToast(
                                      msg: "تم حفظ الفاتورة",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: Container(
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: new BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  width: MediaQuery.of(context).size.width / 2,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: Center(
                                    child: Text(
                                      'تخزين',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Text(
                          "أدخل صورة الفاتورة",
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
      getDate().then((date) async {
        if (isEdited) {
          print('--->>>>>>$_dateTimePicked');
          //Delete
          String userID = prefs.getString('uuid');
          String url =
              "https://receipt-49fc2.firebaseio.com/$userID/${widget.storeName}.json";
          final responce = await http.get(url);
          final data = json.decode(responce.body) as Map<String, dynamic>;
          List<ReceiptModel> testModel = [];
          data.forEach((key, value) {
            if (value['id'] == widget.itemID) {
              testModel.add(ReceiptModel(
                key: key,
                price: value['price'],
                date: value['date'],
                itemID: value['id'],
              ));
            }
          });
          String key = testModel[0].key;

          String urlForDelete =
              "https://receipt-49fc2.firebaseio.com/$userID/${widget.storeName}/$key.json";
          await http.delete(
            urlForDelete,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );
          //End delete
          String urlPost =
              "https://receipt-49fc2.firebaseio.com/$userID/${controllerName.text}.json";
          http.post(
            urlPost,
            body: json.encode(
              {
                'store': controllerName.text,
                'price': controllerPrice.text,
                'image': urlImage,
                'date': _datePicked == null ? date : _datePicked,
                'id': itemID,
                'dateTime': _dateTimePicked == null
                    ? currentTimeInSeconds()
                    : _dateTimePicked,
              },
            ),
          );
        } else {
          if (prefs.getString('uuid') == null ||
              prefs.getString('uuid') == '') {
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
                  'date': _datePicked == null ? date : _datePicked,
                  'id': itemID,
                  'dateTime': _dateTimePicked == null
                      ? currentTimeInSeconds()
                      : _dateTimePicked,
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
                  'date': _datePicked == null ? date : _datePicked,
                  'id': itemID,
                  'dateTime': _dateTimePicked == null
                      ? currentTimeInSeconds()
                      : _dateTimePicked,
                },
              ),
            );
          }
        }
      });
    }
  }
}