
import 'package:flutter/material.dart';
import 'dart:convert';

class Data extends ChangeNotifier {
  var defaultValue = 0;
  var _deviceNumber = 0;
  var _phase1TimeMicrosec = 0;
  var _interPhaseDelayMicrosec = 0;
  var _phase1Time = "";
  var _interPhaseDelay = "";

  int get getDeviceNumber {
    return _deviceNumber;
  }

  int get getPhase1Time {
    return _phase1TimeMicrosec;
  }
  int get getInterPhaseDelay {
    return _interPhaseDelayMicrosec;
  }

  String get getPhase1TimeString {
    return _phase1Time;
  }
  String get getInterPhaseDelayString {
    return _interPhaseDelay;
  }

  setphase1(String getPhase1TimeString) {
    _phase1TimeMicrosec = int.tryParse(getPhase1TimeString) ?? defaultValue;
    notifyListeners();
  }

  setinterphasedelay(String getInterPhaseDelayString) {
    _interPhaseDelayMicrosec =  int.tryParse(getInterPhaseDelayString) ?? defaultValue;
    notifyListeners();
  }

  void changeDeviceNumber(int newDeviceNumber) {
    _deviceNumber = newDeviceNumber;
    notifyListeners();
  }


  // void changePhase1Time(String newPhase1Time) {
  //   _phase1TimeMicrosec = int.parse(newPhase1Time);
  //   notifyListeners();
  // }

  // void changeInterPhaseDelay(String newInterPhaseDelay) {
  //   _interPhaseDelayMicrosec =  int.parse(newInterPhaseDelay);
  //   notifyListeners();
  //  }

}