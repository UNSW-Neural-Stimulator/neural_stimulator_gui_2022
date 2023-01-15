import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert';
import "dart:typed_data";
import 'dart:async';
import 'package:win_ble/win_ble.dart';
import 'package:provider/provider.dart';

class BluetoothLEProvider extends ChangeNotifier {



  /// The streams is where the device information from connections, scans and notifications are stored
  StreamSubscription? scanStream;
  StreamSubscription? connectionStream;
  StreamSubscription? characteristicValueStream;

  /// this is a list of devices that we are connected to, it is a subset of info from our connection stream
  /// We use this for most of the functions below
  List<BleDevice> devices = <BleDevice>[];

  /// get  and set functions to retrieve the connection, scan and notify characteristic streams these works the same as for the rest of our variables in the
  /// provider class
  StreamSubscription? get getScanStream {
    return scanStream;
  }

  StreamSubscription? get getConnnectionStream {
    return connectionStream;
  }

  StreamSubscription? get getcharacteristicValueStream {
    return characteristicValueStream;
  }

  int get getImpedance {
    return impedance;
  }
  // Connection Status variables
  bool connected = false;
  bool get getConnected => connected;
  int impedance = 0;

  void setConnected(bool value) {
    connected = value;
    notifyListeners();
  }

  setScanStream(StreamSubscription stream) {
    scanStream = stream;
    notifyListeners();
  }

  setConnectionStream(StreamSubscription stream) {
    connectionStream = stream;
    notifyListeners();
  }

  setcharacteristicValueStream(StreamSubscription stream) {
    characteristicValueStream = stream;
    notifyListeners();
  }

  setImpedance(int newvalue) {
    impedance = newvalue;
    print("to $impedance");
    notifyListeners();
  }


  // subscription values
  List<int> intArray = [];
  Map<dynamic, dynamic> char_value = {};
  List<dynamic> listValue = [0];

  initialiseBLE() {
    WinBle.initialize(enableLog: false);
    connectionStream = WinBle.connectionStream.listen((event) {
      print("Connection Event : " + event.toString());
    });

    // Listen to Scan Stream , we can cancel in onDispose()
    scanStream = WinBle.scanStream.listen((event) {
      if (!devices.any((element) => element.address == event.address) &&
          event.name == "nstim") {
        devices.add(event);
      }
    });

    // Listen to Characteristic Value Stream
    characteristicValueStream =
        WinBle.characteristicValueStream.listen((event) {
      // TODO: convert CharValue event (notify capture) into list and get error dialogue to
      // pop up when a new notification is sent through
      print("CharValue : $event");

      char_value = event;
      listValue = char_value["value"];
      intArray = [];
      listValue.forEach((listItem) {
        intArray.add(listItem);
      });

      print("setting impedence");
      setImpedance(impedenceByteCalculation(intArray[2], intArray[1]));
    });
  }

  List<int> get getNotifyIntArray => intArray;

  void clearNotifyArray() {
    intArray = [];
  }

  disposeBLE() {
    WinBle.dispose();
    connectionStream?.cancel();
    scanStream?.cancel();
    characteristicValueStream?.cancel();
  }

  List<BleDevice> get getdevices => devices;

  resetDevices() {
    devices = <BleDevice>[];
    notifyListeners();
  }

  startScanning() {
    WinBle.startScanning();
  }

  stopScanning() {
    WinBle.stopScanning();
  }

  writeCharacteristic(String address, String serviceID, String charID,
      Uint8List data, bool writeWithResponse) async {
    await WinBle.write(
        address: address,
        service: serviceID,
        characteristic: charID,
        data: data,
        writeWithResponse: true);
  }

  subsCribeToCharacteristic(address, serviceID, charID) async {
    try {
      await WinBle.subscribeToCharacteristic(
          address: address, serviceId: serviceID, characteristicId: charID);
      print("Subscribe Successfully");
    } catch (e) {
      print("SubscribeCharError : $e");
    }
  }

  unSubscribeToCharacteristic(address, serviceID, charID) async {
    try {
      await WinBle.unSubscribeFromCharacteristic(
          address: address, serviceId: serviceID, characteristicId: charID);
      print("Unsubscribed Successfully");
    } catch (e) {
      print("UnSubscribeError : $e");
    }
  }

  disconnect(address) async {
    try {
      await WinBle.disconnect(address);
      setConnected(false);

      return true;
    } catch (e) {
      return false;
    }
  }

  connect(address) async {
    try {
      await WinBle.connect(address);
      connected = true;
      return true;
    } catch (e) {
      return false;
    }
  }


}


//Some Helper Functions

int impedenceByteCalculation(int frontbyte, int endByte) {
  int x = 0;

  frontbyte = frontbyte << 8;
  
  x = endByte | frontbyte;
   
  return x;
}