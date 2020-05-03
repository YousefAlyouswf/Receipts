import 'dart:io';

class ReceiptModel {
  final int id;
  final String store;
  final String price;
  final File image;
  final String date;

  ReceiptModel({
    this.id,
    this.store,
    this.price,
    this.image,
    this.date,
  });
}
