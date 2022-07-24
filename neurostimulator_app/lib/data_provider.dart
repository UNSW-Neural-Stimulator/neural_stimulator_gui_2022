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
  var _phase1TimeMicrosec = 1000;
  var _interPhaseDelayMicrosec = 1000;
  var _phase2TimeMicrosec = 1000;
  var _interStimDelayMicrosec = 1000;
  var _burstDurationMs = 0;
  var _dutyCyclePercentage = 0;
  var _frequency = 0;

  //dc mode related values
  var _rampUpTime = 0;
  var _dcHoldTime = 0;
  var _dcCurrentTargetMicroAmp = 1000;


  //ints for right side of workspace
  var _phase1CurrentMicroAmp = 1500;
  var _phase2CurrentMicroAmp = 3000;
  //end stimulation
  // var _endByDurationValue = 1;
  // var _endByBurstValue = 1;

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
    "dc_hold_time":  Uint8List.fromList([dc_hold_time, 0, 0, 0, 0]),
    "dc_curr_target":  Uint8List.fromList([dc_curr_target, 232, 3, 0, 0]),
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
    notifyListeners();
  }


// continous stimulation

  void toggleburstcont(bool continuous) {
    _continuousStim = !continuous;
    print("burstmode is equal to $_continuousStim");
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

  setfrequency(String frequencyinput) {
    _frequency = int.tryParse(frequencyinput) ?? defaultValue;
    _interStimDelayMicrosec = calculate_interstim_from_frequency(_frequency, _phase1TimeMicrosec, _phase2TimeMicrosec, _interPhaseDelayMicrosec);
    notifyListeners();
  }

  setphase1(String phase1TimeStringFromTextfield) {
    _phase1TimeMicrosec = int.tryParse(phase1TimeStringFromTextfield) ?? 1000;
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

//TODO, what is burst Duration, and what does it do
  setburstduration(String burstDurationFromTextField) {
    _burstDurationMs = int.tryParse(burstDurationFromTextField) ?? defaultValue;
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

////////////////////////////////////////////////////////////////////////////////////////
  setendbyvalue(String endby) {
    _endbyvalue = int.tryParse(endby) ?? 1;
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
    return _burstDurationMs;
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


  int get getFrequency {
    return _frequency;
  }

  int get getDCCurrentTarget {
    return _dcCurrentTargetMicroAmp;
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

  ///////////////////////////////////////////////////////////////////////////////////
  ///end of get functions

/////////////
  ///Function that updates the serial command input char map before it is sent to the stimulator
  void prepare_stimulation_values() {

    int temporary_bool_to_int = 0;
    temporary_bool_to_int = _cathodicFirst ? 1 : 0;
    print("anodic cathodic is $temporary_bool_to_int");
    serial_command_input_char["anodic_cathodic"] =
        Uint8List.fromList([anodic_cathodic, temporary_bool_to_int, 0, 0, 0]);

    // DEPRECATED AS FOR NSTIM FIRMWARE
    // temporary_bool_to_int = !_dcMode ? 1 : 0;
    // serial_command_input_char["dc_mode"] =
    //     Uint8List.fromList([dc_mode, 0, 0, 0, temporary_bool_to_int]);

    temporary_bool_to_int = _dcMode ? 1 : 0;
    serial_command_input_char["stim_type"] =
        Uint8List.fromList([stim_type, temporary_bool_to_int, 0, 0, 0]);

    print("hold time : $_dcHoldTime");
    print("dc curr targ: $_dcCurrentTargetMicroAmp");
    print("ramp_up = $_rampUpTime");
    serial_command_input_char["ramp_up_time"] =
        bytearray_maker(ramp_up_time, _rampUpTime);

    serial_command_input_char["dc_curr_target"] =
        bytearray_maker(dc_curr_target, _dcCurrentTargetMicroAmp);


            serial_command_input_char["dc_hold_time"] =
        bytearray_maker(dc_hold_time, _dcHoldTime);



    serial_command_input_char["phase_one_time"] =
        bytearray_maker(phase_one_time, _phase1TimeMicrosec);

    serial_command_input_char["inter_phase_gap"] =
        bytearray_maker(inter_phase_gap, _interPhaseDelayMicrosec);

    serial_command_input_char["phase_two_time"] =
        bytearray_maker(phase_two_time, _phase2TimeMicrosec);

    serial_command_input_char["inter_stim_delay"] =
        bytearray_maker(inter_stim_delay, _interStimDelayMicrosec);


    //check which curr value should be negative based off cathodic and anodic

    if (!_cathodicFirst) {

      if (_phase1CurrentMicroAmp < 1) {
        _phase1CurrentMicroAmp = _phase1CurrentMicroAmp * -1;
      }

      if (_phase2CurrentMicroAmp > 1) {
        _phase2CurrentMicroAmp = _phase2CurrentMicroAmp * -1;
      }
    }
    else {

      if (_phase2CurrentMicroAmp < 1) {
        _phase2CurrentMicroAmp = _phase2CurrentMicroAmp * -1;
      }

      if (_phase1CurrentMicroAmp > 1) {
        _phase1CurrentMicroAmp = _phase1CurrentMicroAmp * -1;
      }
    }



    print("cathodic_first = $_cathodicFirst");
    print(_phase1CurrentMicroAmp);
    print(_phase2CurrentMicroAmp);

    serial_command_input_char["dac_phase_one"] =
        bytearray_maker(dac_phase_one, _phase1CurrentMicroAmp);
    serial_command_input_char["dac_phase_two"] =
        bytearray_maker(dac_phase_two, _phase2CurrentMicroAmp);

    /// Calculating amount of bursts and pulses based on stimulation ending method

    ///I burstmode is on, calculate burstduration, duty cycle, burst duration and interburst delay
    var burstperiod = 0.0;
    var pulsePeriod = 0;
    var dutycycle = 0.0;
    var burstDuration = 0.0;
    var stimduration = 0;
    var burstnumber = 0;
    var pulsenumber = 0;
    var burstfrequency = 0.0;

    pulsePeriod = _phase1TimeMicrosec + _phase2TimeMicrosec + _interPhaseDelayMicrosec + _interStimDelayMicrosec;



    if (!_continuousStim) {
      burstDuration = (_burstDurationMs) * 1000;
      dutycycle = (_dutyCyclePercentage) / 100;
      burstperiod = (burstDuration) / (dutycycle);
      int interburst = (burstperiod - burstDuration.round()).round();

      serial_command_input_char["inter_burst_delay"] =
          bytearray_maker(inter_burst_delay, interburst);
    }
    else {
       int interburst = 0;

      serial_command_input_char["inter_burst_delay"] =
          bytearray_maker(inter_burst_delay, interburst);
    }

    //must implment frequency here TODO

    if (_stimForever) {
      if (_continuousStim) {
        serial_command_input_char["burst_num"] = bytearray_maker(burst_num, 0);
      } else {
        serial_command_input_char["pulse_num"] = bytearray_maker(pulse_num, 0);
        // serial_command_input_char["pulse_num_in_one_burst"] =
        //     bytearray_maker(pulse_num_in_one_burst, 0);
      }
    }
    if(!_stimForever) {
        // change stimduration units from minutes to micros
		stimduration = _endbyvalue;
		stimduration = stimduration * 1000000 * 60;

        // if ending by duration, calculate the number of bursts that are needed for the specified duration time
        if (_endByDuration) {
          if (burstDuration != 0) {
            //burst number is calculated as time divided by duration of each burst
            // returns an interger
            burstnumber = stimduration ~/ burstperiod;
          } else {
            //in adherrance to old ui, returns zero, but I want to add an
            // error case
            burstnumber = 0;
          }
        }
        // if ending by number of bursts, the user inputs the number of bursts
        if (_endByBurst) {
          burstnumber = _endbyvalue;
        } else {
          //in adherrance to old ui, returns zero, but I want to add an
          // error case
          burstnumber = 0;
        }
      
      /// not too sure whats going on in the logic below, but it is in adherrance to 
      /// the old ui

        // if burst mode is slected the pulse number and is calculated
        // based on us
        if (!_continuousStim && pulsePeriod != 0) {

            if (burstDuration != 0 && burstperiod != 0) {
              pulsenumber = burstDuration ~/ pulsePeriod;
            }
            if (burstDuration != 0) {
              burstfrequency = 10000000 / burstDuration;
            }
        }
      
        else {
          if (stimduration != 0 && pulsePeriod != 0) {

            pulsenumber = stimduration ~/pulsePeriod;
          }
        }
    
    }


    //put all new values in serial command input char map

  serial_command_input_char["burst_num"] =
           bytearray_maker(burst_num, burstnumber);
  serial_command_input_char["pulse_num"] =
           bytearray_maker(pulse_num, pulsenumber);
  
  // serial_command_input_char["pulse_num_in_one_burst"] =
  //          bytearray_maker(pulse_num_in_one_burst, pulsenumber);

  //////////////////////////////////////////////////////////////
  ///Bluetooth Low Energy













  }
}




