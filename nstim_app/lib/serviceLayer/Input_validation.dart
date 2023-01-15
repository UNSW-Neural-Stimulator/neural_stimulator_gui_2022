
import 'package:nstim_app/serviceLayer/math_helper_functions.dart';

String? frequencyInputErrorText(var frequency, var phasetime1, var phasetime2,
    var interphase, int lowerBound) {
      

  if (calculateInterstimByFrequency(frequency, phasetime1, phasetime2, interphase) <
      lowerBound) {
    return "Frequency is too high";
  } else {
    return null;
  }

}



/// stim Duration error check
/// returns true if stim duration is smaller than or equal to  burst duration
/// else returns false
bool stimulationDurationMinimum(stimduration_minutes, stimduration_seconds, burstduration, holdTime, dcBurst, dcMode) {

  var stimduration = (stimduration_minutes * 60) + stimduration_seconds;
  // conversion into microseconds
  stimduration = stimduration * 1000000;

  // If stimulation duration is less than burst duration,returns true as the
  // stim duration is invalid, else returns false
  if (stimduration < burstduration && !dcMode) {
    return true;
  }
  if (stimduration < (holdTime*2 + dcBurst) && dcMode) {
    return true;
  }

  return false;
}