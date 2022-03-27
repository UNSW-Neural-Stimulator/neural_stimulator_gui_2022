

import 'package:flutter/material.dart';
import "item_details.dart";
import 'item.dart';

class ItemListing extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HOME'),
        backgroundColor: Colors.grey[700],
      ),
      body: ListView(
        children: items.map((item) {
          return ListTile(
            title: Text(item.title),
            onTap: () {
              Navigator.push(
                context,
               MaterialPageRoute(
                  builder: (_) => ItemDetails(),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}