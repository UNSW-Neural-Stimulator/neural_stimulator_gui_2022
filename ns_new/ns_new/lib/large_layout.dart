import 'item.dart';
import 'item_details.dart';
import 'list_item.dart';
import 'package:flutter/material.dart';

class MasterDetailContainer extends StatefulWidget {
  const MasterDetailContainer({Key? key}) : super(key: key);

  @override
  _ItemMasterDetailContainerState createState() =>
      _ItemMasterDetailContainerState();
}

class _ItemMasterDetailContainerState extends State<MasterDetailContainer> {

  Widget _buildLargeLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
            elevation: 4.0,
            child: ItemListing(),
            ),
          ),
      
        Flexible(
          flex: 3,
          child: ItemDetails(),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
     content = _buildLargeLayout();
     return Scaffold(
        body: content,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                // Retrieve the text the that user has entered by using the
                // TextEditingController.
                content: Text("this should popup into a list of detected BLE devices"),
              );
            },
          );
          },
          label: const Text('+ New Device'),
          backgroundColor: const Color.fromARGB(255, 21, 5, 243),
          tooltip: "Scan for nearby devices",
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}