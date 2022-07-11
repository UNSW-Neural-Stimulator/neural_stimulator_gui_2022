import 'package:flutter/material.dart';
import 'dart:convert';
import "dart:typed_data";

import 'package:ns_2022/helper_and_const.dart';

/*
The Data class is a from the provider package. It is used for state management
and its job is to act as a 'database' for values that will be sent to the
stimulator

*/

class Data extends ChangeNotifier {
  // listed below are the values stored as integers and booleans
  var defaultValue = 0;
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

  //burst or continuos stimulation
  bool _burstmode = false;
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

  ///////////////////////////////////////////////////////////////////////////////////////////////
  ///Map for of all values that are sent to the firmware as parameters for stimulation
  ///each value is stored as an Uint8list 
  ///which is the equivalent of a 32 bit bytearray in python.
  ///
  ///

  var serial_command_input_char = {
                    "stop":stop_bytearray,
                    "dac_phase_one": Uint8List.fromList([dac_phase_one,0,0,0,0]),
                    "dac_phase_two":Uint8List.fromList([dac_phase_two,0,0,0,0]),
                    "stim_type": Uint8List.fromList([stim_type,0,0,0,0]),
                    "anodic_cathodic":Uint8List.fromList([anodic_cathodic,0,0,0,0]),
                    "dc_mode":Uint8List.fromList([dc_mode,0,0,0,0]),
                    "ramp_up_time":Uint8List.fromList([ramp_up_time,0,0,0,0]),
                    "phase_one_time":Uint8List.fromList([phase_one_time,0,0,0,0]),
                    "phase_two_time":Uint8List.fromList([phase_two_time,0,0,0,0]),
                    "inter_phase_gap":Uint8List.fromList([inter_phase_gap,0,0,0,0]),
                    "inter_stim_delay":Uint8List.fromList([inter_stim_delay,0,0,0,0]),
                    "inter_burst_delay":Uint8List.fromList([inter_burst_delay,0,0,0,0]),
                    "pulse_num":Uint8List.fromList([pulse_num,0,0,0,0]),
                    "pulse_num_in_one_burst":Uint8List.fromList([pulse_num_in_one_burst,0,0,0,0]),
                    "burst_num":Uint8List.fromList([burst_num,0,0,0,0]),
                    "ramp_up":Uint8List.fromList([ramp_up,0,0,0,0]),
                    "short_electrode":Uint8List.fromList([short_electrode,0,0,0,0]),
                    "start": start_bytearray,
  };

  ///////////////////////////////////////////////////////////////////////////////////////////////
  // the below are methods used for "notifying" and changing the values stored in the Data class
  // this means that if a value is changed on the UI, one of these functions are called to
  // replace the corresponding value in provider
  void toggleCathodicAnodic(bool option) {
    _cathodicFirst = option;
    _anodicFirst = !option;
    int option_int = option ? 1:0;
    serial_command_input_char["anodic_cathodic"] = Uint8List.fromList([anodic_cathodic,0,0,0,option_int]);
    notifyListeners();
  }

  void toggleDC(bool dcmode) {
    _dcMode = !dcmode;
    int dcmode_int = dcmode ? 1:0;
    serial_command_input_char["dc_mode"] = Uint8List.fromList([dc_mode,0,0,0,dcmode_int]);
    notifyListeners();
  }

// continous stimulation

  void toggleburstcont(bool continous_stim) {
    _burstmode = !continous_stim;
    int _burstmode_int = continous_stim ? 1:0;
    serial_command_input_char["stim_type"] = Uint8List.fromList([stim_type,0,0,0,_burstmode_int]);
    notifyListeners();
  }
/////////////////////////////////////////
// TODO: Options on how to end stimulation must match old UI
  void toggleEndByDuration(bool option) {
    _endByDuration = option;
    notifyListeners();
  }

  void toggleEndByBurst(bool option) {
    _endByBurst = option;
    notifyListeners();
  }

  void toggleStimForever(bool option) {
    _stimForever = option;
    notifyListeners();
  }
/////////////////////////////////////////////////////////////////
  setrampUpTime(String rampUpTime) {
    _rampUpTime = int.tryParse(rampUpTime) ?? defaultValue;
    serial_command_input_char["ramp_up_time"] = int32toBigEndianBytes(_rampUpTime);
    notifyListeners();
  }

  setfrequency(String frequencyinput) {
    _frequency = int.tryParse(frequencyinput) ?? defaultValue;
    serial_command_input_char["frequency"] = int32toBigEndianBytes(_frequency);
    notifyListeners();
  }


  setphase1(String phase1TimeStringFromTextfield) {
    _phase1TimeMicrosec =
        int.tryParse(phase1TimeStringFromTextfield) ?? defaultValue;
    serial_command_input_char["phase_one_time"] = int32toBigEndianBytes(_phase1TimeMicrosec);
    notifyListeners();
  }

  // NOTE INTERPHASE delay is INTERPHASE_GAP, idk why they are not named the same
  // but this is in adherrance to the old UI.
  setinterphasedelay(String interPhaseDelayStringFromTextField) {
    _interPhaseDelayMicrosec =
        int.tryParse(interPhaseDelayStringFromTextField) ?? defaultValue;
    serial_command_input_char["inter_phase_gap"] = int32toBigEndianBytes(_interPhaseDelayMicrosec);
    notifyListeners();
  }

  setphase2(String phase2TimeStringFromTextfield) {
    _phase2TimeMicrosec =
        int.tryParse(phase2TimeStringFromTextfield) ?? defaultValue;
    serial_command_input_char["phase_two_time"] = int32toBigEndianBytes(_phase2TimeMicrosec);
    notifyListeners();
  }
  setinterstimdelay(String interStimDelayStringFromTextField) {
    _interStimDelayMicrosec =
        int.tryParse(interStimDelayStringFromTextField) ?? defaultValue;
    serial_command_input_char["inter_stim_delay"] = int32toBigEndianBytes(_interStimDelayMicrosec);
    notifyListeners();
  }
//TODO, what is burst period, and what does it do
  setburstperiod(String burstPeriodFromTextField) {
    _burstPeriodMs = int.tryParse(burstPeriodFromTextField) ?? defaultValue;
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////////////////////////
  /// How the following values are used, need to be sorted
  //TODO, identify the role of this value
  setdutycycle(String dutyCycleFromTextField) {
    _dutyCyclePercentage = int.tryParse(dutyCycleFromTextField) ?? defaultValue;
    notifyListeners();
  }

  setphase1current(String phase1current) {
    _phase1CurrentMicroAmp = int.tryParse(phase1current) ?? defaultValue;
    serial_command_input_char["dac_phase_one"] = int32toBigEndianBytes(_phase1CurrentMicroAmp);
    notifyListeners();
  }

  setphase2current(String phase2current) {
    _phase2CurrentMicroAmp = int.tryParse(phase2current) ?? defaultValue;
    serial_command_input_char["dac_phase_two"] = int32toBigEndianBytes(_phase2CurrentMicroAmp);
    notifyListeners();
  }
  // TODO: this needs to figured out as it seems to be interacting with the DAC values
  setvref0(String vref0) {
    _vref0 = int.tryParse(vref0) ?? defaultValue;
    notifyListeners();
  }
  // TODO: this needs to figured out as it seems to be interacting with the DAC values
  setvref65535(String vref65535) {
    _vref65535 = int.tryParse(vref65535) ?? defaultValue;
    notifyListeners();
  }
////////////////////////////////////////////////////////////////////////////////////////
  setendbyvalue(String endby) {
    if (endByDuration) {
      _endByDuraionValue = int.tryParse(endby) ?? defaultValue;
    }
    if (endByBurst) {
      _endByBurstValue = int.tryParse(endby) ?? defaultValue;
    } else {
      _endByDuraionValue = int.tryParse(endby) ?? defaultValue;
      _endByBurstValue = int.tryParse(endby) ?? defaultValue;
    }
  }

  /// end of set functions
  ///////////////////////////////////////////////////////////////////////////////////
  // All get methods are used to retrieve a value from provider,
  // e.g. a textfield controller may use a get function to find if any value is stored
  // by provider and fill the textfield with it.
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
    } else {
      return "";
    }
  }

  String get endByDurationTitle {
    if (_endByDuration) {
      return "Stimulation Duration (s)";
    } else if (_endByBurst) {
      return "Number of Bursts";
    } else {
      return "Stimulating forever, text box will not accept any input";
    }
  }

  bool get getCathodicFirst {
    return _cathodicFirst;
  }

  bool get getDcMode {
    return _dcMode;
  }

  bool get getBurstMode {
    return _burstmode;
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
    return _interStimDelayMicrosec;
  }

  int get getBurstPeriod {
    return _burstPeriodMs;
  }

  int get getDutyCycle {
    return _dutyCyclePercentage;
  }

  int get getRampUpTime {
    return _rampUpTime;
  }

  int get getFrequency {
    return _frequency;
  }

//
  int get getPhase1Current {
    return _phase1CurrentMicroAmp;
  }

  int get getVref0 {
    return _vref0;
  }

  int get getPhase2Current {
    return _phase2CurrentMicroAmp;
  }

  int get getVref65535 {
    return _vref65535;
  }

  ///////////////////////////////////////////////////////////////////////////////////
  ///end of get functions

}
