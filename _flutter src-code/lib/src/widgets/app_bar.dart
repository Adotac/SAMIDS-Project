import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:samids_web_app/src/constant/extentions.dart';

class LocalAppBar extends StatefulWidget {
  LocalAppBar({
    Key? key,
    required this.pageTitle,
  }) : super(key: key);

  final String pageTitle;

  @override
  State<LocalAppBar> createState() => _LocalAppBarState();
}

class _LocalAppBarState extends State<LocalAppBar> {
  DateTime _dateTime = DateTime.now();
  void _showDatePicker(context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: 60,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                widget.pageTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: _dateTime,
                    firstDate: DateTime(2022),
                    lastDate: DateTime.now(),
                  ).then((value) {
                    setState(() {
                      if (value == null) {
                        return;
                      }
                      _dateTime = value;
                    });
                  });
                },
                icon: const Icon(Icons.edit_calendar_outlined),
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.only(
                    // left: 5.0,
                    right: 18,
                    top: 18,
                    bottom: 18,
                  ),
                  child: Text(
                    formatDate(_dateTime, [MM, ' ', dd, ', ', yyyy])
                        .capitalize(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            Theme.of(context).textTheme.titleMedium?.fontSize),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
