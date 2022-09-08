import 'dart:ffi';
import 'dart:typed_data';

import 'package:ns_2022/pages/workspace.dart';

import 'data_provider.dart';
import 'package:provider/provider.dart';
import 'package:win_ble/win_ble.dart';
import 'pages/full_page_layout.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

// this is a fake ble device used for testing
// BleDevice test_device = BleDevice(address: 'address', name: "name", rssi: "idk", manufacturerData: Uint8List(4), serviceUuids: [], advType: 'poo', timestamp: 'like 10 0 clock', );

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Data (),
        ),
      ],
      child: MaterialApp (
              theme: ThemeData (
                          primarySwatch: Colors.blue,
                      ),
              //the following is to open the workspace without a connected device
              // home: workspace(device: test_device)
              home: const FullPageLayout(),

             ),
          ); 
  }
}