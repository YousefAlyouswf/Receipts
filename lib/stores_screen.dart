import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/friends_model.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:receipt/date_screen.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:receipt/show_other_receipt/show_receipts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_new_receipt.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:http/http.dart' as http;

class StoresScreen extends StatefulWidget {
  final Map<String, double> dataMap;

  const StoresScreen({Key key, this.dataMap}) : super(key: key);
  @override
  _StoresScreenState createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  List<Items> allItems = [];
  List<ReceiptModel> stores = [];
  var map = Map();
  Future<void> fetchStore() async {
    final storeList = await DBHelper.getData('receipts', '', null);
    setState(() {
      stores = storeList
          .map(
            (item) => ReceiptModel(
              store: item['store'],
            ),
          )
          .toList();
    });
  }

  bool isPressed = false;
  List<ReceiptModel> receiptCount = [];
  Future<void> countTheReceipts() async {
    final storeList = await DBHelper.receiptCount('receipts');
    setState(() {
      receiptCount = storeList
          .map(
            (item) => ReceiptModel(
              store: item['store'],
            ),
          )
          .toList();
    });
    List<String> store = [];
    for (var i = 0; i < receiptCount.length; i++) {
      store.add(receiptCount[i].store);
    }

    store.forEach((element) {
      if (!map.containsKey(element)) {
        map[element] = 1;
      } else {
        map[element] += 1;
      }
    });

    for (var i = 0; i < stores.length; i++) {
      allItems.add(Items(stores[i].store, map[stores[i].store]));
    }

    allItems.sort((b, a) => a.count.compareTo(b.count));
  }

  List<Color> colorList;
  @override
  void initState() {
    super.initState();
    initUserID();
    fetchStore();
    countTheReceipts();
    colorList = [
      Color(0xFF69015A),
      Color(0xFF3E7927),
      Color(0xFF8F0407),
      Color(0xFFb3b300),
      Color(0xFF972D1D),
      Color(0xFF006E6F),
      Color(0xFF994F06),
      Color(0xFF013D73),
      Color(0xFF9B6701),
      Color(0xFF006C3B),
      Color(0xFF081C63),
      Color(0xFFA19600),
      Color(0xFF38085C),
      Color(0xFFe88b4b),
      Color(0xFF69015A),
      Color(0xFF3E7927),
      Color(0xFF8F0407),
      Color(0xFF006C3B),
      Color(0xFF972D1D),
      Color(0xFF006E6F),
      Color(0xFF994F06),
      Color(0xFF013D73),
      Color(0xFF9B6701),
      Color(0xFF081C63),
      Color(0xFFA19600),
      Color(0xFF38085C),
      Color(0xFFe88b4b),
      Color(0xFF69015A),
      Color(0xFF3E7927),
      Color(0xFF8F0407),
      Color(0xFF006C3B),
      Color(0xFF972D1D),
      Color(0xFF006E6F),
      Color(0xFF994F06),
      Color(0xFF013D73),
      Color(0xFF9B6701),
      Color(0xFF081C63),
      Color(0xFFA19600),
      Color(0xFF38085C),
      Color(0xFFe88b4b),
    ];
  }

  String userID = '';
  void initUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('uuid');
  }

  void _showDialog(int id) async {
    TextEditingController codeText = TextEditingController();
    TextEditingController friendName = TextEditingController();

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            "أدخل رقم الكود",
            textDirection: TextDirection.rtl,
          ),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                TextField(
                  textAlign: TextAlign.end,
                  controller: codeText,
                  decoration: new InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "رقم الكود",
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  textAlign: TextAlign.end,
                  controller: friendName,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(), hintText: "أسم الصديق"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("إلغاء"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
                child: new Text("عرض"),
                onPressed: () async {
                  if (codeText.text == '' || friendName.text == '') {
                    Fluttertoast.showToast(
                      msg: "يجب تعبئة الحقول",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    await fetchintoMap(codeText.text, context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowReceipts(
                          textCode: codeText.text,
                          name: friendName.text,
                          saved: false,
                        ),
                      ),
                    );
                  }
                }),
          ],
        );
      },
    );
  }

  void freindsFunction() async {
    List<Friends> frindes = [];
    final storeList = await DBHelper.getDataFriend('friend');
    setState(() {
      frindes = storeList
          .map(
            (item) => Friends(
              id: item['id'],
              name: item['name'],
              code: item['code'],
            ),
          )
          .toList();
    });
    showModalBottomSheet(
        isDismissible: true,
        elevation: 0,
        enableDrag: true,
        backgroundColor: Colors.white,
        context: context,
        builder: (context) => frindes.length == 0
            ? Center(
                child: Text(
                  "لا يوجد أصدقاء",
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ),
              )
            : StatefulBuilder(builder: (BuildContext context,
                StateSetter setState /*You can rename this!*/) {
                return Padding(
                  padding: const EdgeInsets.only(left: 50.0, right: 50.0),
                  child: isPressed
                        ? Container(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                    child: CircularProgressIndicator(),
                                    height: 100.0,
                                    width: 100.0,
                                  ),
                                  Text("جاري جلب البيانات")
                              ],
                            ),
                          ),
                        )
                        :  ListView.builder(
                          itemCount: frindes.length,
                          itemBuilder: (ctx, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                color: Colors.white54,
                                child: ListTile(
                                  title: Text(
                                    frindes[index].name,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Clipboard.setData(new ClipboardData(
                                              text: frindes[index].code));

                                          Fluttertoast.showToast(
                                              msg: "تم النسخ",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.grey,
                                              textColor: Colors.white,
                                              fontSize: 16.0);
                                        },
                                        icon: Icon(
                                          Icons.content_copy,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                      Text(
                                        frindes[index].code,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  leading: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () async {
                                      DBHelper.deleteFriend(
                                        'friend',
                                        frindes[index].id,
                                      );
                                    },
                                  ),
                                  onTap: () async {
                                    setState(() {
                                      isPressed = true;
                                    });
                                    // Navigator.pop(context);
                                    await fetchintoMap(
                                        frindes[index].code, context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowReceipts(
                                          saved: true,
                                          textCode: frindes[index].code,
                                          name: frindes[index].name,
                                          dataMap: dataMap,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                );
              }));
  }

  List<String> services = [
    'إظافة صديق',
    'قائمة الأصدقاء',
    'حول التطبيق',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          "محفظتي",
          style: Theme.of(context).textTheme.headline1,
        ),
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 6,
              child: UserAccountsDrawerHeader(
                accountName: Text(''),
                accountEmail: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(new ClipboardData(text: userID));

                          Fluttertoast.showToast(
                              msg: "تم النسخ",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.grey,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        },
                        icon: Icon(
                          Icons.content_copy,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        userID,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: services.length,
                itemBuilder: (ctx, i) {
                  return ListTile(
                    onTap: () async {
                      if (i == 0) {
                        _showDialog(i);
                      } else if (i == 1) {
                        Navigator.of(context).pop();
                        freindsFunction();
                      } else if (i == 2) {
                        TextStyle style = TextStyle(fontSize: 18);
                        showModalBottomSheet(
                            backgroundColor: Colors.white,
                            context: context,
                            builder: (context) => SingleChildScrollView(
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Center(
                                            child: Text(
                                              'تطبيق محفظتي',
                                              textDirection: TextDirection.rtl,
                                              style: style,
                                            ),
                                          ),
                                          Text(
                                            'يحفظ لك جميع فواتيرك ومشترياتك عن طريق تصوير الفاتورة وادخال اسم المتجر والسعر الاجمالي للفاتورة',
                                            textDirection: TextDirection.rtl,
                                            style: style,
                                          ),
                                          Text(
                                            'يسمح لك التطبيق بمشاركة فواتيرك و مشترياتك مع الاصدقاء والأهل',
                                            textDirection: TextDirection.rtl,
                                            style: style,
                                          ),
                                          Center(
                                            child: Text(
                                              'القائمة الجانبية',
                                              textDirection: TextDirection.rtl,
                                              style: style,
                                            ),
                                          ),
                                          Text(
                                            'عرض رقمك الخاص الذي يسمح لأصدقائك بالاطلاع على فواتيرك',
                                            textDirection: TextDirection.rtl,
                                            style: style,
                                          ),
                                          Text(
                                            'إظافة صديق عن طريق رقمه الظاهر في تطبيقه الخاص لإظافته في قائمتك والإطلاع على فواتيره بشكل مستمر',
                                            textDirection: TextDirection.rtl,
                                            style: style,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
                      }
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            services[i],
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        Icon(
                          i == 0
                              ? Icons.add
                              : i == 1 ? Icons.people : Icons.tablet_android,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => stores.length == 0
                      ? Center(
                          child: Text(
                          "لا توجد فواتير",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ))
                      : Container(
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
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: "btn3",
            onPressed: freindsFunction,
            child: Icon(Icons.people),
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddNewReceipt()));
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            widget.dataMap.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddNewReceipt()));
                      },
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height / 4,
                          width: MediaQuery.of(context).size.width / 2,
                          child: LiquidCircularProgressIndicator(
                            value: 0.25, // Defaults to 0.5.
                            valueColor: AlwaysStoppedAnimation(Colors.red),
                            backgroundColor: Colors.white,
                            borderColor: Colors.red,
                            borderWidth: 5.0,
                            direction: Axis.horizontal,
                            center: Text(
                              "إظافة فاتورة جديدة",
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                            itemCount: allItems.length,
                            gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3),
                            itemBuilder: (context, i) {
                              return Container(
                                decoration: new BoxDecoration(
                                  borderRadius:
                                      new BorderRadius.all(Radius.circular(15)),
                                  image: DecorationImage(
                                      colorFilter: ColorFilter.mode(
                                          colorList[i], BlendMode.srcATop),
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
                                        builder: (context) => ReceiptScreen(
                                          storeName: allItems[i].storeName,
                                          color: colorList[i],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                              .copyWith(
                                                color: colorList[i],
                                              ),
                                        ),
                                      ),
                                      Text(
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
          ],
        ),
      ),
    );
  }

  List<ReceiptModel> storesForMap = [];

  Map<String, double> dataMap;

  Future<void> fetchintoMap(String userid, BuildContext ctx) async {
    String url = "https://receipt-49fc2.firebaseio.com/$userid.json";
    final responce = await http.get(url);
    final data = json.decode(responce.body) as Map<String, dynamic>;
    List<String> storesFromFirebase = [];
    data.forEach((key, value) {
      storesFromFirebase.add(key);
    });

    List<ReceiptModel> toGetAllPrice = [];
    storesForMap = [];

    for (var i = 0; i < storesFromFirebase.length; i++) {
      String url1 =
          "https://receipt-49fc2.firebaseio.com/$userid/${storesFromFirebase[i]}.json";
      final responce1 = await http.get(url1);
      final data1 = json.decode(responce1.body) as Map<String, dynamic>;
      List<ReceiptModel> testModel1 = [];
      data1.forEach((key, value) {
        testModel1.add(ReceiptModel(
          store: value['store'],
          price: value['price'],
        ));
      });
      setState(() {
        toGetAllPrice = testModel1;
      });
      for (var j = 0; j < toGetAllPrice.length; j++) {
        storesForMap.add(ReceiptModel(
            store: toGetAllPrice[j].store, price: toGetAllPrice[j].price));
      }
      toGetAllPrice = [];
    }

    List<String> stor = [];
    List<double> price = [];

    for (var i = 0; i < storesForMap.length; i++) {
      stor.add(storesForMap[i].store);
      price.add(double.parse(storesForMap[i].price));
    }

    List<double> newPrice = [];
    List<String> newStore = [];
    for (var i = 0; i < stor.length; i++) {
      bool x = newStore.contains(stor[i]);
      if (!x) {
        newStore.add(stor[i]);
        double x = 0;
        for (var j = 0; j < stor.length; j++) {
          if (stor[i] == stor[j]) {
            x += price[j];
          }
        }
        newPrice.add(x);
      }
    }
    print(newStore);
    print(newPrice);
    dataMap = new Map();
    for (var i = 0; i < newStore.length; i++) {
      //dataMap.putIfAbsent(newStore[i], () => newPrice[i]);
      dataMap[newStore[i]] = newPrice[i];
    }
    print(dataMap);
  }
}

class Items {
  final String storeName;
  final int count;

  Items(this.storeName, this.count);
}
