import 'dart:async';
import "../data_provider.dart";
import 'package:provider/provider.dart';

import 'workspace.dart';
import 'package:flutter/material.dart';
import 'package:win_ble/win_ble.dart';

class FullPageLayout extends StatefulWidget {
  const FullPageLayout({Key? key}) : super(key: key);

  @override
  _FullPageLayoutState createState() => _FullPageLayoutState();
}

/*
The full page layout holds the list of devices and the homepage on the right
*/

class _FullPageLayoutState extends State<FullPageLayout> {
  bool isScanning = false;

  @override
  void initState() {
    final Data myProvider = Provider.of<Data>(context, listen: false);
    myProvider.initialiseBLE();

    super.initState();
  }

//check if the following can be removed
  String bleStatus = "";
  String bleError = "";
  String error = "none";
  bool connected = false;

  @override
  void dispose() {
    Provider.of<Data>(context, listen: false).disposeBLE();
    super.dispose();
  }

// ##END##
//////////////////////////////////

  Widget _buildFullPageLayout() {
    final Data myProvider = Provider.of<Data>(context, listen: true);
    List<BleDevice> devices = myProvider.getdevices;

    return Row(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Material(
              elevation: 4.0,
              child: Column(
                children: [
                  Container(
                    color: Colors.blue,
                    height: 60,
                    child: const Text("Available Devices",
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
                      itemCount: devices.length,
                      itemBuilder: (BuildContext context, int index) {
                        BleDevice device = devices[index];
                        return InkWell(
                                onTap: () async {
                                  myProvider.stopScanning();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => workspace(
                                              device: device,
                                            )),
                                  );
                                },
                                child: Card(
                                  child: ListTile(
                                      leading: Text(device.name.isEmpty
                                          ? "N/A"
                                          : device.name),
                                      title: Text(device.address),
                                      // trailing: Text(device.manufacturerData.toString()),
                                      subtitle: Text(
                                          "rssi : ${device.rssi} | AdvTpe : ${device.advType}")),
                                ),
                              );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50)),

                    onPressed: () {
                      // scans for an overall of 10 seconds, with
                      // "bursts" with durations starting from one seconds and increasing to 4
                      for (int i = 1; i <= 4; i += 1) {
                        myProvider.startScanning();
                        Timer(Duration(seconds: i), () {
                          myProvider.stopScanning();
                          if (devices != []) {
                            setState(() {});
                          }
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.bluetooth,
                      size: 24.0,
                    ),
                    label: Text('Scan for 10 seconds'), // <-- Text
                  ),
                ],
              )),
        ),
        // Flexible(
        //   flex: 2,
        //   child: Material(
        //       elevation: 4.0,
        //       child: Column(
        //         children: [
        //           Container(
        //             color: Colors.blue,
        //             height: 60,
        //             child: const Text("Connected Devices",
        //                 style: TextStyle(
        //                     color: Color.fromARGB(255, 255, 255, 255),
        //                     fontSize: 25,
        //                     fontFamily: 'Raleway',
        //                     fontWeight: FontWeight.w300)),
        //             alignment: Alignment.center,
        //           ),
        //           Flexible(
        //             flex: 1,
        //             child: ListView.builder(
        //                 itemCount: this.value,
        //                 itemBuilder: (context, index) {
        //                   return Item(index: index);
        //                 }),
        //           ),
        //         ],
        //       )),
        // ),
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
