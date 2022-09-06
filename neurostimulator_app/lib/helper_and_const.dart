import 'dart:io';

import 'package:flutter/material.dart';
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

const dc_burst_gap = 0x11;
const dc_burst_num = 0x12;

///////////////////////////////////////////////////////
///
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

///////////////////////////////////////////
/// Custom textfields with selectable units from microsec to minutes

class CustomTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType inputType;
  final bool obscureText;
  final bool enabled;
  final Function onChanged;
  final int minValue;
  final int maxValue;

  CustomTextField({
    required this.controller,
    required this.onChanged,
    this.inputType = TextInputType.text,
    this.obscureText = false,
    required this.labelText,
    required this.enabled,
    required this.minValue,
    required this.maxValue,
  });

  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String dropdownValue = 'µs';
  var inputtedNumberAsInt;
  double inputtedNumber = 0.0;
  Map dropDownExponents = {'µs': 0, 'ms': 1, 's': 2};
  @override
  Widget build(BuildContext context) {
    String input = widget.controller!.text;
    inputtedNumber = double.tryParse(input) ?? 0.0;
    return Row(children: [
      SizedBox(
        width: 200,
        child: TextField(
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          controller: widget.controller,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r"([0-9]+\.?[0-9]*|\.[0-9]+)")),
          ],
          onChanged: (value) {
            if (value != '') {
              inputtedNumber = double.parse(value);
            }

            switch (dropdownValue) {
              case 'µs':
                inputtedNumberAsInt = (inputtedNumber).round();
                break;
              case 'ms':
                inputtedNumberAsInt = (inputtedNumber * 1000).round();
                break;
              case 's':
                inputtedNumberAsInt = (inputtedNumber * 1000000).round();
                break;
            }

            if (widget.onChanged != null) {
              print(inputtedNumberAsInt.toString());
              widget.onChanged(inputtedNumberAsInt.toString());
            }
          },
          decoration: InputDecoration(
            errorText: input_error_text(widget.minValue, widget.maxValue,
                dropdownValue, widget.controller!.text),
            disabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            labelText: widget.labelText,
            labelStyle: TextStyle(fontSize: 20),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      ),
      SizedBox(
        width: 5,
      ),
      DropdownButton<String>(
        value: dropdownValue,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        onChanged: (String? newValue) {
          setState(() {
            switch (newValue!) {
              case 'µs':
                widget.controller?.text = (inputtedNumber *
                        pow(
                            1000,
                            (dropDownExponents[dropdownValue] -
                                dropDownExponents[newValue])))
                    .toString();

                break;
              case 'ms':
                widget.controller?.text = (inputtedNumber *
                        pow(
                            1000,
                            (dropDownExponents[dropdownValue] -
                                dropDownExponents[newValue])))
                    .toString();
                break;
              case 's':
                widget.controller?.text = (inputtedNumber *
                        pow(
                            1000,
                            (dropDownExponents[dropdownValue] -
                                dropDownExponents[newValue])))
                    .toString();
                break;

            }
            dropdownValue = newValue;
          });
        },
        items: <String>['µs', 'ms', 's']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )
    ]);
  }
}

///////////////////////////////////////
/// Calculates if the given input is exceeding the minimum and maximum values that are possible.
String? input_error_text(int min, int max, String unit, String input) {
  double inputtedNumber = 0;
  int inputtedNumberAsInt = 0;
  // if nothing is in the textfield, then do nothing

  if (input == '') {
    return null;
  }
  // convert the number to an int, based on the unit specified
  else {
    inputtedNumber = double.parse(input);
  }
  switch (unit) {
    case 'µs':
      inputtedNumberAsInt = (inputtedNumber).round();
      break;
    case 'ms':
      inputtedNumberAsInt = (inputtedNumber * 1000).round();
      break;
    case 's':
      inputtedNumberAsInt = (inputtedNumber * 1000000).round();
      break;
    case 'm':
      inputtedNumberAsInt = ((inputtedNumber / 60) * 1000000).round();
      break;
  }

  if (inputtedNumberAsInt < min) {
    return "Input must be greater then $min";
  } else if (inputtedNumberAsInt > max) {
    return "Cannot exceed $max";
  } else {
    return null;
  }
}

String? frequency_input_error(var frequency, var phasetime1, var phasetime2,
    var interphase, int lower_bound) {
  if (calculate_interstim_from_frequency(
          frequency, phasetime1, phasetime2, interphase) <
      lower_bound) {
    return "Frequency is too high";
  } else {
    return null;
  }
}

String? generic_error_string(int value_to_check ,int upperbound, int lowerbound, String error_string) {
  if (value_to_check > upperbound || value_to_check < lowerbound) {
    return error_string;
  } else {
    return null;
  }
}


/// this is used to convert an integer value to a 32 bit byte array so that it can
/// be sent to the firmware via bluetooth low energy
Uint8List bytearray_maker(var code, int value) {
  Uint8List array = Uint8List(5)
    ..buffer.asByteData().setInt32(1, value, Endian.little);
  array[0] = code;
  return array;
}

///////////////////////////////////////////////////////////////////////
/// no too sure what this does, but it comes from the old UI, will need to
/// clarify
int calculate_adv_to_mv(int adc_value) {
  var adc = adc_value.round();
  var pos = adc >= (4096 / 2).round();
  if (pos) {
    int voltage = (((adc - (4096 / 2)) / (4096 / 2)) * 15000).round();
    return voltage;
  } else {
    adc += 2048;
    int voltage = (((adc - (4096 / 2)) / (4096 / 2)) * 15000).round();
    return (-1 * (15000 - voltage)).round();
  }
}

////////////
///Calculates the interstim delay from a frequency input, note that this can give negative output
///which is filtered out as an error by the textfield

int calculate_interstim_from_frequency(
    var frequency, var phasetime1, var phasetime2, var interphase) {
  if (frequency == 0.0) {
    return 0;
  }
  var answer = (1000000 / frequency - phasetime1 - phasetime2 - interphase);

  // if answer == 0 then return 0, else give the answer rounded to an integer
  return answer == 0 ? 0 : answer.round();
}
