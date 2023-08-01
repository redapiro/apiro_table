import 'package:apiro_table/utils/common_methods.dart';
import 'package:flutter/material.dart';

class MapPopup extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  MapPopup({required this.data,required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Center(child: Text('${CommonMethods.capitalizeFirstLetter(title)} Field Metadata')),alignment: Alignment.center,
        content: SizedBox(width: MediaQuery.of(context).size.width *.70,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: data.entries.length,

            itemBuilder: (context, index) {
              var entry = data.entries.toList()[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        entry.key,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Text(
                      entry.value.join(',\n'),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
