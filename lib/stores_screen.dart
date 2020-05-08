import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/friends_model.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:receipt/receipt_screen.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:receipt/show_other_receipt/show_receipts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_new_receipt.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class StoresScreen extends StatefulWidget {
  final Map<String, double> dataMap;

  const StoresScreen({Key key, this.dataMap}) : super(key: key);
  @override
  _StoresScreenState createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  List<ReceiptModel> stores = [];
  var map = Map();
  Future<void> fetchStore() async {
    final storeList = await DBHelper.getData('receipts', '');
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

    print(store);

    

    store.forEach((element) {
      if (!map.containsKey(element)) {
        map[element] = 1;
      } else {
        map[element] += 1;
      }
    });

    print(map['يوسف']);
  }

  List<Color> colorList;
  @override
  void initState() {
    super.initState();
    fetchStore();
    countTheReceipts();
    colorList = [
      Color(0xFF0B84A5),
      Color(0xFFF6C85F),
      Color(0xFF6F4E7C),
      Color(0xFF9DD866),
      Color(0xFFCA472F),
      Color(0xFFFFA056),
      Color(0xFF8DDDD0),
      Color(0xFFF7DC6F),
      Color(0xFFA2D9CE),
      Color(0xFFEDBB99),
      Color(0xFFcddaab),
      Color(0xFF7cae0f),
      Color(0xFF2e84d5),
      Color(0xFFe88b4b),
    ];
  }

  void _showDialog(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    TextEditingController codeText = TextEditingController();
    TextEditingController friendName = TextEditingController();

    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (id == 0) {
          return AlertDialog(
            title: new Text(
              "رقم عرض الفواتير",
              textDirection: TextDirection.rtl,
            ),
            content: Text(
              prefs.getString('uuid'),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("إلغاء"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text("نسخ"),
                onPressed: () {
                  Clipboard.setData(
                      new ClipboardData(text: prefs.getString('uuid')));
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                      msg: "تم النسخ",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0);
                },
              ),
            ],
          );
        } else if (id == 1) {
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
                  onPressed: () {
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
        } else {
          return null;
        }
      },
    );
  }

  List<String> services = [
    'عرض الرقم',
    'فواتير صديق جديد',
    'فواتير أصدقاء مخزنة',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("محفظتي"),
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: DrawerHeader(
          child: ListView.builder(
            itemCount: services.length,
            itemBuilder: (ctx, i) {
              return ListTile(
                onTap: () async {
                  if (i == 0) {
                    _showDialog(i);
                  } else if (i == 1) {
                    _showDialog(i);
                  } else if (i == 2) {
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
                      backgroundColor: Colors.white,
                      context: context,
                      builder: (context) => frindes.length == 0
                          ? Center(
                              child: Text(
                                "لا يوجد أصدقاء",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.black),
                              ),
                            )
                          : Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                itemCount: frindes.length,
                                itemBuilder: (ctx, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Card(
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
                                        subtitle: Text(
                                          frindes[index].code,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
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
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ShowReceipts(
                                                saved: true,
                                                textCode: frindes[index].code,
                                                name: frindes[index].name,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    );
                  }
                },
                title: Card(
                  color: Colors.white30,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      services[i],
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              );
            },
          ),
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
            heroTag: "btn2",
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddNewReceipt()));
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
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
                    itemCount: stores.length,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
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
                                  storeName: stores[i].store,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(
                                    stores[i].store,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "الفواتير ${map[stores[i].store].toString()}",
                                textDirection: TextDirection.rtl,
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
    );
  }
}
