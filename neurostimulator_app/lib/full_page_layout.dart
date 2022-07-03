import 'workspace.dart';
import 'device_list.dart';
import 'package:flutter/material.dart';

class FullPageLayout extends StatefulWidget {
  const FullPageLayout({Key? key}) : super(key: key);

  @override
  _FullPageLayoutState createState() => _FullPageLayoutState();
}

/*
The full page layout holds the list of devices and the homepage on the right
*/

class _FullPageLayoutState extends State<FullPageLayout> {
  int value = 0;
  _addItem() {
    setState(() {
      value = value + 1;
    });
  }

  Widget _buildFullPageLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
              elevation: 4.0,
              child: Column(
                children: [
                  Container(
                    color: Colors.blue,
                    height: 60,
                    child: const Text("Connected Devices",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.w300)),
                    alignment: Alignment.center,
                  ),
                  Flexible(
                    flex: 1,
                    child: ListView.builder(
                        itemCount: this.value,
                        itemBuilder: (context, index) {
                          return Item(index: index);
                        }),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50),
                        textStyle: const TextStyle(fontSize: 20)),
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
                    child: const Text('Enabled'),
                  ),
                ],
              )),
        ),
        Flexible(
          flex: 3,
          child: workspaceHome(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    content = _buildFullPageLayout();
    return Scaffold(
      body: content,
    );
  }
}
