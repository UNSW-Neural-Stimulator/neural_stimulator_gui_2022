import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:math';


///UUIDs
///Serial Command Input Char UUID is the characteristic which we use to write values into.

const SERIAL_COMMAND_INPUT_CHAR_UUID = "c4583a38-ef5a-4526-882f-ea5f5d91dbf3";
const SERVICE_UUID = "13d47a92-3e31-4bde-89b8-77e55b659c76";

///UINT32MAX is the highest number we can send as a parameter to the firmware

const UINT32MAX = 4294967295;

//the values below include codes for bytearrays that we send to firmware.
Uint8List start_bytearray = Uint8List.fromList([1, 0, 0, 0, 0]);
Uint8List stop_bytearray = Uint8List.fromList([2, 0, 0, 0, 0]);
const stim_type = 0x03;
const anodic_cathodic = 0x04;
const phase_one_time = 0x05;
const phase_two_time = 0x06;
const inter_phase_gap = 0x07;
const inter_stim_delay = 0x08;
const inter_burst_delay = 0x09;
const pulse_num = 0x0A;
const burst_num = 0x0B;
const dac_phase_one = 0x0C;
const dac_phase_two = 0x0D;
const ramp_up_time = 0x0E;
const dc_hold_time = 0x0F;
const dc_curr_target = 0x10;
const dc_burst_gap = 0x11;
const dc_burst_num = 0x12;

///////////////////////////////////////////////////////

class num_range_formatter extends TextInputFormatter {
  final int min;
  final int max;

  num_range_formatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue pre_val,
    TextEditingValue curr_value,
  ) {
    if (curr_value.text == '') {
      return curr_value;
    }
    int? success = int.tryParse(curr_value.text);
    if (success == null) {
      return curr_value;
    }

    if (int.parse(curr_value.text) < min) {
      return TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else if (int.parse(curr_value.text) > max) {
      return pre_val;
    } else {
      return curr_value;
    }
  }
}
