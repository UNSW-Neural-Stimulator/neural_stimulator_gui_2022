import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import "dart:typed_data";
import 'package:win_ble/win_ble.dart';
import 'package:ns_2022/util/consts.dart';
import 'dart:async';
import 'package:win_ble/win_ble.dart';
import '../util/helper_functions.dart';

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
  var _dutyCyclePercentage = 1;
  var _frequency = 0.0;

  //
  var _interStimDelayStringForDisplay_frequency = "";

  //dc mode related values
  var _rampUpTime = 0;
  var _dcHoldTime = 0;
  var _dcCurrentTargetMicroAmp = 1000;
  var _dcBurstGap = 0;
  var _dcBurstNum = 0;

  //ints for right side of workspace
  var _phase1CurrentMicroAmp = 3000;
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
    "dac_phase_one": Uint8List.fromList([dac_phase_one, 184, 11, 0, 0]),
    "dac_phase_two": Uint8List.fromList([dac_phase_two, 184, 11, 0, 0]),
    "ramp_up_time": Uint8List.fromList([ramp_up_time, 0, 0, 0, 0]),
    "dc_hold_time": Uint8List.fromList([dc_hold_time, 0, 0, 0, 0]),
    "dc_curr_target": Uint8List.fromList([dc_curr_target, 232, 3, 0, 0]),
    "dc_burst_gap": Uint8List.fromList([dc_burst_gap, 0, 0, 0, 0]),
    "dc_burst_num": Uint8List.fromList([dc_burst_num, 0, 0, 0, 0]),
    "start": start_bytearray,
  };

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
    _frequency = double.tryParse(frequencyinput) ?? 0.0;
    _interStimDelayMicrosec = calculate_interstim_from_frequency(_frequency,
        _phase1TimeMicrosec, _phase2TimeMicrosec, _interPhaseDelayMicrosec);
    _interStimDelayStringForDisplay_frequency =
        _interStimDelayMicrosec.toString();
    notifyListeners();
  }

  setfrequencyNoNotify(String frequencyinput) {
    _frequency = double.tryParse(frequencyinput) ?? 0.0;
    _interStimDelayMicrosec = calculate_interstim_from_frequency(_frequency,
        _phase1TimeMicrosec, _phase2TimeMicrosec, _interPhaseDelayMicrosec);
    _interStimDelayStringForDisplay_frequency =
        _interStimDelayMicrosec.toString();
  }


  setphase1(String phase1TimeStringFromTextfield) {
    _phase1TimeMicrosec = int.tryParse(phase1TimeStringFromTextfield) ?? 0;
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
    _dutyCyclePercentage = int.tryParse(dutyCycleFromTextField) ?? 1;
    notifyListeners();
  }

  setDCCurrentTarget(String dcCurrentTarget) {
    _dcCurrentTargetMicroAmp = int.tryParse(dcCurrentTarget) ?? 1000;
    notifyListeners();
  }

  setphase1current(String phase1current) {
    _phase1CurrentMicroAmp = int.tryParse(phase1current) ?? 3000;
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
      return "Stimulation Duration";
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

  double get getFrequency {
    return _frequency;
  }

  int get getDCCurrentTarget {
    return _dcCurrentTargetMicroAmp;
  }

  int get getendbyminutes {
    return _endStimulationMinute;
  }

  int get getendbyseconds {
    return _endStimulationSeconds;
  }

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

  int get getpulsePeriod {
    return (_phase1TimeMicrosec +
        _phase2TimeMicrosec +
        _interPhaseDelayMicrosec +
        _interStimDelayMicrosec);
  }

  bool get getEndByDuration {
    return _endByDuration;
  }

  bool get getEndByBurst {
    return _endByBurst;
  }

  bool get getStimForever {
    return _stimForever;
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
  /////////////////////////////////////////////////////////////////////
  // Final start stimulation error check
  String startStimErrorCheck() {
    String formattedWarning = "";
  if (!connected) {
      formattedWarning = formattedWarning + "Device is not connected.\n";
      return formattedWarning;

  }
  if (!_dcMode) {
    if (_phase1TimeMicrosec > UINT32MAX
      || _phase2TimeMicrosec > UINT32MAX
      || _interPhaseDelayMicrosec > UINT32MAX
      || _interStimDelayMicrosec > UINT32MAX) {
      
      formattedWarning = formattedWarning + "Phase time settings are invalid\n";

      }
    var interstim_by_freq = calculate_interstim_from_frequency(_frequency, _phase1TimeMicrosec, _phase2TimeMicrosec, _interPhaseDelayMicrosec);

    if (_calculate_interstim_by_freq 
      &&  interstim_by_freq < 0) {
      formattedWarning = formattedWarning + "Frequency value is invalid.\n";

      }
    if (_burstDurationMicrosec <= getpulsePeriod && !_continuousStim) {
      formattedWarning = formattedWarning + "Burst duration is invalid.\n";
      }

    if (_dutyCyclePercentage <= 0 || _dutyCyclePercentage > 100 && !_continuousStim) {
      formattedWarning = formattedWarning + "Duty Cycle is invalid.\n";
      }

    if (_phase1CurrentMicroAmp > UINT32MAX
      || _phase2CurrentMicroAmp > UINT32MAX) {
      formattedWarning = formattedWarning + "Current values are invalid\n";
      }
  } else {
    if (_dcCurrentTargetMicroAmp > UINT32MAX
      || _dcBurstGap > UINT32MAX
      || _rampUpTime > UINT32MAX
      || _dcHoldTime > UINT32MAX) {
      formattedWarning = formattedWarning + "DC stimulation values are invalid\n";
      }
  }
  bool stimDurationInvalid = stimulation_duration_minimum(_endStimulationMinute, 
                              _endStimulationSeconds,
                              _burstDurationMicrosec, 
                              _dcHoldTime, 
                              _dcBurstGap, 
                              _dcMode);
  if (stimDurationInvalid && _endByDuration) {
    formattedWarning = formattedWarning + "Stimulation duration values are invalid\n";

  }

  return formattedWarning;
  }

  ////////////////////////////////////////////////////////////////////
  Map<String, dynamic> generatePresetMap(String presetname) {

    Map<String, dynamic> presetValuesMap = {
      //fix burst num
      //fix pulse num
      "preset_name": presetname,
      "dc_mode": _dcMode,
      "cathodic_first": _cathodicFirst,
      "phase_one_time": _phase1TimeMicrosec,
      "phase_two_time": _phase2TimeMicrosec,
      "inter_phase_gap": _interPhaseDelayMicrosec,
      "inter_stim_delay": _interStimDelayMicrosec,
      "dac_phase_one": _phase1CurrentMicroAmp,
      "dac_phase_two": _phase2CurrentMicroAmp,
      "ramp_up_time": _rampUpTime,
      "dc_hold_time": _dcHoldTime,
      "dc_curr_target": _dcCurrentTargetMicroAmp,
      "dc_burst_gap": _dcBurstGap,
      "dc_burst_num": _dcBurstNum,
      "end_by_minutes": _endStimulationMinute,
      "end_by_seconds": _endStimulationSeconds,
      "end_by_value": _endbyvalue,
      "end_by_burst": _endByBurst,
      "end_by_duration": _endByDuration,
      "stim_forever": _stimForever,
      "frequency": _frequency,

    };
    return presetValuesMap;
  }




  ///////////////////////////////////////////////////////////////
  ///BLE Section
  /// the following values are use for BLE connection
  /// All BLE functions are stored within this data_provider, and is called by the UI through the provider class.
  /// This allows us to keep BLE things seperated from our presentation layer which means we don't run into
  /// issues when we do stuff like change pages and routes in the UI

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


  bool connected = false;
  bool get getConnected => connected;


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


    // subscription values
    List<int> intArray = [];
    Map<dynamic, dynamic> char_value = {};
    List<dynamic> listValue = [0];

    //Impedence Value

    int impedance = 0;
    
    setImpedance(int newvalue) {
      impedance = newvalue;
      notifyListeners();
    }

    int get getImpedance {
      return impedance;
    } 


  // This function is
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
    characteristicValueStream = WinBle.characteristicValueStream.listen((event) { 
      // TODO: convert CharValue event (notify capture) into list and get error dialogue to
      // pop up when a new notification is sent through
      print("CharValue : $event"); 

        char_value = event;
        listValue = char_value["value"];
        intArray = [];
        listValue.forEach((listItem) {
          intArray.add(listItem);
        });

        setImpedance(impedenceByteCalculation(intArray[2], intArray[1]));

    }); 
  }

  List<int> get getNotifyIntArray => intArray;

  void clearNotifyArray () {
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
      await WinBle.subscribeToCharacteristic(address: address, serviceId: serviceID, characteristicId: charID); 
      print("Subscribe Successfully"); 
    } catch (e) { 
      print("SubscribeCharError : $e"); 
    } 
  }

  unSubscribeToCharacteristic(address, serviceID, charID) async { 
    try { 
      await WinBle.unSubscribeFromCharacteristic(address: address, serviceId: serviceID, characteristicId: charID); 
      print("Unsubscribed Successfully"); 
    } catch (e) { 
      print("UnSubscribeError : $e"); 
    } 
  } 

  disconnect(address) async {
    try {
      await WinBle.disconnect(address);
      connected = false;

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
    _dcMode = presetMap["dc_mode"];
    _cathodicFirst = presetMap["cathodic_first"];
    _phase1TimeMicrosec = presetMap["phase_one_time"];
    _phase2TimeMicrosec= presetMap["phase_two_time"];
    _interPhaseDelayMicrosec = presetMap["inter_phase_gap"];
    _interStimDelayMicrosec = presetMap["inter_stim_delay"];
    _phase1CurrentMicroAmp = presetMap["dac_phase_one"];
    _phase2CurrentMicroAmp = presetMap["dac_phase_two"];
    _rampUpTime = presetMap["ramp_up_time"];
    _dcHoldTime = presetMap["dc_hold_time"];
    _dcCurrentTargetMicroAmp = presetMap["dc_curr_target"];
    _dcBurstGap = presetMap["dc_burst_gap"];
    _dcBurstNum = presetMap["dc_burst_num"];
    _endStimulationMinute = presetMap["end_by_minutes"];
    _endStimulationSeconds = presetMap["end_by_seconds"];
    _endbyvalue = presetMap["end_by_value"];
    _endByDuration = presetMap["end_by_duration"];
    _endByBurst = presetMap["end_by_burst"];
    _stimForever = presetMap["stim_forever"];
    _frequency = presetMap["frequency"];
    setPrepareUpdatePreset(true);
    await Future.delayed(Duration(milliseconds: 10));
    setPrepareUpdatePreset(false);

    setUpdatePreset(true);
    await Future.delayed(Duration(milliseconds: 50));
    setUpdatePreset(false);

  }

}
