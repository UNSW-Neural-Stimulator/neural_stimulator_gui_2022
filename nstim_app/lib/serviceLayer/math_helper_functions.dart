//This file contains functions that are used to assist in calculations 


int calculateInterstimByFrequency(
    var frequency, var phasetime1, var phasetime2, var interphase) {
  if (frequency == 0.0) {
    return 0;
  }
  var answer = (1000000 / frequency - phasetime1 - phasetime2 - interphase);

  // if answer == 0 then return 0, else give the answer rounded to an integer
  return answer == 0 ? 0 : answer.round();
}