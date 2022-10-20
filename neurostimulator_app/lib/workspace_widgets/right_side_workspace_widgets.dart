import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ns_2022/workspace_widgets/ErrorDialogue.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import "../data_provider.dart";
import '../util/consts.dart';
import 'package:win_ble/win_ble.dart';
import 'dart:typed_data';
import '../util/helper_functions.dart';

class RightSideInputs extends StatefulWidget {
  final BleDevice device;
  const RightSideInputs({Key? key, required this.device, connection})
      : super(key: key);

  @override
  State<RightSideInputs> createState() => _RightSideInputsState();
}

// Define a corresponding State class.
// This holds the data related to the following input widgets
class _RightSideInputsState extends State<RightSideInputs> {
  late BleDevice device = widget.device;

  // Create text controllers and use them to retrieve the current value
  // of the TextFields.
  TextEditingController? _phase1CurrentTextfield;
  TextEditingController? _phase2CurrentTextfield;
  TextEditingController? _dcCurrentTargetTextfield;
  TextEditingController? _dcHoldTimeTextfield;
  TextEditingController? _rampUpTimeTextfield;
  TextEditingController? _dcBurstGapTextfield;
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
    final Data myProvider = Provider.of<Data>(context);
    var burstduration = Provider.of<Data>(context).getBurstDuration;
    // Calls error checking function to assert stimduration is larger than burst duration
    if (stimulation_duration_minimum(
        myProvider.getendbyminutes,
        myProvider.getendbyseconds,
        burstduration,
        myProvider.getRampUpTime,
        myProvider.getDCHoldTime,
        myProvider.getDcMode)) {
      return 'Must be > burst duration';
    }
    // return null if the text is valid
    return null;
  }

  String? get _durationMinutesErrorText {
    final Data myProvider = Provider.of<Data>(context);
    // Calls error checking function to assert stimduration is larger than burst duration
    if (stimulation_duration_minimum(
        myProvider.getendbyminutes,
        myProvider.getendbyseconds,
        myProvider.getBurstDuration,
        myProvider.getRampUpTime,
        myProvider.getDCHoldTime,
        myProvider.getDcMode)) {
      return 'Invalid Duration';
    }
    // return null if the text is valid
    return null;
  }

  /// initstate is called when the widget is built, it initialises all the textfields
  /// with their respective values in provider.
  @override
  void initState() {
    device = widget.device;
    final Data myProvider = Provider.of<Data>(context, listen: false);
    super.initState();
    _phase1CurrentTextfield =
        TextEditingController(text: myProvider.getPhase1Current.toString());
    _phase2CurrentTextfield =
        TextEditingController(text: myProvider.getPhase2Current.toString());
    _dcCurrentTargetTextfield =
        TextEditingController(text: myProvider.getDCCurrentTarget.toString());
    _dcHoldTimeTextfield =
        TextEditingController(text: myProvider.getDCHoldTime.toString());
    _dcBurstGapTextfield =
        TextEditingController(text: myProvider.getDCBurstGap.toString());
    _rampUpTimeTextfield =
        TextEditingController(text: myProvider.getRampUpTime.toString());
    _endByMinutesTextfield =
        TextEditingController(text: myProvider.getendbyminutes.toString());
    _endBySecondsTextfield =
        TextEditingController(text: myProvider.getendbyseconds.toString());
    _endStimulationTextField =
        TextEditingController(text: myProvider.getendByValue);
    List<bool> fixedLengthList;
  }

  // this calls a rebuild whenever a change is made, it is required for the toggle box
  @override
  void didChangeDependencies() {
    fixedLengthList = [
      Provider.of<Data>(context).endByDuration,
      Provider.of<Data>(context).endByBurst,
      Provider.of<Data>(context).stimilateForever
    ];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _phase1CurrentTextfield?.dispose();
    _phase2CurrentTextfield?.dispose();
    _dcCurrentTargetTextfield?.dispose();
    _dcHoldTimeTextfield?.dispose();
    _dcBurstGapTextfield?.dispose();
    _rampUpTimeTextfield?.dispose();
    _endStimulationTextField?.dispose();
    _endByMinutesTextfield?.dispose();
    _endBySecondsTextfield?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Data myProvider = Provider.of<Data>(context);
    var endStimulationTitle = Provider.of<Data>(context).endByDurationTitle;
    var value_one = "";

    if (myProvider.getUpdatePreset) {
      setState(() {
        _phase1CurrentTextfield =
            TextEditingController(text: myProvider.getPhase1Current.toString());
        _phase2CurrentTextfield =
            TextEditingController(text: myProvider.getPhase2Current.toString());
        _dcCurrentTargetTextfield = TextEditingController(
            text: myProvider.getDCCurrentTarget.toString());
        _dcHoldTimeTextfield =
            TextEditingController(text: myProvider.getDCHoldTime.toString());
        _dcBurstGapTextfield =
            TextEditingController(text: myProvider.getDCBurstGap.toString());
        _rampUpTimeTextfield =
            TextEditingController(text: myProvider.getRampUpTime.toString());
        _endByMinutesTextfield =
            TextEditingController(text: myProvider.getendbyminutes.toString());
        _endBySecondsTextfield =
            TextEditingController(text: myProvider.getendbyseconds.toString());
        _endStimulationTextField =
            TextEditingController(text: myProvider.getendByValue);
      });
    }

    return Column(
      children: [
        if (myProvider.getDcMode && myProvider.getConnected)
          SizedBox(
            height: 45,
            child: Row(
              children: const [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber, size: 45),
                Text(
                  "    CAUTION: DC stimulation can be unsafe if not used appropriately.",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                )
              ],
            ),
          )
        else
          const SizedBox(
            height: 45,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterSwitch(
              activeColor: Colors.blue,
              inactiveColor: Colors.grey,
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.white,
              activeTextFontWeight: FontWeight.w400,
              inactiveTextFontWeight: FontWeight.w400,
              activeText: "DC mode on",
              inactiveText: "DC mode off",
              width: 150,
              height: 40,
              showOnOff: true,
              onToggle: (bool dcmode) {
                Provider.of<Data>(context, listen: false).toggleDC(dcmode);
              },
              value: Provider.of<Data>(context)
                  .getDcMode, // remove `listen: false`
            ),
            const SizedBox(
              width: 50,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                minimumSize: const Size(150, 50),
              ),

              onPressed: () async {
                String allErrors = myProvider.startStimErrorCheck();
                if (allErrors != "") {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title:
                                Text('Please address the following warnings: '),
                            content: SingleChildScrollView(
                              child: errorDialogue(description: allErrors),
                            ));
                      });
                } else {
                  Provider.of<Data>(context, listen: false)
                      .prepare_stimulation_values();
                  var serial_command_inputs =
                      Provider.of<Data>(context, listen: false)
                          .get_serial_command_input_char;
                  for (var value in serial_command_inputs.values) {
                    myProvider.writeCharacteristic(device.address, SERVICE_UUID,
                        SERIAL_COMMAND_INPUT_CHAR_UUID, value, true);
                    await Future.delayed(
                        const Duration(milliseconds: 1), () {});
                  }
                }
              },
              icon: const Icon(
                Icons.bolt,
                size: 24.0,
              ),
              label: const Text('start',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w400)), // <-- Text
            ),
            const SizedBox(
              width: 50,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                minimumSize: const Size(150, 50),
              ),

              onPressed: () {
                myProvider.writeCharacteristic(
                    device.address,
                    SERVICE_UUID,
                    SERIAL_COMMAND_INPUT_CHAR_UUID,
                    Uint8List.fromList([2, 0, 0, 0, 0]),
                    true);
              },
              icon: const Icon(
                Icons.stop_outlined,
                size: 24.0,
              ),
              label: const Text('stop',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w400)), // <-- Text
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: TextField(
                    enabled: !myProvider.getDcMode && myProvider.getConnected,
                    keyboardType: TextInputType.number,
                    controller: _phase1CurrentTextfield,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(18),
                    ],
                    onChanged: (value) {
                      myProvider.setphase1current(value);
                      print(value);
                    },
                    decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        labelText: 'Phase 1 Current (µA)',
                        labelStyle: TextStyle(fontSize: 20),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        errorText: generic_error_string(
                            myProvider.getPhase1Current,
                            3000,
                            0,
                            "Must be less than 3000")),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: TextField(
                    enabled: !myProvider.getDcMode && myProvider.getConnected,
                    keyboardType: TextInputType.number,
                    controller: _phase2CurrentTextfield,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(18),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      myProvider.setphase2current(value);
                    },
                    decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        labelText: 'Phase 2 Current (µA)',
                        labelStyle: TextStyle(fontSize: 20),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        errorText: generic_error_string(
                            myProvider.getPhase2Current,
                            3000,
                            0,
                            "Must be less than 3000")),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _dcCurrentTargetTextfield,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(18),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      myProvider.setDCCurrentTarget(value);
                    },
                    enabled: myProvider.getDcMode && myProvider.getConnected,
                    decoration: InputDecoration(
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        labelText: 'DC Current Target (µA)',
                        labelStyle: TextStyle(fontSize: 20),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue)),
                        errorText: generic_error_string(
                            myProvider.getDCCurrentTarget,
                            3000,
                            0,
                            "Must be less than 3000")),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    enabled: myProvider.getDcMode && myProvider.getConnected,
                    controller: _dcHoldTimeTextfield,
                    onChanged: (value) {
                      myProvider.setDCHoldTime(value);
                    },
                    labelText: 'DC Hold Time',
                    minValue: 0,
                    maxValue: UINT32MAX,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    enabled: myProvider.getDcMode && myProvider.getConnected,
                    controller: _rampUpTimeTextfield,
                    onChanged: (value) {
                      myProvider.setrampUpTime(value);
                    },
                    labelText: 'Ramp Up/Down Time ',
                    minValue: 0,
                    maxValue: UINT32MAX,
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    enabled: myProvider.getDcMode && myProvider.getConnected,
                    controller: _dcBurstGapTextfield,
                    onChanged: (value) {
                      myProvider.setDCBurstGap(value);
                    },
                    labelText: 'DC Burst Gap',
                    minValue: 0,
                    maxValue: UINT32MAX,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          height: 250,
          child: Column(
            children: [
              const Text("End stimulation by:"),
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
                    Provider.of<Data>(context, listen: false)
                        .toggleEndByDuration(true);
                    Provider.of<Data>(context, listen: false)
                        .toggleEndByBurst(false);
                    Provider.of<Data>(context, listen: false)
                        .toggleStimForever(false);
                  } else if (index == 1) {
                    Provider.of<Data>(context, listen: false)
                        .toggleEndByDuration(false);
                    Provider.of<Data>(context, listen: false)
                        .toggleEndByBurst(true);
                    Provider.of<Data>(context, listen: false)
                        .toggleStimForever(false);
                  } else if (index == 2) {
                    Provider.of<Data>(context, listen: false)
                        .toggleEndByDuration(false);
                    Provider.of<Data>(context, listen: false)
                        .toggleEndByBurst(false);
                    Provider.of<Data>(context, listen: false)
                        .toggleStimForever(true);
                  }
                },
                isSelected: fixedLengthList,
              ),
              const SizedBox(height: 5),
              Text("$endStimulationTitle"),
              const SizedBox(height: 5),
              if (Provider.of<Data>(context).endByBurst)
                SizedBox(
                  width: 250,
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _endStimulationTextField,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      num_range_formatter(min: 1, max: UINT32MAX)
                    ],
                    onChanged: (value) {
                      myProvider.setendbyvalue(value);
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
              if (Provider.of<Data>(context).stimilateForever)
                const SizedBox(width: 250, height: 50),
              if (Provider.of<Data>(context).endByDuration)
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
                          num_range_formatter(min: 0, max: 1091)
                        ],
                        onChanged: (value) {
                          myProvider.setendbystimulationminute(value);
                        },
                        decoration: InputDecoration(
                          labelText: "Minutes",
                          enabled: myProvider.getConnected,
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
                        enabled: myProvider.getConnected,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          num_range_formatter(min: 0, max: 60)
                        ],
                        onChanged: (value) {
                          myProvider.setendbystimulationseconds(value);
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
                // TODO: once impedence check is implemented this should be uncommented. Includes 
                // a button with its Onpressed function left empty 
              // SizedBox(height: 5),
              // SizedBox(
              //   width: 250,
              //   child: ElevatedButton.icon(
              //     style: ElevatedButton.styleFrom(
              //       primary: Colors.red,
              //       minimumSize: const Size(150, 50),
              //     ),

              //     onPressed: () {
              //       //This shall be updated to run and impedence check
              //     },

              //     icon: const Icon(
              //       Icons.bolt,
              //       size: 24.0,
              //     ),
              //     label: const Text('Impedence check',
              //         style: TextStyle(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w400)), // <-- Text
              //   ),
              // ),
            ],
          ),
        ),
        Container(
          width: 500,
          height: 1, // Thickness
          color: Colors.grey,
        )
      ],
    );
  }
}
