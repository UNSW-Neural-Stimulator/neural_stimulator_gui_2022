import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:win_ble/win_ble.dart';

import '../../../providers/bluetooth_le_provider.dart';
import '../../../util/consts.dart';

class ConnectionBar extends StatefulWidget {
  final BleDevice device;
  const ConnectionBar({Key? key, required this.device}) : super(key: key);
  @override
  _ConnectionBarState createState() => _ConnectionBarState();
}

class _ConnectionBarState extends State<ConnectionBar> {
  late BleDevice device = widget.device;
  
  @override
  Widget build(BuildContext context) {
    final BluetoothLEProvider bluetoothLEProvider =
    Provider.of<BluetoothLEProvider>(context);

    return Row(
        children: [
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (await bluetoothLEProvider.connect(widget.device.address) == true) {
                  setState(() {});
                  bluetoothLEProvider.subsCribeToCharacteristic(
                      widget.device.address, SERVICE_UUID, NOTIFY_CHAR_UUID);
                  print('ready');
                  setState(() {bluetoothLEProvider.setConnected(true);});
                } else {
                  print("error on connection");
                }
              },
              icon: const Icon(
                Icons.bluetooth,
                size: 15.0,
              ),
              label: Text('Connect'), // <-- Text
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () async {
                if (await bluetoothLEProvider.disconnect(widget.device.address) ==
                    true) {
                  bluetoothLEProvider.unSubscribeToCharacteristic(
                      widget.device.address, SERVICE_UUID, NOTIFY_CHAR_UUID);
                  setState(() {});
                  print('disconnected');
                } else {
                  print("error on disconnection");
                }
              },
              icon: const Icon(
                Icons.bluetooth,
                size: 15.0,
              ),
              label: Text('Disconnect'), // <-- Text
            ),
          ),
          SizedBox(width: 20),

          ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    fixedSize: const Size(150, 40),
                  ),

                  onPressed: () {
                    // showDialog(
                    //     context: context,
                    //     builder: (BuildContext context) {
                    //       return AlertDialog(
                    //         title: Text('Presets: '),
                    //         content: presetContainer(),
                    //       );
                    //     });
                  },

                  icon: const Icon(
                    Icons.save,
                    size: 20.0,
                  ),
                  label: const Text('Presets',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400)), // <-- Text
                ),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      );
  }
}
