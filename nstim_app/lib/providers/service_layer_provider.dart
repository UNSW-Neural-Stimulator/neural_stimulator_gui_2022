import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nstim_app/serviceLayer/math_helper_functions.dart';
import 'dart:convert';
import "dart:typed_data";
import 'dart:async';
import 'package:win_ble/win_ble.dart';
import 'package:provider/provider.dart';

class ServiceLayerProvider extends ChangeNotifier {
  var userInputsMap = {
    "phase1TimeMicroSec": 1000,
    "phase2TimeMicroSec": 1000,
    "interphaseDelay": 1000,
    "interstimDelay": 1000,
    "frequency": 0.0,
    "burstDuration": 0,
    "dutyCyclePercentage": 1,
    "cathodicFirst": true,
    "phase1Current": 3000,
    "phase2Current": 3000,
    "DCCurrent": 3000,
    "DCHoldtime": 0,
    "RampUpTime": 0,
    "DCBurstGap": 0,
    "durationMinutes": 0,
    "durationSeconds": 0,
    "endByBurstNum": 0,
    "endByDurtion": true,
    "endByBurst": false,
    "stimulateForever": false,
    "calculateInterstimByFreq": false,
    "DCModeOn": false,
    "continuousStimOn": true,
  };

  /// To avoid working with dynamic variables
  /// we have the following getter & setter
  /// functions to group similar inputs

  setIntegerValue(String key, String inputString) {
    int inputInt = int.tryParse(inputString) ?? 0;
    userInputsMap.update(key, (value) => inputInt);
    notifyListeners();
  }

  setDoubleValue(String key, String inputString) {
    double inputDouble = double.tryParse(inputString) ?? 0.0;
    userInputsMap.update(key, (value) => inputDouble);
    notifyListeners();
  }

  setBooleanValue(String key, bool newValue) {
    userInputsMap.update(key, (value) => newValue);
    notifyListeners();
  }

  int retrieveIntValue(String key) {
    /// as userInputsMap is a Map<String, Object>
    /// using the the toString() function and then parsing
    /// to an int is needed to retrieve the value
    int result = int.tryParse(userInputsMap[key].toString()) ?? 0;
    return result;
  }

  double? retrieveDoubleValue(String key) {
    /// similar to retrieveIntValue
    /// using the the toString() function and then parsing
    /// to an double is needed to retrieve the value
    /// 
    double result =  double.tryParse(userInputsMap[key].toString()) ?? 0;
    return result;
  }

  bool retrieveBoolValue(String key) {
    /// similar to the above functions
    /// we use the toString method to help us convert
    /// to boolean
    return userInputsMap[key].toString() == 'true';
  }

  updateInterstimByFrequency() {
    setIntegerValue(
        "interstimDelay",
        calculateInterstimByFrequency(
          userInputsMap["frequency"],
          userInputsMap["phase1TimeMicroSec"],
          userInputsMap["phase2TimeMicroSec"],
          userInputsMap["interphaseDelay"],
        ).toString());

    notifyListeners();
  }

  int get getpulsePeriod {
    return (retrieveIntValue("phase1TimeMicroSec") +
        retrieveIntValue("phase2TimeMicroSec") +
        retrieveIntValue("interphaseDelay") +
        retrieveIntValue("interstimDelay"));
  }

    String get endStimulationTitle {
    if (retrieveBoolValue("endByDuration")) {
      return "Stimulation Duration";
    } else if (retrieveBoolValue("endByBurst")) {
      return "Number of Bursts";
    } else {
      return "Stimulating forever, text box will not accept any input";
    }
  }



}
