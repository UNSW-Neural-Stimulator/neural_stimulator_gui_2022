import 'package:flutter/services.dart';

///////////////////////////////////////
/// Calculates if the given input is exceeding the minimum and maximum values that are possible.
String? textfieldInputError(int min, int max, String unit, String input) {
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

  if (inputtedNumberAsInt <= min) {
    return "Input must be greater than \n$min µs";
  } else if (inputtedNumberAsInt > max) {
    return "Cannot exceed $max µs";
  } else {
    return null;
  }
}


class NumberRangeFormatter extends TextInputFormatter {
  final int min;
  final int max;

  NumberRangeFormatter({required this.min, required this.max});

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
      return const TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else if (int.parse(curr_value.text) > max) {
      return pre_val;
    } else {
      return curr_value;
    }
  }
}


String? DutyCycleErrorText(int min, int max, String input) {
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
  inputtedNumberAsInt = (inputtedNumber).round();

  if (inputtedNumberAsInt <= min) {
    return "Input must be greater than \n$min";
  } else if (inputtedNumberAsInt > max) {
    return "Cannot exceed $max";
  } else {
    return null;
  }
}

String? GenericErrorString(
    int value_to_check, int upperbound, int lowerbound, String error_string) {
  if (value_to_check > upperbound || value_to_check < lowerbound) {
    return error_string;
  } else {
    return null;
  }
}