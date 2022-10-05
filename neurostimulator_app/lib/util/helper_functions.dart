import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:provider/provider.dart';
import "../data_provider.dart";
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
    final Data myProvider = Provider.of<Data>(context, listen: false);
    if (myProvider.getPrepareUpdatePreset) {
      dropdownValue = 'µs';
    }
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
            LengthLimitingTextInputFormatter(20),
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
    return "Input must be greater then \n$min µs";
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

String? generic_error_string(
    int value_to_check, int upperbound, int lowerbound, String error_string) {
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


/// stim Duration error check
/// returns true if stim duration is larger than or equal to  burst duration
/// else returns false
bool stimulation_duration_minimum(stimduration_minutes, stimduration_seconds, burstduration) {

  var stimduration = (stimduration_minutes * 60) + stimduration_seconds;
  // conversion into microseconds
  stimduration = stimduration * 1000000;

  // If stimulation duration is less than burst duration,returns true as the
  // stim duration is invalid, else returns false
  if (stimduration < burstduration) {
    return true;
  }
  return false;
}
