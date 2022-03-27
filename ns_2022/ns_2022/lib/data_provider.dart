
import 'package:flutter/material.dart';
import 'dart:convert';

class Data extends ChangeNotifier {
  var defaultValue = 0;
  var _deviceNumber = 0;
  var _phase1TimeMicrosec = 0;
  var _interPhaseDelayMicrosec = 0;
  var _phase2TimeMicrosec = 0;
  var _interstimDelayMicrosec = 0;
  var _phase2Time = "";
  var _interstimDelay = "";
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

  int get getPhase2Time {
    return _phase2TimeMicrosec;
  }
  int get getInterstimDelay {
    return _interstimDelayMicrosec;
  }

  String get getPhase1TimeString {
    return _phase1Time;
  }
  String get getInterPhaseDelayString {
    return _interPhaseDelay;
  }

  String get getPhase2TimeString {
    return _phase2Time;
  }
  String get getInterstimDelayString {
    return _interstimDelay;
  }

  setphase1(String getPhase1TimeString) {
    _phase1TimeMicrosec = int.tryParse(getPhase1TimeString) ?? defaultValue;
    notifyListeners();
  }

  setinterphasedelay(String getInterPhaseDelayString) {
    _interPhaseDelayMicrosec =  int.tryParse(getInterPhaseDelayString) ?? defaultValue;
    notifyListeners();
  }

  setphase2(String getPhase2TimeString) {
    _phase2TimeMicrosec = int.tryParse(getPhase2TimeString) ?? defaultValue;
    notifyListeners();
  }

  setinterstimdelay(String getInterstimDelayString) {
    _interstimDelayMicrosec =  int.tryParse(getInterstimDelayString) ?? defaultValue;
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