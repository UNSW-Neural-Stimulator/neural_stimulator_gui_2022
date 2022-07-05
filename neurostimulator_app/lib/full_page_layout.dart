import 'dart:async';

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
//////////////////////////////////
// ##Start##
// the following code was sourced from:

// Copyright (c) 2021 Rohit Sangwan
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

  StreamSubscription? scanStream;
  StreamSubscription? connectionStream;

  bool isScanning = false;

  @override
  void initState() {
    WinBle.initialize(enableLog: true);
    // call winBLe.dispose() when done
    connectionStream = WinBle.connectionStream.listen((event) {
      print("Connection Event : " + event.toString());
    });

    // Listen to Scan Stream , we can cancel in onDispose()
    scanStream = WinBle.scanStream.listen((event) {
      setState(() {
        if (!devices.any((element) => element.address == event.address)) {
          devices.add(event);
        }
      });
    });
    super.initState();
  }

  String bleStatus = "";
  String bleError = "";
  String error = "none";
  bool connected = false;
  bool notloading = true;

  List<BleDevice> devices = <BleDevice>[];

  /// Main Methods
  ///
  void showSuccess(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.green,
          duration: Duration(milliseconds: 300)));

  void showError(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 300)));

  connect(BleDevice device) async {
    final address = device.address;
    setState(() {
      notloading = false;
    });
    try {
      await WinBle.connect(address);
      showSuccess("Connected");
      notloading = true;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => workspace(
                  device: device,
                )),
      );
    } catch (e) {
      setState(() {
        notloading = true;

        error = e.toString();
        showError(error);
      });
    }
  }

  startScanning() {
    WinBle.startScanning();
    setState(() {
      isScanning = true;
    });
  }

  stopScanning() {
    WinBle.stopScanning();
    setState(() {
      isScanning = false;
    });
  }

  @override
  void dispose() {
    scanStream?.cancel();
    connectionStream?.cancel();
    super.dispose();
  }

// ##END##
//////////////////////////////////

  Widget _buildFullPageLayout() {
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
                        return notloading
                            ? InkWell(
                                onTap: () async {
                                  stopScanning();
                                  await connect(device);
                                  WinBle.connectionStreamOf(device.address)
                                      .listen((event) {
                                    if (event) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => workspace(
                                                  device: device,
                                                )),
                                      );
                                    }
                                  });
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
                              )
                            : CircularProgressIndicator();
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(50)),

                    onPressed: () {
                      startScanning();
                      Timer(Duration(seconds: 10), () {
                        stopScanning();
                      });
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

/*
this is an item from the list, representing a device
*/
// class Item extends StatelessWidget {
//   Item({
//     required this.index,
//   });

//   final int index;
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//         title: Text("Device " + index.toString()),
//         onTap: () =>
//             Navigator.push(context, MaterialPageRoute(builder: (context) {
//               return StatefulBuilder(builder: ((context, setState) {
//                 return const workspace();
//               }));
//             })));
//   }
// }
