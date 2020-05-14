import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:receipt/database/db_helper.dart';
import 'package:receipt/models/receipt_model.dart';

import '../add_new_receipt.dart';
import '../loaded.dart';

class GridViewDateScreen extends StatefulWidget {
  final List<ReceiptModel> itemList, receipts, selectedList;
  final Color color;
  final Function deleteFromFirebase, fetchReceipts;
  final String datePicked;
  final bool presstheSelect;
  const GridViewDateScreen(
    this.itemList,
    this.selectedList,
    this.color,
    this.receipts,
    this.deleteFromFirebase,
    this.fetchReceipts,
    this.datePicked,
    this.presstheSelect,
  );
  @override
  _GridViewDateScreenState createState() => _GridViewDateScreenState();
}

class _GridViewDateScreenState extends State<GridViewDateScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.itemList.length,
              gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, i) {
                return Container(
                  margin: EdgeInsets.all(10),
                  child: GridItem(
                    pressedTheSelect: widget.presstheSelect,
                    color: widget.color,
                    openImage: openImage,
                    item: widget.itemList[i],
                    isSelected: (bool value) {
                      setState(() {
                        if (value) {
                          widget.selectedList.add(widget.itemList[i]);
                        } else {
                          widget.selectedList.remove(widget.itemList[i]);
                        }
                      });
                    },
                    key: Key(
                      widget.itemList[i].id.toString(),
                    ),
                  ),
                );
              },
            ),
          ),
          widget.selectedList.length > 0 && widget.presstheSelect
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
                        for (var i = 0; i < widget.selectedList.length; i++) {
                          widget.deleteFromFirebase(
                              widget.selectedList[i].itemID);
                          DBHelper.deleteItem(
                              'receipts', widget.selectedList[i].id);
                        }
                        await widget.fetchReceipts(widget.datePicked);
                        if (widget.receipts.length == 0) {
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
    );
  }
}

class GridItem extends StatefulWidget {
  final Key key;
  final ReceiptModel item;
  final ValueChanged<bool> isSelected;
  final Function openImage;
  final Color color;
  final bool pressedTheSelect;
  GridItem(
      {this.item,
      this.isSelected,
      this.key,
      this.openImage,
      this.color,
      this.pressedTheSelect});

  @override
  _GridItemState createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    if (!widget.pressedTheSelect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          isSelected = false;
          widget.isSelected(isSelected);
        });
      });
    }
    return Container(
      decoration: new BoxDecoration(
        color: widget.color
            .withOpacity(isSelected && widget.pressedTheSelect ? 0.3 : 0.9),
        borderRadius: new BorderRadius.all(Radius.circular(10)),
      ),
      child: InkWell(
        onTap: () {
          if (widget.pressedTheSelect) {
            setState(() {
              isSelected = !isSelected;
              widget.isSelected(isSelected);
            });
          } else {
            widget.openImage(widget.item.image);
          }
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
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Center(
                        child: Text(
                          widget.item.date,
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
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
                  color: Colors.white,
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
                        color: widget.color,
                        dateTime: widget.item.dateTime,
                      ),
                    ),
                  );
                },
              ),
            ),
            widget.pressedTheSelect && !isSelected
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.check_circle,
                      ),
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          isSelected = !isSelected;
                          widget.isSelected(isSelected);
                        });
                      },
                    ),
                  )
                : Container(),
            isSelected && widget.pressedTheSelect
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.check_circle,
                      ),
                      color: Colors.red,
                      onPressed: () {
                        setState(() {
                          isSelected = !isSelected;
                          widget.isSelected(isSelected);
                        });
                      },
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
