//This file contains functions that are used to assist in calculations 


import 'dart:typed_data';

int calculateInterstimByFrequency(
    var frequency, var phasetime1, var phasetime2, var interphase) {
  if (frequency == 0.0) {
    return 0;
  }
  var answer = (1000000 / frequency - phasetime1 - phasetime2 - interphase);

  // if answer == 0 then return 0, else give the answer rounded to an integer
  return answer == 0 ? 0 : answer.round();
}

/// this is used to convert an integer value to a 32 bit byte array so that it can
/// be sent to the firmware via bluetooth low energy
Uint8List bytearray_maker(var code, int value) {
  Uint8List array = Uint8List(5)
    ..buffer.asByteData().setInt32(1, value, Endian.little);
  array[0] = code;
  return array;
}