
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
  var _interStimDelay = "";
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
    return _interStimDelay;
  }

  setphase1(String phase1TimeStringFromTextfield) {
    _phase1TimeMicrosec = int.tryParse(phase1TimeStringFromTextfield) ?? defaultValue;
    _phase1Time = phase1TimeStringFromTextfield;
    notifyListeners();
  }

  setinterphasedelay(String interPhaseDelayStringFromTextField) {
    _interPhaseDelayMicrosec =  int.tryParse(interPhaseDelayStringFromTextField) ?? defaultValue;
    _interPhaseDelay = interPhaseDelayStringFromTextField;
    notifyListeners();
  }

  setphase2(String phase2TimeStringFromTextfield) {
    _phase2TimeMicrosec = int.tryParse(phase2TimeStringFromTextfield) ?? defaultValue;
    _phase2Time = phase2TimeStringFromTextfield;
    notifyListeners();
  }

  setinterstimdelay(String interStimDelayStringFromTextField) {
    _interstimDelayMicrosec =  int.tryParse(interStimDelayStringFromTextField) ?? defaultValue;
    _interStimDelay = interStimDelayStringFromTextField;
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