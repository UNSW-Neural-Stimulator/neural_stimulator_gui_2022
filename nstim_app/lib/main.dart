import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nstim_app/providers/bluetooth_le_provider.dart';
import 'package:nstim_app/providers/preset_provider.dart';
import 'package:nstim_app/providers/service_layer_provider.dart';
import 'package:provider/provider.dart';
import 'package:win_ble/win_ble.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: BluetoothLEProvider(),
        ),
        ChangeNotifierProvider.value(
          value: ServiceLayerProvider(),
        ),
        ChangeNotifierProvider.value(
          value: Presets(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'roboto',
          textTheme: const TextTheme(
              headline1: TextStyle(
                  color: Color.fromARGB(255, 0, 60, 109),
                  fontWeight: FontWeight.normal,
                  fontSize: 30),
              headline2: TextStyle(
                  color: Color.fromARGB(255, 0, 60, 109),
                  fontWeight: FontWeight.normal,
                  fontSize: 15)),
        ),
        //the following is to open the workspace without a connected device
        //  home: workspace(device: test_device)
        home: const HomePage(),
      ),
    );
  }
}
