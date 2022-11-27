import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'sample_item.dart';
import 'sample_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.black,
        elevation: 0,
        title: const Text(
          'SAMIDS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: const [],
      ),
      body: Row(children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.70,
          child: Container(
            color: Colors.red,
            child: Column(
              children: [
                SizedBox(
                  height: 400,
                  width: 450,
                  child: Card(
                    child: Text("Sign up"),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.blue,
            child: Column(
              children: [
                Text("data"),
                Text("data"),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
