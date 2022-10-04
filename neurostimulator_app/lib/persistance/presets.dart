import 'package:localstorage/localstorage.dart';
import "dart:convert";
import 'package:provider/provider.dart';

import '../data_provider.dart';

void makeNewPreset() {
  //Take in preset name

  //Check if name is taken

  //Save all current values from provider
  Map<String, dynamic> presetValuesMap = {
    "stim_type": 0,
    "anodic_cathodic": 0,
    "phase_one_time": 0,
    "phase_two_time": 0,
    "inter_phase_gap": 0,
    "inter_stim_delay": 0,
    "inter_burst_delay": 0,
    "burst_num": 0,
    "pulse_num": 0,
    "dac_phase_one": 0,
    "dac_phase_two": 0,
    "ramp_up_time": 0,
    "dc_hold_time": 0,
    "dc_curr_target": 0,
    "dc_burst_gap": 0,
    "dc_burst_num": 0,
  };

  String mr_json = jsonEncode(presetValuesMap);

  Map<String, dynamic> presetsMap = new Map();

  presetsMap.addEntries([MapEntry("preset", presetValuesMap)]);
  String mr_json2 = jsonEncode(presetsMap);
}
