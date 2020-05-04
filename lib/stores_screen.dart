import 'package:flutter/material.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';
import 'package:receipt/receipt_screen.dart';
import 'package:pie_chart/pie_chart.dart';
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
      Color(0xFFEBF60A),
      Color(0xFFFE3216),
      Color(0xFF58FF4A),
      Color(0xFF4AECFF),
      Color(0xFF7B87FF),
      Color(0xFFAFCEFF),
      Color(0xFFFFAFF9),
      Color(0xFFF7DC6F),
      Color(0xFFA2D9CE),
      Color(0xFFEDBB99),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("المتاجر"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddNewReceipt()));
            },
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
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width / 2,
                      child: LiquidCircularProgressIndicator(
                        value: 0.25, // Defaults to 0.5.
                        valueColor: AlwaysStoppedAnimation(Colors
                            .pink), // Defaults to the current Theme's accentColor.
                        backgroundColor: Colors
                            .white, // Defaults to the current Theme's backgroundColor.
                        borderColor: Colors.red,
                        borderWidth: 5.0,
                        direction: Axis
                            .horizontal, // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.vertical.
                        center: Text(
                          "إظافة فاتورة جديدة",
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                  ),
                )
              : PieChart(
                  dataMap: widget.dataMap,
                  colorList: colorList,
                ),
          Expanded(
            child: GridView.builder(
              itemCount: stores.length,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, i) {
                return Container(
                  color: colorList[i],
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
                        style: Theme.of(context).textTheme.bodyText1,
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
