import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import "../data_provider.dart";
import '../helper_and_const.dart';
import 'package:win_ble/win_ble.dart';
import 'dart:typed_data';

class RightSideInputs extends StatefulWidget {
  final BleDevice device;
  const RightSideInputs({Key? key, required this.device, connection})
      : super(key: key);

  @override
  State<RightSideInputs> createState() => _RightSideInputsState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _RightSideInputsState extends State<RightSideInputs> {
  late BleDevice device = widget.device;

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  TextEditingController? _phase1CurrentTextfield;
  TextEditingController? _phase2CurrentTextfield;
  TextEditingController? _dcCurrentTargetTextfield;
  TextEditingController? _dcHoldTimeTextfield;
  TextEditingController? _rampUpTimeTextfield;
  TextEditingController? _dcBurstGapTextfield;

  TextEditingController? _endByMinutesTextfield;
  TextEditingController? _endBySecondsTextfield;

  TextEditingController? _endStimulationTextField;
  List<bool> fixedLengthList = [true, false, false];
  String error = "none";
  String result = "";
  bool connected = false;

//////////////////////////////////////////////////
  /// this shouldn't be here, this is to fix an error where the device disconnects upon
  /// navigating to the workspace. this should be fixed soon with the BLE code being moved to provider

///////////////////////////////////////////////////
  String? get _durationErrorText {
    // at any time, we can get the text from _controller.value.text
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code

    if (Provider.of<Data>(context).getendbyseconds +
            Provider.of<Data>(context).getendbyminutes ==
        0) {
      return 'Must be > 0';
    }
    // return null if the text is valid
    return null;
  }

  String? get _durationMinutesErrorText {
    // at any time, we can get the text from _controller.value.text
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code

    if (Provider.of<Data>(context).getendbyseconds +
            Provider.of<Data>(context).getendbyminutes ==
        0) {
      return 'Invalid Duration';
    }
    // return null if the text is valid
    return null;
  }

  void showSuccess(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 700)));

  void showError(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 300)));


  @override
  void initState() {
    device = widget.device;
    final Data myProvider = Provider.of<Data>(context, listen: false);
    // _characteristicValueStream =
    //     WinBle.characteristicValueStream.listen((event) {
    // });
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
    TextEditingController(text: myProvider.getendByValue);
    List<bool> fixedLengthList;
  }

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
    return Column(
      children: [
        myProvider.getDcMode
            ? SizedBox(
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
            : const SizedBox(
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
                Provider.of<Data>(context, listen: false)
                    .prepare_stimulation_values();
                var serial_command_inputs =
                    Provider.of<Data>(context, listen: false)
                        .get_serial_command_input_char;
                for (var value in serial_command_inputs.values) {
                  myProvider.writeCharacteristic(device.address, SERVICE_UUID,
                      SERIAL_COMMAND_INPUT_CHAR_UUID, value, true);
                  await Future.delayed(const Duration(milliseconds: 1), () {});
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
                    enabled: !myProvider.getDcMode,
                    keyboardType: TextInputType.number,
                    controller: _phase1CurrentTextfield,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      myProvider.setphase1current(value);
                    },
                    decoration:  InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      labelText: 'Phase 1 Current (µA)',
                      labelStyle: TextStyle(fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                        errorText: generic_error_string(myProvider.getPhase1Current, 3000, 0, "Must be less than 3000")
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: TextField(
                    enabled: !myProvider.getDcMode,
                    keyboardType: TextInputType.number,
                    controller: _phase2CurrentTextfield,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                   ],
                    onChanged: (value) {
                      myProvider.setphase2current(value);
                    },
                    decoration:  InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      labelText: 'Phase 2 Current (µA)',
                      labelStyle: TextStyle(fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                                                 errorText: generic_error_string(myProvider.getPhase2Current, 3000, 0, "Must be less than 3000")
 
                    ),
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
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      myProvider.setDCCurrentTarget(value);
                    },
                    enabled: myProvider.getDcMode,
                    decoration:  InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      labelText: 'DC Current Target (µA)',
                      labelStyle: TextStyle(fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                                                  errorText: generic_error_string(myProvider.getDCCurrentTarget, 3000, 0, "Must be less than 3000")

                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: CustomTextField(
                    enabled: myProvider.getDcMode,
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
                    enabled: myProvider.getDcMode,
                    controller: _rampUpTimeTextfield,
                    onChanged: (value) {
                      myProvider.setrampUpTime(value);
                    },
                    labelText: 'Ramp Up Time ',
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
                    enabled: myProvider.getDcMode,
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
              const SizedBox(height: 10),
              Text("$endStimulationTitle"),
              const SizedBox(height: 10),
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
                  width: 250,
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          num_range_formatter(min: 0, max: 60)
                        ],
                        onChanged: (value) {
                          myProvider.setendbystimulationseconds(value);
                        },
                        decoration: InputDecoration(
                          labelText: "Seconds",
                          errorText: _durationErrorText,
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
