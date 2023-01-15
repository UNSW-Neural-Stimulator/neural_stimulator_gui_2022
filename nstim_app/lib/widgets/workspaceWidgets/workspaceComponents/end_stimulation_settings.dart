import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nstim_app/providers/service_layer_provider.dart';
import 'package:nstim_app/serviceLayer/Input_validation.dart';
import 'package:nstim_app/util/textfield_helper_functions.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:win_ble/win_ble.dart';

import '../../../providers/bluetooth_le_provider.dart';
import '../../../util/consts.dart';

class EndStimulationSettings extends StatefulWidget {
  final BleDevice device;
  const EndStimulationSettings({Key? key, required this.device}) : super(key: key);
  @override
  _EndStimulationSettingsState createState() => _EndStimulationSettingsState();
}

class _EndStimulationSettingsState extends State<EndStimulationSettings> {
  late BleDevice device = widget.device;

  // these two text controllers are to recieve the minutes and seconds
  // for the stimulation duration, I put them below as their inputs are handled
  // differently, instead of being "saved" straight into provider, some
  // calculations take place to convert their units
  TextEditingController? _endByMinutesTextfield;
  TextEditingController? _endBySecondsTextfield;
  // end stimulation textfield for ending by burst number, this is done seperately
  // to the duration by time inputs as it takes in different value types
  TextEditingController? _endStimulationTextField;
  // Fixed length list is to control the end by stimulation toggle box
  List<bool> fixedLengthList = [true, false, false];



  // the following duration error text functions are for the minute and second textfields
  // they have independent errors functions as this helps with formatting the page,
  // Since they have small textfield sizes we can't fit the entire error message
  // so they are handled independently and appear concatated visually to the user

  String? get _durationSecondsErrorText {
    final ServiceLayerProvider serviceLayerProvider = Provider.of<ServiceLayerProvider>(context);
    var burstduration = Provider.of<ServiceLayerProvider>(context).retrieveIntValue("burstDuration");
    // Calls error checking function to assert stimduration is larger than burst duration
    if (stimulationDurationMinimum(
        serviceLayerProvider.retrieveIntValue("durationMinutes"),
        serviceLayerProvider.retrieveIntValue("durationSeconds"),
        burstduration,
        serviceLayerProvider.retrieveIntValue("RampUpTime"),
        serviceLayerProvider.retrieveIntValue("DCHoldtime"),
        serviceLayerProvider.retrieveBoolValue("DCModeOn"))) {
      return 'Must be > burst duration';
    }
    // return null if the text is valid
    return null;
  }

  String? get _durationMinutesErrorText {
    final ServiceLayerProvider serviceLayerProvider = Provider.of<ServiceLayerProvider>(context);
    // Calls error checking function to assert stimduration is larger than burst duration
    var burstduration = Provider.of<ServiceLayerProvider>(context).retrieveIntValue("burstDuration");
    // Calls error checking function to assert stimduration is larger than burst duration
    if (stimulationDurationMinimum(
        serviceLayerProvider.retrieveIntValue("durationMinutes"),
        serviceLayerProvider.retrieveIntValue("durationSeconds"),
        burstduration,
        serviceLayerProvider.retrieveIntValue("RampUpTime"),
        serviceLayerProvider.retrieveIntValue("DCHoldtime"),
        serviceLayerProvider.retrieveBoolValue("DCModeOn"))) {
    // return null if the text is valid
    return null;
  }
  }



  @override
  void initState() {
        device = widget.device;
final ServiceLayerProvider serviceLayerProvider =
        Provider.of<ServiceLayerProvider>(context, listen: false);
    super.initState();
    _endByMinutesTextfield = TextEditingController(
        text: serviceLayerProvider
            .retrieveIntValue("durationMinutes")
            .toString());
    _endBySecondsTextfield = TextEditingController(
        text: serviceLayerProvider
            .retrieveIntValue("durationSeconds")
            .toString());
    _endStimulationTextField = TextEditingController(
        text:
            serviceLayerProvider.retrieveIntValue("endByBurstNum").toString());
    List<bool> fixedLengthList;
  }

    // this calls a rebuild whenever a change is made, it is required for the toggle box
  @override
  void didChangeDependencies() {
    fixedLengthList = [
      Provider.of<ServiceLayerProvider>(context)
          .retrieveBoolValue("endByDurtion"),
      Provider.of<ServiceLayerProvider>(context)
          .retrieveBoolValue("endByBurst"),
      Provider.of<ServiceLayerProvider>(context)
          .retrieveBoolValue("stimulateForever")
    ];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _endStimulationTextField?.dispose();
    _endByMinutesTextfield?.dispose();
    _endBySecondsTextfield?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BluetoothLEProvider bluetoothLEProvider =
        Provider.of<BluetoothLEProvider>(context);
    final ServiceLayerProvider serviceLayerProvider =
        Provider.of<ServiceLayerProvider>(context);

    var endStimulationTitle = Provider.of<ServiceLayerProvider>(context).endStimulationTitle;

    return 
    Container(
          height: 250,
          child: Column(
            children: [

              Text(
            "End stimulation by:",
            style: Theme.of(context).textTheme.headline2,
          ),
              const SizedBox(
                height: 10,
              ),

              ToggleButtons(
                constraints: const BoxConstraints(minWidth: 160, minHeight: 50),
                children: <Widget>[
                  const Text("Stimulation Duration"),
                  const Text("Number of Bursts"),
                  const Text("Stimulate Forever"),
                ],
                onPressed: (int index) {
                  if (index == 0) {
                    //Basically what's happening here is that we are toggling the selected value as chosen
                    // in data provider and making all the other ones false
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("endByDurtion",true);
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("endByBurst", false);
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("stimulateForever",false);
                  } else if (index == 1) {
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("endByDurtion",false);
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("endByBurst", true);
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("stimulateForever",false);
                  } else if (index == 2) {
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("endByDurtion",false);
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("endByBurst", false);
                    Provider.of<ServiceLayerProvider>(context, listen: false)
                        .setBooleanValue("stimulateForever",true);
                  }
                },
                isSelected: fixedLengthList,
              ),
              const SizedBox(height: 5),
              Text("$endStimulationTitle"),
              const SizedBox(height: 5),
              if (Provider.of<ServiceLayerProvider>(context).retrieveBoolValue("endByBurst"))
                SizedBox(
                  width: 250,
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _endStimulationTextField,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      NumberRangeFormatter(min: 1, max: UINT32MAX)
                    ],
                    onChanged: (value) {
                      serviceLayerProvider.setIntegerValue("endByBurstNum",value);
                    },
                    decoration: const InputDecoration(
                      hintText: "1",
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                    ),
                  ),
                ),
              if (Provider.of<ServiceLayerProvider>(context).retrieveBoolValue("stimulateForever"))
                const SizedBox(width: 250, height: 50),
              if (Provider.of<ServiceLayerProvider>(context).retrieveBoolValue("endByDurtion"))
                SizedBox(
                  width: 300,
                  height: 70,
                  child: Row(children: [
                    Flexible(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _endByMinutesTextfield,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          NumberRangeFormatter(min: 0, max: 1091)
                        ],
                        onChanged: (value) {
                          serviceLayerProvider.setIntegerValue("durationMinutes",value);
                        },
                        decoration: InputDecoration(
                          labelText: "Minutes",
                          enabled: bluetoothLEProvider.getConnected,
                          errorText: _durationMinutesErrorText,
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: _endBySecondsTextfield,
                          enabled: bluetoothLEProvider.getConnected,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          NumberRangeFormatter(min: 0, max: 60)
                        ],
                        onChanged: (value) {
                          serviceLayerProvider.setIntegerValue("durationSeconds",value);
                        },
                        decoration: InputDecoration(
                          labelText: "Seconds",
                          errorText: _durationSecondsErrorText,
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                        ),
                      ),
                    )
                  ]),
                ),
          
            ],
          ),
        );
  }
}
