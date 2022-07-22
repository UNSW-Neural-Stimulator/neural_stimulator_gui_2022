


import 'package:ns_2022/helper_and_const.dart';

void main() {
  var _phase1TimeMicrosec = 0;
  var _phase2TimeMicrosec = 0;
  var _interPhaseDelayMicrosec = 0;
  var _interStimDelayMicrosec = 0;
  var _continuousStim = false;

  var  _burstPeriodMs = 0;
  var  _dutyCyclePercentage= 0;
  var  _endByDuration= false;
  var  _endByBurst= false;
  var  _stimForever= false;

  var  _endbyvalue= 0;


    var burstDuration = 0.0;
    var pulsePeriod = 0;
    var dutycycle = 0.0;
    var burstperiod = 0;
    var stimduration = 0;
    var burstnumber = 0;
    var pulsenumber = 0;
    var burstfrequency = 0.0;

    pulsePeriod = _phase1TimeMicrosec + _phase2TimeMicrosec + _interPhaseDelayMicrosec + _interStimDelayMicrosec;



    if (!_continuousStim) {
      burstperiod = (_burstPeriodMs) * 1000;
      dutycycle = (_dutyCyclePercentage) / 100;
      burstDuration = dutycycle * burstperiod.round();
      int interburst = (burstperiod - burstDuration.round()).round();

      print("interburst delay is $interburst");
    }
    else {
       int interburst = 0;

        print("interburst delay is $interburst");

    }

    //must implment frequency here TODO

    if (_stimForever) {
      if (_continuousStim) {
        print("burst num = $burst_num");
      } else {
        print("burst num = $pulse_num");

      }
    }
        // if ending by duration, calculate the number of bursts that are needed for the specified duration time
        if (_endByDuration) {
          stimduration = _endbyvalue;

          if (burstDuration != 0) {
            //burst number is calculated as time divided by duration of each burst
            // returns an interger
            burstnumber = stimduration ~/ burstDuration;
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
            stimduration = stimduration * 1000000;


            pulsenumber = stimduration ~/pulsePeriod;
          }
        }
    
    

    //put all new values in serial command input char map

        print("burst num = $burst_num");
        print("burst num = $pulse_num");
}