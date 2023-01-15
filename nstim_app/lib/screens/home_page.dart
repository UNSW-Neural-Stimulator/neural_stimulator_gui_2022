import 'dart:async';

import '../widgets/homeWidgets/home_display.dart';
import 'package:flutter/material.dart';
import 'package:win_ble/win_ble.dart';

import 'package:provider/provider.dart';
import '../providers/bluetooth_le_provider.dart';
import 'workspace.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  bool isScanning = false;

  @override
  void initState() {
    final BluetoothLEProvider bluetoothProvider = Provider.of<BluetoothLEProvider>(context, listen: false);
    bluetoothProvider.initialiseBLE();
    super.initState();
  }

//check if the following can be removed
  String bleStatus = "";
  String bleError = "";
  String error = "none";
  bool connected = false;

  @override
  void dispose() {
    Provider.of<BluetoothLEProvider>(context, listen: false).disposeBLE();
    super.dispose();
  }

// ##END##
//////////////////////////////////

  Widget _buildFullPageLayout() {
    final BluetoothLEProvider bluetoothProvider = Provider.of<BluetoothLEProvider>(context, listen: true);
    List<BleDevice> devices = bluetoothProvider.getdevices;

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
                                  bluetoothProvider.stopScanning();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Workspace(
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
                        bluetoothProvider.startScanning();
                        setState(() {bluetoothProvider.resetDevices();});
                        Timer(Duration(seconds: i), () {
                          bluetoothProvider.stopScanning();
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

        Flexible(
          flex: 3,
          child: homeDisplay(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildFullPageLayout(),
    );
  }
}


