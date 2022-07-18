import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:math';
/////////////////////
///Constants and other values that are needed for ble

///UUIDs
///Serial Command Input Char UUID is the characteristic which we use to write values into.
const SERIAL_COMMAND_INPUT_CHAR_UUID = "c4583a38-ef5a-4526-882f-ea5f5d91dbf3";
const SERVICE_UUID = "13d47a92-3e31-4bde-89b8-77e55b659c76";
////////////////////////////////////////////////////////////////
///UINT32MAX is the highest number we can send as a parameter to the firmware
const UINT32MAX = 4294967295;

//the values below include codes for bytearrays that we send to firmware.
Uint8List start_bytearray = Uint8List.fromList([1, 0, 0, 0, 0]);
Uint8List stop_bytearray = Uint8List.fromList([2, 0, 0, 0, 0]);
const stim_type = 0x03;
const anodic_cathodic = 0x04;
const phase_one_time = 0x05;
const phase_two_time = 0x06;

//burst phase gap
const inter_phase_gap = 0x07;

//interpulsegap?
const inter_stim_delay = 0x08;


//interburstgap
const inter_burst_delay = 0x09;
//burst pulse num
const pulse_num = 0x0A;

const burst_num = 0x0B;

// these two are now burst phase 1 curr and burst phase 2 curr
const dac_phase_one = 0x0C;
const dac_phase_two = 0x0D;

const ramp_up_time = 0x0E;
const dc_hold_time = 0x0F;
const dc_curr_target = 0x10;


// const ramp_up = 0x10;
// const short_electrode = 0x11;
// const record_freq = 0x12;
// Uint8List start_recording = Uint8List.fromList([0x13, 0, 0, 0, 0]);
// Uint8List stop_recording = Uint8List.fromList([0x14, 0, 0, 0, 0]);
// Uint8List electrode_voltage = Uint8List.fromList([0x15, 0, 0, 0, 0]);
// const elec_offset = 0x16;
// const show_dac = 0x17;
// const return_idle = 0x18;
// Uint8List check_state = Uint8List.fromList([0x19, 0, 0, 0, 0]);
// const dc_mode = 0x20;


//
//need to add hold time

//need to add dc curr target

///////////////////////////////////////////////////////
/// The
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
    } else if (int.parse(curr_value.text) < min) {
      return TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return int.parse(curr_value.text) > max ? pre_val : curr_value;
    }
  }
}

Uint8List bytearray_maker(var code, int value) {
  Uint8List array =
      Uint8List(5)..buffer.asByteData().setInt32(1, value, Endian.little);
  array[0] = code;
  return array;

}

///////////////////////////////////////////////////////////////////////
/// functions from old UI
/// 
int calculate_adv_to_mv(int adc_value) {
  var adc = adc_value.round();
  var pos = adc >= (4096/2).round();
  if (pos) {
    int voltage =  (((adc - (4096 / 2)) / (4096 / 2)) * 15000).round();
    return voltage;
  }
  else {
    adc += 2048;
    int voltage = (((adc - (4096 / 2)) / (4096 / 2)) * 15000).round();
    return (-1*(15000 - voltage)).round();
  }

}

int calculate_interstim_from_frequency(int frequency, int phasetime1, int phasetime2, int interphase) {
  var answer = (1000000 / frequency - phasetime1 - phasetime2 - interphase);
  return answer != 0 ? 0:answer.round();

  }