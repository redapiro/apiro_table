import 'package:flutter/material.dart';

class MapPopup extends StatelessWidget {
  final Map<String, dynamic> data;

  MapPopup({required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: Text('Meta Data'),
        content: SizedBox(width: MediaQuery.of(context).size.width *.70,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: data.entries.length,

            itemBuilder: (context, index) {
              var entry = data.entries.toList()[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.value.join(', '),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
