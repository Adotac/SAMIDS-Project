import 'package:flutter/material.dart';
import 'package:samids_web_app/src/widgets/title_medium_text.dart';

class CardSmall extends StatelessWidget {
  final String title;
  const CardSmall({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sampleListActivites = [
      TitleMediumText(
        title: title,
      ),
      for (int i = 0; i < 10; i++)
        // ignore: prefer_const_constructors
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: const ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 25,
            ),
            title: Text("Martin Erickson Lapetaje • Prog 1 - 2019"),
            subtitle: Text("12:11 On-Time"),
          ),
        ),
    ];
    
    return Flexible(
      flex: 1,
      child: Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ignore: prefer_const_literals_to_create_immutables
              children: sampleListActivites,
            ),
          ),
        ),
      ),
    );
  }
}
