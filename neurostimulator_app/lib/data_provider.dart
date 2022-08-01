import 'package:flutter/material.dart';
import 'dart:convert';
import "dart:typed_data";
import 'package:win_ble/win_ble.dart';
import 'package:ns_2022/helper_and_const.dart';
import 'dart:async';

/*
The Data class is a from the provider package. It is used for state management
and its job is to act as a 'database' for values that will be sent to the
stimulator

*/

class Data extends ChangeNotifier {
  // listed below are the values stored as integers and booleans
  var defaultValue = 0;
  var _phase1TimeMicrosec = 1000;
  var _interPhaseDelayMicrosec = 1000;
  var _phase2TimeMicrosec = 1000;
  var _interStimDelayMicrosec = 1000;
  var _burstDurationMicrosec = 0;
  var _dutyCyclePercentage = 0;
  var _frequency = 0;

  //
  var _interStimDelayStringForDisplay_frequency = "";

  //dc mode related values
  var _rampUpTime = 0;
  var _dcHoldTime = 0;
  var _dcCurrentTargetMicroAmp = 1000;
  var _dcBurstGap = 0;
  var _dcBurstNum = 0;



  //ints for right side of workspace
  var _phase1CurrentMicroAmp = 1500;
  var _phase2CurrentMicroAmp = 3000;
  
  //end stimulation by duration, minute and seconds
  var _endStimulationMinute = 0;
  var _endStimulationSeconds = 0;

  var _endbyvalue = 1;

  // calculate interstim by freq
  bool _calculate_interstim_by_freq = false;

  //burst or continuos stimulation
  bool _continuousStim = false;
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

  //variables used for burst calculations

  ////////////////////////////////
  ///DEBUG MAP, delete this before prod, this is a map that is used to print all the values 
  ///stored in this provider class
  
   late var debug_map = {


  "phase 1 time": getPhase1Time,
    "_interPhaseDelayMicrosec":getInterPhaseDelay,
    "_phase2TimeMicrosec":getPhase2Time,
    "_interStimDelayMicrosec":getInterstimDelay,


  "_burstDurationMicrosec":_burstDurationMicrosec,
    "_dutyCyclePercentage":_dutyCyclePercentage,
    "_frequency":_frequency,
    "_interStimDelayStringForDisplay_frequency":_interStimDelayStringForDisplay_frequency,


  "_rampUpTime":_rampUpTime,
    "_dcHoldTime":_dcHoldTime,
    "_dcCurrentTargetMicroAmp":_dcCurrentTargetMicroAmp,
    "_dcBurstGap":_dcBurstGap,
  
  "_dcBurstNum":_dcBurstNum,
    "_phase1CurrentMicroAmp":_phase1CurrentMicroAmp,
    "_phase2CurrentMicroAmp":_phase2CurrentMicroAmp,
    "_endStimulationMinute":_endStimulationMinute,

  "_endbyvalue":_endbyvalue,
    "_calculate_interstim_by_freq":_calculate_interstim_by_freq,
    "_continuousStim":_continuousStim,
    "_dcMode":_dcMode,

  "_endByDuration":_endByDuration,
    "_endByBurst":_endByBurst,
    "_stimForever":_stimForever,
    "_cathodicFirst":_cathodicFirst,

    "_anodicFirst":_anodicFirst,

  };


  ////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////////////////////
  ///Map for of all values that are sent to the firmware as parameters for stimulation
  ///each value is stored as an Uint8list
  ///which is the equivalent of a 32 bit bytearray in python.
  ///
  ///

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
    "dac_phase_one": Uint8List.fromList([dac_phase_one, 220, 5, 0, 0]),
    "dac_phase_two": Uint8List.fromList([dac_phase_two, 184, 11, 0, 0]),
    "ramp_up_time": Uint8List.fromList([ramp_up_time, 0, 0, 0, 0]),
    "dc_hold_time": Uint8List.fromList([dc_hold_time, 0, 0, 0, 0]),
    "dc_curr_target": Uint8List.fromList([dc_curr_target, 232, 3, 0, 0]),
    "dc_burst_gap": Uint8List.fromList([dc_burst_gap, 0, 0, 0, 0]),
    "dc_burst_num": Uint8List.fromList([dc_burst_num, 0, 0, 0, 0]),
    "start": start_bytearray,
  };

  Map get getdebugmap{
    print("hi");
    print("phase one time is = $_phase1TimeMicrosec");
    return debug_map;
    }

  ///////////////////////////////////////////////////////////////////////////////////////////////
  // the below are methods used for "notifying" and changing the values stored in the Data class
  // this means that if a value is changed on the UI, one of these functions are called to
  // replace the corresponding value in provider
  void toggleCathodicAnodic(bool option) {
    _cathodicFirst = option;
    _anodicFirst = !option;
    notifyListeners();
  }

  void toggleDC(bool dcmode) {
    _dcMode = dcmode;
    notifyListeners();
  }

  void togglefrequency(bool frequency) {
    _calculate_interstim_by_freq = frequency;
    if (frequency == false) {
      _interStimDelayStringForDisplay_frequency == "";
    }
    notifyListeners();
  }

// continous stimulation

  void toggleburstcont(bool continuous) {
    _continuousStim = !continuous;
    // //print("burstmode is equal to $_continuousStim");
    notifyListeners();
  }

/////////////////////////////////////////
  ///function for calculating the values for ending by duration
  ///and putting them into the serial input char map
  void toggleEndByDuration(bool option) {
    //updates that end by duration is the chosen ending method
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
    notifyListeners();
  }

  setDCHoldTime(String dcHoldTime) {
    _dcHoldTime = int.tryParse(dcHoldTime) ?? defaultValue;
    notifyListeners();
  }

  setDCBurstGap(String dcburstgap) {
    _dcBurstGap = int.tryParse(dcburstgap) ?? defaultValue;
    notifyListeners();
  }

  setDCBurstNum(String dcburstnum) {
    _dcBurstNum = int.tryParse(dcburstnum) ?? defaultValue;
    notifyListeners();
  }


  setfrequency(String frequencyinput) {
    _frequency = int.tryParse(frequencyinput) ?? defaultValue;
    _interStimDelayMicrosec = calculate_interstim_from_frequency(_frequency,
        _phase1TimeMicrosec, _phase2TimeMicrosec, _interPhaseDelayMicrosec);
    _interStimDelayStringForDisplay_frequency =
        _interStimDelayMicrosec.toString();
    notifyListeners();
  }

  setphase1(String phase1TimeStringFromTextfield) {
    _phase1TimeMicrosec = int.tryParse(phase1TimeStringFromTextfield) ?? 0;
    print("helloooo");
    notifyListeners();
  }

  // NOTE INTERPHASE delay is INTERPHASE_GAP, idk why they are not named the same
  // but this is in adherrance to the old UI.
  setinterphasedelay(String interPhaseDelayStringFromTextField) {
    _interPhaseDelayMicrosec =
        int.tryParse(interPhaseDelayStringFromTextField) ?? 1000;
    notifyListeners();
  }

  setphase2(String phase2TimeStringFromTextfield) {
    _phase2TimeMicrosec = int.tryParse(phase2TimeStringFromTextfield) ?? 1000;
    notifyListeners();
  }

  setinterstimdelay(String interStimDelayStringFromTextField) {
    _interStimDelayMicrosec =
        int.tryParse(interStimDelayStringFromTextField) ?? 1000;
    notifyListeners();
  }

  setburstduration(String burstDurationFromTextField) {
    _burstDurationMicrosec =
        int.tryParse(burstDurationFromTextField) ?? defaultValue;
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////////////////////////
  /// How the following values are used, need to be sorted

  setdutycycle(String dutyCycleFromTextField) {
    _dutyCyclePercentage = int.tryParse(dutyCycleFromTextField) ?? defaultValue;
    notifyListeners();
  }

  setDCCurrentTarget(String dcCurrentTarget) {
    _dcCurrentTargetMicroAmp = int.tryParse(dcCurrentTarget) ?? 1000;
    notifyListeners();
  }

  setphase1current(String phase1current) {
    _phase1CurrentMicroAmp = int.tryParse(phase1current) ?? 1500;
    notifyListeners();
  }

  setphase2current(String phase2current) {
    _phase2CurrentMicroAmp = int.tryParse(phase2current) ?? 3000;
    notifyListeners();
  }

  setinterstimsting(String interstim_value_from_frequency) {
    _interStimDelayStringForDisplay_frequency = interstim_value_from_frequency;
    notifyListeners();
  }

////////////////////////////////////////////////////////////////////////////////////////
  setendbyvalue(String endby) {
    _endbyvalue = int.tryParse(endby) ?? 1;
    notifyListeners();
  }

  setendbystimulationminute(String endbyminutes) {
    _endStimulationMinute = int.tryParse(endbyminutes) ?? 0;
    notifyListeners();
  }

  setendbystimulationseconds(String endbyseconds) {
    _endStimulationSeconds = int.tryParse(endbyseconds) ?? 0;
    notifyListeners();
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
    return _endbyvalue.toString();
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

  bool get getCalculateByFrequency {
    return _calculate_interstim_by_freq;
  }

  bool get getBurstMode {
    return _continuousStim;
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

  int get getBurstDuration {
    return _burstDurationMicrosec;
  }

  int get getDutyCycle {
    return _dutyCyclePercentage;
  }

  int get getRampUpTime {
    return _rampUpTime;
  }

  int get getDCHoldTime {
    return _dcHoldTime;
  }

  int get getDCBurstGap {
    return _dcBurstGap;
  }

  int get getDCBurstNum {
    return _dcBurstNum;
  }



  int get getFrequency {
    return _frequency;
  }

  int get getDCCurrentTarget {
    return _dcCurrentTargetMicroAmp;
  }
//

  int get getendbyminutes {
    return _endStimulationMinute;
  }

  int get getendbyseconds {
    return _endStimulationSeconds;
  }

//
  int get getPhase1Current {
    return _phase1CurrentMicroAmp;
  }

  int get getPhase2Current {
    return _phase2CurrentMicroAmp;
  }

  Map get get_serial_command_input_char {
    return serial_command_input_char;
  }

  String get getinterstimstring {
    return _interStimDelayStringForDisplay_frequency;
  }

  ///////////////////////////////////////////////////////////////////////////////////
  ///end of get functions

/////////////
  ///Function that updates the serial command input char map before it is sent to the stimulator
  void prepare_stimulation_values() {
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

    print(_dcBurstGap);
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

    //print("cathodic_first = $_cathodicFirst");
    //print(_phase1CurrentMicroAmp);
    //print(_phase2CurrentMicroAmp);

    serial_command_input_char["dac_phase_one"] =
        bytearray_maker(dac_phase_one, _phase1CurrentMicroAmp);
    serial_command_input_char["dac_phase_two"] =
        bytearray_maker(dac_phase_two, _phase2CurrentMicroAmp);


    var dc_burst = 0;

    if (_dcMode) {

      if (_endByDuration && _dcHoldTime != 0 && _dcBurstGap != 0 && _rampUpTime != 0) {
        var dcstimduration = (_endStimulationMinute * 60) + _endStimulationSeconds;
        dc_burst = ((dcstimduration*1000000)/(_dcHoldTime + _dcBurstGap + _rampUpTime)).round();

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
		if ((burstPeriod - _burstDurationMicrosec).round() > _interStimDelayMicrosec) {
			interburst = (burstPeriod - _burstDurationMicrosec).round() - _interStimDelayMicrosec;
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

      if (burstPeriod != 0) {
        //burst number is calculated as time divided by duration of each burst
        // returns an interger
        burstnumber = (stimduration * 1000000) ~/ burstPeriod;

      } else {
        //in adherrance to old ui, returns zero, but I want to add an
        // error case
        burstnumber = 0;
      }
    }
    // if ending by number of bursts, the user inputs the number of bursts

    //////////////////////////////////////////////////

    if (_endByBurst) {
//           if(_endbyvalue != 0) {

      burstnumber = _endbyvalue;


    }

    // if burst mode is sdlected the pulse number is calculated

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
  ///////////////////////////////////////////////////////////////
  ///BLE Section 
  /// the following values are use for BLE connection
  /// values calculated in the UI is stored here so navigation between pages can occur smoothly
  
  StreamSubscription? scanStream;
  StreamSubscription? connectionStream;
  List<BleDevice> devices = <BleDevice>[];

  bool isScanning = false;
  bool notloading = false;

  StreamSubscription? get getScanStream {
    return scanStream;
  }

  StreamSubscription? get getConnnectionStream {
    return connectionStream;
  }

  setScanStream(StreamSubscription stream) {
    scanStream = stream;
    notifyListeners();
  }

  setConnectionStream(StreamSubscription stream) {
    connectionStream = stream;
    notifyListeners();
  }


}