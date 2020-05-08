import 'dart:io';

class ReceiptModel {
  final String key;
  final String itemID;
  final int id;
  final String store;
  final String price;
  final File image;
  final String date;
  final String onlineImage;
  final List<ReceiptModel> listModel;
  ReceiptModel({
    this.itemID,
    this.key,
    this.id,
    this.store,
    this.price,
    this.image,
    this.date,
    this.listModel,
    this.onlineImage,
  });
}
