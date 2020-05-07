import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:receipt/database/db_helper.dart';
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

  List<Color> colorList;
  @override
  void initState() {
    super.initState();
    fetchStore();
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

    if (prefs.getString('uuid') == null) {
      Fluttertoast.showToast(
          msg: "يجب تسجيل فاتورة",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
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
              content: TextField(
                controller: codeText,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowReceipts(
                            textCode: codeText.text,
                          ),
                        ),
                      );
                    }),
              ],
            );
          } else {
            return null;
          }
        },
      );
    }
  }

  List<String> services = ['عرض الرقم', 'فواتير صديق '];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("فواتيري"),
        centerTitle: true,
      ),
      endDrawer: Drawer(
        child: ListView.builder(
            itemCount: 2,
            itemBuilder: (ctx, i) {
              return ListTile(
                onTap: () {
                  if (i == 0) {
                    _showDialog(i);
                  } else if (i == 1) {
                    _showDialog(i);
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
            }),
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
                          color: Colors.transparent,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: PieChart(
                            dataMap: widget.dataMap,
                            colorList: colorList,
                            showLegends: false,
                            chartRadius: MediaQuery.of(context).size.width,
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
                            color: colorList[i],
                            borderRadius:
                                new BorderRadius.all(Radius.circular(5))),
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
                          child: Center(
                            child: Text(
                              stores[i].store,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
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
