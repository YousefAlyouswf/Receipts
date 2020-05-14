import 'package:flutter/material.dart';

class PickDateWidget extends StatefulWidget {
  final Function fetchReceipts;
  final Color color;

  PickDateWidget(
    this.fetchReceipts,
    this.color,
  );

  @override
  _PickDateWidgetState createState() => _PickDateWidgetState();
}

class _PickDateWidgetState extends State<PickDateWidget> {
  String datePicked;
  void presentDatePicker() {
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
          datePicked = "${date.day}/${date.month}/${date.year}";
        });
        widget.fetchReceipts(datePicked);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 32, right: 32),
      child: Container(
        width: double.infinity,
        //height: MediaQuery.of(context).size.height * 0.05,
        child: Card(
          shadowColor: Theme.of(context).primaryColor,
          color: widget.color.withOpacity(0.3),
          elevation: 10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              datePicked == null
                  ? Container()
                  : IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          datePicked = null;

                          widget.fetchReceipts(datePicked);
                        });
                      },
                    ),
              Center(
                child: Text(
                  datePicked == null
                      ? 'أختر التاريخ لفرز الفواتير'
                      : '$datePicked',
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
              FlatButton.icon(
                onPressed: presentDatePicker,
                icon: Icon(Icons.calendar_today),
                label: Text(
                  'التاريخ',
                  style: Theme.of(context).textTheme.headline3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
