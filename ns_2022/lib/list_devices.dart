

import 'package:flutter/material.dart';
import 'workspace.dart';

class ItemListing extends StatefulWidget {
  @override
  _ItemListingState createState() => _ItemListingState();
}

class _ItemListingState extends State<ItemListing> {
  int value = 0;

  _addItem() {
    setState(() {
      value = value + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connected Devices"),
      ),
      body: ListView.builder(
          itemCount: this.value,
          itemBuilder: (context, index) {
            return Item(index: index              
            );
          }
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: _addItem,
              label: const Text('+ New Device'),
              backgroundColor: const Color.fromARGB(255, 21, 5, 243),
              tooltip: "Scan for nearby devices",
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }


}


class Item extends StatelessWidget{
  Item({
    required this.index,
  });

  final int index;
  @override
  Widget build(BuildContext context) {
     return ListTile(
                title: Text("Device " + index.toString()),
                onTap: () => Navigator.push(
                                          context,
                                              MaterialPageRoute(builder: (context) => workspace(deviceNumber: index)),
                                        )
      );
  }
}
