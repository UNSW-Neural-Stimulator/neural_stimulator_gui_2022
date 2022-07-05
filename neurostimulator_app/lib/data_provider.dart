
import 'package:flutter/material.dart';
import 'dart:convert';

/*
The Data class is a from the provider package. It is used for state management
and its job is to act as a 'database' for values that will be sent to the
stimulator

*/

class Data extends ChangeNotifier {

  // listed below are the values stored as integers and booleans

  var defaultValue = 0;
  //var _deviceNumber = 0;
  // the following are int variables for the left side of the workspace
  var _phase1TimeMicrosec = 0;
  var _interPhaseDelayMicrosec = 0;
  var _phase2TimeMicrosec = 0;
  var _interStimDelayMicrosec = 0;
  var _burstPeriodMs = 0;
  var _dutyCyclePercentage = 0;
  var _rampUpTime = 0;
  var _frequency = 0;

  //ints for right side of workspace
  var _phase1CurrentMicroAmp = 0;
  var _vref0 = 0;
  var _phase2CurrentMicroAmp = 0;
  var _vref65535 = 0;
  //end stimulation
  var _endByDuraionValue = 0;
  var _endByBurstValue = 0;

  //buttons from right side of workspace
  //bool _start = false;
  bool _dcMode = false;

  //end simulation toggle button
  bool _endByDuration = true;
  bool _endByBurst = false;
  bool _stimForever = false;

  // if false then anodic first is true
  bool _cathodicFirst = true;
  bool _anodicFirst = false;
  
  // the below are methods used for "notifying" and changing the values stored in the Data class

  void toggleCathodicAnodic(bool option) {
    _cathodicFirst = option;
    _anodicFirst = !option;
    notifyListeners();
  }

  // void togglestart(bool start) {
  //   _start = start;
  //   notifyListeners();
  // }

  void toggleDC(bool dcmode) {
    _dcMode = dcmode;
    notifyListeners();
  }

  void toggleEndByDuration(bool option) {
    _endByDuration = option;
    notifyListeners();
  }

  void toggleEndByBurst (bool option) {
    _endByBurst = option;
    notifyListeners();
  }

  void toggleStimForever (bool option) {
    _stimForever = option;
    notifyListeners();
  }

  setrampUpTime(String rampUpTime) {
    _rampUpTime = int.tryParse(rampUpTime) ?? defaultValue;
    notifyListeners();
  }

  setfrequency(String frequencyinput) {
    _frequency = int.tryParse(frequencyinput) ?? defaultValue;
    notifyListeners();
  }

  setphase1(String phase1TimeStringFromTextfield) {
    _phase1TimeMicrosec = int.tryParse(phase1TimeStringFromTextfield) ?? defaultValue;
    notifyListeners();
  }

  setinterphasedelay(String interPhaseDelayStringFromTextField) {
    _interPhaseDelayMicrosec =  int.tryParse(interPhaseDelayStringFromTextField) ?? defaultValue;
    notifyListeners();
  }

  setphase2(String phase2TimeStringFromTextfield) {
    _phase2TimeMicrosec = int.tryParse(phase2TimeStringFromTextfield) ?? defaultValue;
    notifyListeners();
  }

  setinterstimdelay(String interStimDelayStringFromTextField) {
    _interStimDelayMicrosec =  int.tryParse(interStimDelayStringFromTextField) ?? defaultValue;
    notifyListeners();
  }

  setburstcycle(String burstCycleFromTextField) {
    _burstPeriodMs = int.tryParse(burstCycleFromTextField) ?? defaultValue;
    notifyListeners();
  }

  setdutycycle(String dutyCycleFromTextField) {
    _dutyCyclePercentage =  int.tryParse(dutyCycleFromTextField) ?? defaultValue;
    notifyListeners();
  }
  setphase1current(String phase1current) {
    _phase1CurrentMicroAmp =  int.tryParse(phase1current) ?? defaultValue;
    notifyListeners();
  }
  setphase2current(String phase2current) {
    _phase2CurrentMicroAmp =  int.tryParse(phase2current) ?? defaultValue;
    notifyListeners();
  }
  setvref0(String vref0) {
    _vref0 =  int.tryParse(vref0) ?? defaultValue;
    notifyListeners();
  }

  setvref65535(String vref65535) {
    _vref65535 =  int.tryParse(vref65535) ?? defaultValue;
    notifyListeners();
  }

  setendbyvalue(String endby) {
    if (endByDuration) {
      _endByDuraionValue =  int.tryParse(endby) ?? defaultValue;
    }
    if (endByBurst) {
      _endByBurstValue =  int.tryParse(endby) ?? defaultValue;
    }
    else {
      _endByDuraionValue =  int.tryParse(endby) ?? defaultValue;
      _endByBurstValue =  int.tryParse(endby) ?? defaultValue;
    }
  }

  // void changeDeviceNumber(int newDeviceNumber) {
  //   _deviceNumber = newDeviceNumber;
  //   notifyListeners();
  // }


  // the methods below are for retrieving the values in data
  bool get endByDuration {
    return _endByDuration;
  }
  bool get endByBurst {
    return _endByBurst;
  }
  bool get stimilateForever {
    return _stimForever;
  }

  String get getendByValue {
    if (endByDuration) {
      return _endByDuraionValue.toString();
    }
    if (endByBurst) {
      return _endByBurstValue.toString();
    }
    else {
      return "";
    }
  }


  String get endByDurationTitle {
    if (_endByDuration) {
      return "Stimulation Duration (s)";
    }
    else if (_endByBurst) {
      return "Number of Bursts";
    }
    else {
      return "Stimulating forever, text box will not accept any input";
    }
  }

  bool get getCathodicFirst {
    return _cathodicFirst;
  }

  // bool get getstart {
  //   return _start;
  // }
  bool get getDcMode {
    return _dcMode;
  }

  // int get getDeviceNumber {
  //   return _deviceNumber;
  // }

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
    return _interStimDelayMicrosec;
  }

  int get getBurstPeriod {
    return _burstPeriodMs;
  }
  int get getDutyCycle {
    return _dutyCyclePercentage;
  }

  int get getrampUpTime {
    return _rampUpTime;
  }
  int get getfrequency {
    return _frequency;
  }
//
  int get getPhase1Current {
    return _phase1CurrentMicroAmp;
  }
  int get getvref0 {
    return _vref0;
  }

  int get getPhase2Current {
    return _phase2CurrentMicroAmp;
  }
  int get vref65535 {
    return _vref65535;
  }

  String get getRampUpTimeString {
    return _rampUpTime.toString();
  }

  String get getFrequencyString {
    return _frequency.toString();
  }
  String get getPhase1TimeString {
    return _phase1TimeMicrosec.toString();
  }
  String get getInterPhaseDelayString {
    return _interPhaseDelayMicrosec.toString();
  }

  String get getPhase2TimeString {
    return _phase2TimeMicrosec.toString();
  }
  String get getInterstimDelayString {
    return _interStimDelayMicrosec.toString();
  }

  String get getBurstPeriodMsString {
    return _burstPeriodMs.toString();
  }
  String get getDutyCycleString {
    return _dutyCyclePercentage.toString();
  }

  String get getPhase1CurrentString {
    return _phase1CurrentMicroAmp.toString();
  }
  String get getVref0String {
    return _vref0.toString();
  }

  String get getPhase2CurrentString {
    return _phase2CurrentMicroAmp.toString();
  }
  String get getVref65535String {
    return _vref65535.toString();
  }

}