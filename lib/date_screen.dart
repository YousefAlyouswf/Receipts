import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'add_new_receipt.dart';
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
        fetchReceipts();
      }
    });
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
        ),
      );
    });
  }

  getSnackBar() {
    if (selectedList.length > 0) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Assign a GlobalKey to the Scaffold'),
        duration: Duration(days: 365),
      ));
    } else {}
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    fetchReceipts();
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNewReceipt(
                  storeName: widget.storeName,
                ),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "${widget.storeName} ($sumPrice ريال) ",
            textDirection: TextDirection.rtl,
          ),
          centerTitle: true,
        ),
        body: Container(
          color: Colors.green[50],
          child: Column(
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
                        _datePicked == null
                            ? Container()
                            : IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _datePicked = null;
                                  });
                                  fetchReceipts();
                                },
                              ),
                        Center(
                          child: Text(
                            _datePicked == null
                                ? 'لم يتم أختيار التاريخ'
                                : '$_datePicked',
                            textDirection: TextDirection.rtl,
                          ),
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
                  itemCount: itemList.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, i) {
                    return Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: GridItem(
                        openImage: openImage,
                        item: itemList[i],
                        isSelected: (bool value) {
                          setState(() {
                            if (value) {
                              selectedList.add(itemList[i]);
                            } else {
                              selectedList.remove(itemList[i]);
                            }
                          });
                        },
                        key: Key(
                          itemList[i].id.toString(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              selectedList.length > 0
                  ? Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: Colors.red,
                      child: IconButton(
                          icon: Icon(
                            Icons.delete_forever,
                            size: MediaQuery.of(context).size.height * 0.05,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            for (var i = 0; i < selectedList.length; i++) {
                              deleteFromFirebase(selectedList[i].itemID);
                              DBHelper.deleteItem(
                                  'receipts', selectedList[i].id);
                            }
                            await fetchReceipts();
                            if (receipts.length == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Loaded(),
                                ),
                              );
                            }
                          }),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class GridItem extends StatefulWidget {
  final Key key;
  final ReceiptModel item;
  final ValueChanged<bool> isSelected;
  final Function openImage;
  GridItem({this.item, this.isSelected, this.key, this.openImage});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.openImage(widget.item.image);
      },
      onLongPress: () {
        setState(() {
          isSelected = !isSelected;
          widget.isSelected(isSelected);
        });
      },
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              Expanded(
                child: Container(
                  child: Image.file(
                    widget.item.image,
                    fit: BoxFit.fill,
                    width: double.infinity,
                    color: Colors.black.withOpacity(isSelected ? 1 : 0),
                    colorBlendMode: BlendMode.color,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      " ${widget.item.price} ريال",
                      textDirection: TextDirection.rtl,
                    ),
                    Text(widget.item.date),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.blue,
              ),
              onPressed: () {
      
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNewReceipt(
                      storeName: widget.item.store,
                      price: widget.item.price,
                      date: widget.item.date,
                      image: widget.item.image,
                      itemID: widget.item.itemID,
                    ),
                  ),
                );
              },
            ),
          ),
          isSelected
              ? Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.red,
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
