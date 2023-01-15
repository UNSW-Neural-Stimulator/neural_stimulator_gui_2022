import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nstim_app/serviceLayer/Input_validation.dart';
import 'package:nstim_app/serviceLayer/math_helper_functions.dart';
import 'dart:convert';
import "dart:typed_data";
import 'dart:async';
import 'package:win_ble/win_ble.dart';
import 'package:provider/provider.dart';
import '../util/consts.dart';

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
    "rampUpTime": 0,
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

  var serial_command_input_char = {
    "stop": stop_bytearray,
    "stim_type": Uint8List.fromList([stim_type, 0, 0, 0, 0]),
    "anodic_cathodic": Uint8List.fromList([anodic_cathodic, 1, 0, 0, 0]),
    "phase_one_time": Uint8List.fromList([phase_one_time, 232, 3, 0, 0]),
    "phase_two_time": Uint8List.fromList([phase_two_time, 232, 3, 0, 0]),
    "inter_phase_gap": Uint8List.fromList([inter_phase_gap, 232, 3, 0, 0]),
    "inter_stim_delay": Uint8List.fromList([inter_stim_delay, 232, 3, 0, 0]),
    "inter_burst_delay": Uint8List.fromList([inter_burst_delay, 0, 0, 0, 0]),
    "burst_num": Uint8List.fromList([burst_num, 0, 0, 0, 0]),
    "pulse_num": Uint8List.fromList([pulse_num, 0, 0, 0, 0]),
    "dac_phase_one": Uint8List.fromList([dac_phase_one, 184, 11, 0, 0]),
    "dac_phase_two": Uint8List.fromList([dac_phase_two, 184, 11, 0, 0]),
    "ramp_up_time": Uint8List.fromList([ramp_up_time, 0, 0, 0, 0]),
    "dc_hold_time": Uint8List.fromList([dc_hold_time, 0, 0, 0, 0]),
    "dc_curr_target": Uint8List.fromList([dc_curr_target, 232, 3, 0, 0]),
    "dc_burst_gap": Uint8List.fromList([dc_burst_gap, 0, 0, 0, 0]),
    "dc_burst_num": Uint8List.fromList([dc_burst_num, 0, 0, 0, 0]),
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

  Map get getSerialCommandInputChar {
    return serial_command_input_char;
  }
  
  /////////////////////////////////////////////////////////////////////
  // Final start stimulation error check
  String startStimErrorCheck(bool connected) {
    String formattedWarning = "";
    if (!connected) {
      formattedWarning = formattedWarning + "Device is not connected.\n";
      return formattedWarning;
    }
    if (!retrieveBoolValue("DCModeOn")){
      if (retrieveIntValue("phase1TimeMicroSec") > UINT32MAX ||
          retrieveIntValue("phase2TimeMicroSec") > UINT32MAX ||
          retrieveIntValue("interphaseDelay") > UINT32MAX ||
          retrieveIntValue("interstimDelay") > UINT32MAX) {
        formattedWarning =
            formattedWarning + "Phase time settings are invalid\n";
      }
      var interstim_by_freq = calculateInterstimByFrequency(retrieveIntValue("frequency"),
          retrieveIntValue("phase1TimeMicroSec"), retrieveIntValue("phase2TimeMicroSec"), retrieveIntValue("interphaseDelay"));

      if (retrieveBoolValue("calculateInterstimByFreq") && interstim_by_freq < 0) {
        formattedWarning = formattedWarning + "Frequency value is invalid.\n";
      }
      if ((retrieveIntValue("burstDuration") <= getpulsePeriod) && !retrieveBoolValue("continuousStimOn")) {
        formattedWarning = formattedWarning + "Burst duration is invalid.\n";
      }

      if (retrieveIntValue("dutyCyclePercentage") <= 0 ||
          retrieveIntValue("dutyCyclePercentage") > 100 && !retrieveBoolValue("continuousStimOn")) {
        formattedWarning = formattedWarning + "Duty Cycle is invalid.\n";
      }

      if (retrieveIntValue("phase1Current") > UINT32MAX ||
          retrieveIntValue("phase2Current") > UINT32MAX) {
        formattedWarning = formattedWarning + "Current values are invalid\n";
      }
    } else {
      if (retrieveIntValue("DCCurrent") > UINT32MAX ||
          retrieveIntValue("DCBurstGap") > UINT32MAX ||
          retrieveIntValue("rampUpTime") > UINT32MAX ||
          retrieveIntValue("DCHoldTime") > UINT32MAX) {
        formattedWarning =
            formattedWarning + "DC stimulation values are invalid\n";
      }
    }
    bool stimDurationInvalid = stimulationDurationMinimum(
        retrieveIntValue("durationMinutes"),
        retrieveIntValue("durationSeconds"),
        retrieveIntValue("burstDuration"),
        retrieveIntValue("RampUpTime"),
        retrieveIntValue("DCHoldtime"),
        retrieveBoolValue("DCModeOn"));
    if (stimDurationInvalid && retrieveBoolValue("endByDuration")) {
      formattedWarning =
          formattedWarning + "Stimulation duration values are invalid\n";
    }

    return formattedWarning;
  }




  /////////////
  ///Function that updates the serial command input char map before it is sent to the stimulator
  void prepare_stimulation_values() {

  var _phase1TimeMicrosec = retrieveIntValue("phase1TimeMicroSec");
  var _interPhaseDelayMicrosec = retrieveIntValue("interphaseDelay");
  var _phase2TimeMicrosec = retrieveIntValue("phase2TimeMicroSec");
  var _interStimDelayMicrosec = retrieveIntValue("interstimDelay");
  var _burstDurationMicrosec = retrieveIntValue("burstDuration");
  var _dutyCyclePercentage = retrieveIntValue("dutyCyclePercentage");
  var _rampUpTime = retrieveIntValue("rampUpTime");
  var _dcHoldTime = retrieveIntValue("DCHoldtime");
  var _dcCurrentTargetMicroAmp = retrieveIntValue("DCCurrent");
  var _dcBurstGap = retrieveIntValue("DCBurstGap");
  var _phase1CurrentMicroAmp = retrieveIntValue("phase1Current");
  var _phase2CurrentMicroAmp = retrieveIntValue("phase2Current");
  var _endStimulationMinute = retrieveIntValue("durationMinutes");;
  var _endStimulationSeconds = retrieveIntValue("durationSeconds");;
  var _endbyvalue = retrieveIntValue("endByBurstNum");;
  bool _continuousStim = retrieveBoolValue("continuousStimOn");
  bool _dcMode = retrieveBoolValue("DCModeOn");
  bool _endByDuration = retrieveBoolValue("endByDurtion");
  bool _endByBurst = retrieveBoolValue("endByBurst");
  bool _stimForever = retrieveBoolValue("stimulateForever");
  bool _cathodicFirst = retrieveBoolValue("cathodicFirst");




    int temporary_bool_to_int = 0;
    temporary_bool_to_int = _cathodicFirst ? 1 : 0;
    serial_command_input_char["anodic_cathodic"] =
        Uint8List.fromList([anodic_cathodic, temporary_bool_to_int, 0, 0, 0]);

    temporary_bool_to_int = _dcMode ? 1 : 0;
    serial_command_input_char["stim_type"] =
        Uint8List.fromList([stim_type, temporary_bool_to_int, 0, 0, 0]);

    serial_command_input_char["ramp_up_time"] =
        bytearray_maker(ramp_up_time, _rampUpTime);

    serial_command_input_char["dc_curr_target"] =
        bytearray_maker(dc_curr_target, _dcCurrentTargetMicroAmp);

    serial_command_input_char["dc_hold_time"] =
        bytearray_maker(dc_hold_time, _dcHoldTime);

    serial_command_input_char["dc_burst_gap"] =
        bytearray_maker(dc_burst_gap, _dcBurstGap);

    serial_command_input_char["phase_one_time"] =
        bytearray_maker(phase_one_time, _phase1TimeMicrosec);

    serial_command_input_char["inter_phase_gap"] =
        bytearray_maker(inter_phase_gap, _interPhaseDelayMicrosec);

    serial_command_input_char["phase_two_time"] =
        bytearray_maker(phase_two_time, _phase2TimeMicrosec);

    serial_command_input_char["inter_stim_delay"] =
        bytearray_maker(inter_stim_delay, _interStimDelayMicrosec);

    //check which curr value should be negative based off cathodic and anodic
    // the following variables are used to prevent the textfield value becomming negtive
    var _phase1CurrentMicroAmpToSendToBle = _phase1CurrentMicroAmp;
    var _phase2CurrentMicroAmpToSendToBle = _phase2CurrentMicroAmp;

    if (!_cathodicFirst) {
      if (_phase1CurrentMicroAmp < 1) {
        _phase1CurrentMicroAmp = _phase1CurrentMicroAmp * -1;
      }

      if (_phase2CurrentMicroAmp > 1) {
        _phase2CurrentMicroAmp = _phase2CurrentMicroAmp * -1;
      }
    } else {
      if (_phase2CurrentMicroAmp < 1) {
        _phase2CurrentMicroAmp = _phase2CurrentMicroAmp * -1;
      }

      if (_phase1CurrentMicroAmp > 1) {
        _phase1CurrentMicroAmp = _phase1CurrentMicroAmp * -1;
      }
    }

    serial_command_input_char["dac_phase_one"] =
        bytearray_maker(dac_phase_one, _phase1CurrentMicroAmp);
    serial_command_input_char["dac_phase_two"] =
        bytearray_maker(dac_phase_two, _phase2CurrentMicroAmp);

    var dc_burst = 0;

    if (_dcMode) {
      if (_endByDuration &&
          _dcHoldTime != 0 &&
          _dcBurstGap != 0 &&
          _rampUpTime != 0) {
        var dcstimduration =
            (_endStimulationMinute * 60) + _endStimulationSeconds;
        dc_burst = ((dcstimduration * 1000000) /
                (_dcHoldTime + _dcBurstGap + _rampUpTime))
            .round();
      }

      if (_endByBurst) {
        dc_burst = _endbyvalue;
      }

      if (_stimForever) {
        dc_burst = 0;
      }

      serial_command_input_char["dc_burst_num"] =
          bytearray_maker(dc_burst_num, dc_burst);
    }

    /// Calculating amount of bursts and pulses based on stimulation ending method

    /// The following values are used for calculation of burst number
    /// and pulse number
    /// the reason we are not using the values stored into provider
    /// is to prevent any values on the user interface changing
    /// as a result of these calculations.

    // BurstPeriod is the burstduration + interburst delay
    var burstPeriod = 0.0;
    // Pulse Period is the total length of each pulse
    var pulsePeriod = 0;
    // Stim duration is the _endby value convereted to seconds
    var stimduration = 0;
    //
    var burstnumber = 0;
    var pulsenumber = 0;
    var burstfrequency = 0.0;

    pulsePeriod = _phase1TimeMicrosec +
        _phase2TimeMicrosec +
        _interPhaseDelayMicrosec +
        _interStimDelayMicrosec;

/////////////////////////////////
    // if it is burst mode calculate interburst delay
    if (!_continuousStim && !_dcMode && _burstDurationMicrosec != 0) {
      burstPeriod = (_burstDurationMicrosec * 100) / _dutyCyclePercentage;
      int interburst = 0;
      var burstPeriodValidityCheckValue = burstPeriod - _burstDurationMicrosec;
      if ((burstPeriod - _burstDurationMicrosec).round() >
          _interStimDelayMicrosec) {
        interburst = (burstPeriod - _burstDurationMicrosec).round() -
            _interStimDelayMicrosec;
      }

      serial_command_input_char["inter_burst_delay"] =
          bytearray_maker(inter_burst_delay, interburst);
    }

    ///= if continuos stimulation is selected there is no interburst delay
    else {
      int interburst = 0;

      serial_command_input_char["inter_burst_delay"] =
          bytearray_maker(inter_burst_delay, interburst);
    }

/////////////////////////////////////////////////////////////////////

    /// if stimulating forever burst number and pulse number should be zero
    if (_stimForever) {
      if (_continuousStim) {
        serial_command_input_char["burst_num"] = bytearray_maker(burst_num, 0);
      } else {
        serial_command_input_char["pulse_num"] = bytearray_maker(pulse_num, 0);
      }
    }

    ///////////////////////////////////////////////////////////////////
    // if ending by duration, calculate the number of bursts that are needed for the specified duration time
    if (_endByDuration) {
      stimduration = (_endStimulationMinute * 60) + _endStimulationSeconds;
      // print("burstPeriod $burstPeriod");
      if (burstPeriod != 0) {
        //burst number is calculated as time divided by duration of each burst
        // returns an interger
        burstnumber = (stimduration * 1000000) ~/ burstPeriod;
        // print(burstnumber);
      } else if (_continuousStim) {
        burstPeriod = pulsePeriod.toDouble();
        burstnumber = 1;
      } else {
        burstnumber = 0;
      }
    }
    // if ending by number of bursts, the user inputs the number of bursts

    //////////////////////////////////////////////////

    if (_endByBurst) {
      burstnumber = _endbyvalue;
    }

    // if burst mode is selected, the pulse number is calculated

    if (!_continuousStim && pulsePeriod != 0) {
      if (_burstDurationMicrosec != 0) {
        pulsenumber = _burstDurationMicrosec ~/ pulsePeriod;
      }
      if (_burstDurationMicrosec != 0) {
        burstfrequency = 10000000 / _burstDurationMicrosec;
      }
    }
    // if continuous stimulation is selected the pulse number
    // is calculated
    else {
      if (stimduration != 0 && pulsePeriod != 0) {
        stimduration = stimduration * 1000000;
        pulsenumber = stimduration ~/ pulsePeriod;
      }
    }
    //put all new values in serial command input char map
    serial_command_input_char["burst_num"] =
        bytearray_maker(burst_num, burstnumber);
    serial_command_input_char["pulse_num"] =
        bytearray_maker(pulse_num, pulsenumber);
  }


// preset functions


 /////////////////////////////////////
  // preset update functions

  bool prepareUpdatePreset = false;

  bool get getPrepareUpdatePreset => prepareUpdatePreset;

  setPrepareUpdatePreset(bool value) {
    prepareUpdatePreset = value;
    notifyListeners();
  }

  bool updatePreset = false;

  bool get getUpdatePreset => updatePreset;

  setUpdatePreset(bool value) {
    updatePreset = value;
    notifyListeners();
  }

  setFromPreset(Map<String, dynamic> presetMap) async {
    userInputsMap["DCModeOn"] = presetMap["dc_mode"];
     userInputsMap["cathodicFirst"] = presetMap["cathodic_first"];
     userInputsMap["phase1TimeMicroSec"] = presetMap["phase_one_time"];
     userInputsMap["phase2TimeMicroSec"] = presetMap["phase_two_time"];
     userInputsMap["interphaseDelay"] = presetMap["inter_phase_gap"];
     userInputsMap["interstimDelay"] = presetMap["inter_stim_delay"];
     userInputsMap["phase1Current"] = presetMap["dac_phase_one"];
     userInputsMap["phase2Current"] = presetMap["dac_phase_two"];
     userInputsMap["rampUpTime"] = presetMap["ramp_up_time"];
     userInputsMap["DCHoldtime"] = presetMap["dc_hold_time"];
     userInputsMap["DCCurrent"] = presetMap["dc_curr_target"];
     userInputsMap["DCBurstGap"] = presetMap["dc_burst_gap"];
    //  userInputsMap["DCModeOn"] = presetMap["dc_burst_num"];
     userInputsMap["durationMinutes"] = presetMap["end_by_minutes"];
     userInputsMap["durationSeconds"] = presetMap["end_by_seconds"];
     userInputsMap["endByBurstNum"] = presetMap["end_by_value"];
     userInputsMap["endByDurtion"] = presetMap["end_by_duration"];
     userInputsMap["endByBurst"] = presetMap["end_by_burst"];
     userInputsMap["stimulateForever"] = presetMap["stim_forever"];
     userInputsMap["frequency"] = presetMap["frequency"];
     userInputsMap["dutyCyclePercentage"] = presetMap["duty_cycle"];
     userInputsMap["burstDuration"] = presetMap["burst_duration"];
     userInputsMap["continuousStimOn"] = presetMap["continuous_stim"];
    setPrepareUpdatePreset(true);
    await Future.delayed(Duration(milliseconds: 10));
    setPrepareUpdatePreset(false);

    setUpdatePreset(true);
    await Future.delayed(Duration(milliseconds: 50));
    setUpdatePreset(false);
  }

  Map<String, dynamic> generatePresetMap(String presetname) {
    Map<String, dynamic> presetValuesMap = {
      "preset_name": presetname,
      "dc_mode": userInputsMap["DCModeOn"] ,
      "cathodic_first": userInputsMap["cathodicFirst"],
      "phase_one_time": userInputsMap["phase1TimeMicroSec"],
      "phase_two_time": userInputsMap["phase2TimeMicroSec"],
      "inter_phase_gap": userInputsMap["interphaseDelay"],
      "inter_stim_delay": userInputsMap["interstimDelay"],
      "dac_phase_one": userInputsMap["phase1Current"],
      "dac_phase_two": userInputsMap["phase2Current"],
      "ramp_up_time": userInputsMap["rampUpTime"],
      "dc_hold_time": userInputsMap["DCHoldtime"],
      "dc_curr_target": userInputsMap["DCCurrent"],
      "dc_burst_gap": userInputsMap["DCBurstGap"],
      "end_by_minutes": userInputsMap["durationMinutes"],
      "end_by_seconds": userInputsMap["durationSeconds"],
      "end_by_value": userInputsMap["endByBurstNum"],
      "end_by_burst": userInputsMap["endByBurst"],
      "end_by_duration": userInputsMap["endByDurtion"],
      "stim_forever": userInputsMap["stimulateForever"],
      "frequency": userInputsMap["frequency"],
      "burst_duration": userInputsMap["burstDuration"],
      "duty_cycle": userInputsMap["dutyCyclePercentage"],
      "continuous_stim": userInputsMap["continuousStimOn"],
    };
    return presetValuesMap;
  }


}





