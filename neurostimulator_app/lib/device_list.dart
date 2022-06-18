import 'package:flutter/material.dart';
import 'workspace.dart';

/*
This is a stateful widget that makes the scrollable list of devices on the side
*/

class DeviceList extends StatefulWidget {
  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  // value of the number of devices made in the list, all this should be 
  // eventually replaced to show device name when ble is implemented

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
            return Item(index: index);
          }),
          // this is a button to scan for devices
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Devices"),
              actions: [
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                      "Scan for devices\n (this adds a fake\n device for now)"),
                  onPressed: () {
                    _addItem();
                  },
                ),
              ],
            );
          },
        ),
        label: const Text('+ New Device'),
        backgroundColor: const Color.fromARGB(255, 21, 5, 243),
        tooltip: "Scan for nearby devices",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
/*
this is an item from the list, representing a device
*/ 
class Item extends StatelessWidget {
  Item({
    required this.index,
  });

  final int index;
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text("Device " + index.toString()),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return StatefulBuilder(builder: ((context, setState) {
                return const workspace();
              }));
            })));
  }
}
