import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ns_2022/preset_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:win_ble/win_ble.dart';
import "../data_provider.dart";
import '../util/consts.dart';
import '../util/helper_functions.dart';
import '../persistance/presetList.dart';
import 'ErrorDialogue.dart';

class leftTextFields extends StatefulWidget {
  final BleDevice device;
  const leftTextFields({Key? key, required this.device}) : super(key: key);
  @override
  _leftTextFieldsState createState() => _leftTextFieldsState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _leftTextFieldsState extends State<leftTextFields> {
  late BleDevice device = widget.device;

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  TextEditingController? _phase1Textfield;
  TextEditingController? _interPhaseDelayTextfield;
  TextEditingController? _phase2Textfield;
  TextEditingController? _interStimDelayTexfield;
  TextEditingController? _burstDurationTextfield;
  TextEditingController? _dutyCycleTextfield;
  TextEditingController? _rampUpTimeTextfield;
  TextEditingController? _frequencyTextfield;

  @override
  void initState() {
    final Data myProvider = Provider.of<Data>(context, listen: false);

    super.initState();
    device = widget.device;

    _phase1Textfield =
        TextEditingController(text: myProvider.getPhase1Time.toString());
    _interPhaseDelayTextfield =
        TextEditingController(text: myProvider.getInterPhaseDelay.toString());
    _phase2Textfield =
        TextEditingController(text: myProvider.getPhase2Time.toString());
    _interStimDelayTexfield =
        TextEditingController(text: myProvider.getInterstimDelay.toString());
    _burstDurationTextfield =
        TextEditingController(text: myProvider.getBurstDuration.toString());
    _dutyCycleTextfield =
        TextEditingController(text: myProvider.getDutyCycle.toString());
    _frequencyTextfield =
        TextEditingController(text: myProvider.getFrequency.toString());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _phase1Textfield?.dispose();
    _interPhaseDelayTextfield?.dispose();
    _phase2Textfield?.dispose();
    _interStimDelayTexfield?.dispose();
    _burstDurationTextfield?.dispose();
    _dutyCycleTextfield?.dispose();
    _frequencyTextfield?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Data myProvider = Provider.of<Data>(context);
    final Presets presetProvider = Provider.of<Presets>(context);
    var interstim_from_freq = Provider.of<Data>(context).getinterstimstring;
    bool show_interstim_tab =
        !Provider.of<Data>(context).getCalculateByFrequency;
///////////////////////////////////////
    if (myProvider.getUpdatePreset) {
      setState(() {
        _phase1Textfield =
            TextEditingController(text: myProvider.getPhase1Time.toString());
        _interPhaseDelayTextfield = TextEditingController(
            text: myProvider.getInterPhaseDelay.toString());
        _phase2Textfield =
            TextEditingController(text: myProvider.getPhase2Time.toString());
        _interStimDelayTexfield = TextEditingController(
            text: myProvider.getInterstimDelay.toString());
        _burstDurationTextfield =
            TextEditingController(text: myProvider.getBurstDuration.toString());
        _dutyCycleTextfield =
            TextEditingController(text: myProvider.getDutyCycle.toString());
        _frequencyTextfield =
            TextEditingController(text: myProvider.getFrequency.toString());
        myProvider.setfrequencyNoNotify(myProvider.getFrequency.toString());
        interstim_from_freq = myProvider.getinterstimstring;
      });
    }
///////////////////
    return Column(children: [
      SizedBox(
        height: 20,
      ),
      Row(
        children: [
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (await myProvider.connect(widget.device.address) == true) {
                  setState(() {});
                  myProvider.subsCribeToCharacteristic(
                      widget.device.address, SERVICE_UUID, NOTIFY_CHAR_UUID);
                  print('ready');
                  setState(() {myProvider.setConnected(true);});
                } else {
                  print("error on connection");
                }
              },
              icon: const Icon(
                Icons.bluetooth,
                size: 15.0,
              ),
              label: Text('Connect'), // <-- Text
            ),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: 150,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(primary: Colors.red),
              onPressed: () async {
                if (await myProvider.disconnect(widget.device.address) ==
                    true) {
                  myProvider.unSubscribeToCharacteristic(
                      widget.device.address, SERVICE_UUID, NOTIFY_CHAR_UUID);
                  setState(() {});
                  print('disconnected');
                } else {
                  print("error on disconnection");
                }
              },
              icon: const Icon(
                Icons.bluetooth,
                size: 15.0,
              ),
              label: Text('Disconnect'), // <-- Text
            ),
          ),
          SizedBox(
            width: 20,
          ),
          FlutterSwitch(
              activeColor: Colors.blue,
              inactiveColor: Colors.blue,
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.white,
              activeTextFontWeight: FontWeight.w400,
              inactiveTextFontWeight: FontWeight.w400,
              activeText: "Continuous",
              inactiveText: "Burst mode on",
              width: 150,
              height: 40,
              showOnOff: true,
              onToggle: (bool continuous) {
                setState(() {
                  Provider.of<Data>(context, listen: false)
                      .toggleburstcont(!continuous);
                });
              },
              value: Provider.of<Data>(context).getBurstMode),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
      ),
      if (!myProvider.getConnected)
        SizedBox(
          height: 30,
          child: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
              Text(
                "    The device is not connected",
                style:
                    TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
              )
            ],
          ),
        )
      else
        SizedBox(
          height: 30,
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const Text(
                "    Phase Time Settings",
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 60, 109),
                    fontWeight: FontWeight.normal,
                    fontSize: 30),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  enabled: !myProvider.getDcMode && myProvider.getConnected,
                  controller: _phase1Textfield,
                  onChanged: (value) {
                    myProvider.setphase1(value);
                    if (myProvider.getCalculateByFrequency) {
                      myProvider
                          .setfrequency(myProvider.getFrequency.toString());
                      interstim_from_freq = myProvider.getinterstimstring;
                    }
                  },
                  labelText: 'Phase 1 Time',
                  minValue: 0,
                  maxValue: UINT32MAX,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  enabled: !myProvider.getDcMode && myProvider.getConnected,
                  controller: _interPhaseDelayTextfield,
                  onChanged: (value) {
                    myProvider.setinterphasedelay(value);
                  },
                  labelText: 'Inter-phase Delay',
                  minValue: 0,
                  maxValue: UINT32MAX,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              const SizedBox(height: 60),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  enabled: !myProvider.getDcMode && myProvider.getConnected,
                  controller: _phase2Textfield,
                  onChanged: (value) {
                    myProvider.setphase2(value);
                    if (myProvider.getCalculateByFrequency) {
                      myProvider
                          .setfrequency(myProvider.getFrequency.toString());
                      interstim_from_freq = myProvider.getinterstimstring;
                    }
                  },
                  labelText: 'Phase 2 Time',
                  minValue: 0,
                  maxValue: UINT32MAX,
                ),
              ),
              const SizedBox(height: 20),
              show_interstim_tab
                  ? SizedBox(
                      width: 250,
                      child: CustomTextField(
                        enabled:
                            !myProvider.getDcMode && myProvider.getConnected,
                        controller: _interStimDelayTexfield,
                        onChanged: (value) {
                          myProvider.setinterstimdelay(value);
                        },
                        labelText: 'Inter-stim Delay',
                        minValue: 0,
                        maxValue: UINT32MAX,
                      ),
                    )
                  : Column(
                      children: [
                        Text("Inter-stim delay from frequency:",
                            style: TextStyle(
                                color: Color.fromARGB(255, 150, 150, 150),
                                fontWeight: FontWeight.w500,
                                fontSize: 15)),
                        SizedBox(height: 6),
                        Container(
                          width: 250,
                          height: 1, // Thickness
                          color: Colors.blue,
                        ),
                        SizedBox(height: 6),
                        Text("$interstim_from_freq µs",
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.normal,
                                fontSize: 15)),
                      ],
                    )
            ],
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Calculate inter-stim delay by frequency:",
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 60, 109),
                    fontWeight: FontWeight.normal,
                    fontSize: 15),
              ),
              const SizedBox(height: 10),
              FlutterSwitch(
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.white,
                activeTextFontWeight: FontWeight.w400,
                inactiveTextFontWeight: FontWeight.w400,
                activeText: "on",
                inactiveText: "off",
                width: 75,
                height: 40,
                showOnOff: true,
                onToggle: (bool frequency) {
                  Provider.of<Data>(context, listen: false)
                      .togglefrequency(frequency);
                  if (frequency == false) {
                    Provider.of<Data>(context, listen: false)
                        .setinterstimsting("");
                  } else {
                    myProvider.setfrequency(myProvider.getFrequency.toString());
                    interstim_from_freq = myProvider.getinterstimstring;
                    myProvider.setfrequency(
                        Provider.of<Data>(context, listen: false)
                            .getFrequency
                            .toString());
                  }
                },
                value: Provider.of<Data>(context)
                    .getCalculateByFrequency, // remove `listen: false`
              ),
            ],
          ),
          SizedBox(
            width: 15,
          ),
          Column(children: [
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                enabled: (myProvider.getCalculateByFrequency &&
                    !myProvider.getDcMode &&
                    myProvider.getConnected),
                controller: _frequencyTextfield,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r"([0-9]+\.?[0-9]*|\.[0-9]+)")),
                ],
                onChanged: (value) {
                  myProvider.setfrequency(value);
                },
                decoration: InputDecoration(
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  labelText: 'Frequency (pps)',
                  errorText: frequency_input_error(
                      myProvider.getFrequency,
                      myProvider.getPhase1Time,
                      myProvider.getPhase2Time,
                      myProvider.getInterPhaseDelay,
                      0),
                  labelStyle: TextStyle(fontSize: 20),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
            ),
          ])
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 40,
                width: 300,
                child: Text(
                  "    Burst Settings",
                  style: TextStyle(
                      color: Color.fromARGB(255, 0, 60, 109),
                      fontWeight: FontWeight.normal,
                      fontSize: 30),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  enabled: (!Provider.of<Data>(context).getBurstMode &
                          !myProvider.getDcMode &&
                      myProvider.getConnected),
                  controller: _burstDurationTextfield,
                  onChanged: (value) {
                    myProvider.setburstduration(value);
                  },
                  labelText: 'Burst Duration',
                  minValue: myProvider.getpulsePeriod,
                  maxValue: UINT32MAX,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              const SizedBox(height: 60),
              SizedBox(
                width: 250,
                child: TextField(
                  enabled: (!Provider.of<Data>(context).getBurstMode &
                          !myProvider.getDcMode &&
                      myProvider.getConnected),
                  keyboardType: TextInputType.number,
                  controller: _dutyCycleTextfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 0, max: 100)
                  ],
                  onChanged: (value) {
                    myProvider.setdutycycle(value);
                  },
                  decoration: InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      labelText: 'Duty Cycle (%)',
                      labelStyle: TextStyle(fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                      errorText: Duty_cycle_input_error_text(
                          1, 100, _dutyCycleTextfield!.text)),
                ),
              ),
            ],
          ),
        ],
      ),
      Row(
        children: [
          SizedBox(
            width: 50,
          ),
          Column(
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    minimumSize: const Size(150, 50),
                  ),

                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Presets: '),
                            content: presetContainer(),
                          );
                        });
                  },

                  icon: const Icon(
                    Icons.save,
                    size: 24.0,
                  ),
                  label: const Text('Presets',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400)), // <-- Text
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    minimumSize: const Size(150, 50),
                  ),

                  onPressed: () async {
                    String allErrors = myProvider.startStimErrorCheck();
                    if (allErrors != "") {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: Text(
                                    'Please address the following warnings: '),
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
                        myProvider.writeCharacteristic(
                            device.address,
                            SERVICE_UUID,
                            SERIAL_COMMAND_INPUT_CHAR_UUID,
                            value,
                            true);
                        await Future.delayed(
                            const Duration(milliseconds: 1), () {});
                      }
                      //Send impedance check request
                      myProvider.writeCharacteristic(
                          device.address,
                          SERVICE_UUID,
                          SERIAL_COMMAND_INPUT_CHAR_UUID,
                          Uint8List.fromList([19, 0, 0, 0, 0]),
                          true);
                    }
                    ;
                  },

                  icon: const Icon(
                    Icons.bolt,
                    size: 24.0,
                  ),
                  label: const Text('Impedance check',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400)), // <-- Text
                ),
              ),
            ],
          ),
          SizedBox(
            width: 50,
          ),
          Column(
            children: [
              const Text(
                "Toggle anodic or cathodic first:",
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 0, 60, 109),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              FlutterSwitch(
                activeColor: Colors.blue,
                inactiveColor: Colors.blue,
                activeTextColor: Colors.white,
                inactiveTextColor: Colors.white,
                activeTextFontWeight: FontWeight.w400,
                inactiveTextFontWeight: FontWeight.w400,
                activeText: "cathodic first",
                inactiveText: "anodic first",
                width: 150,
                height: 40,
                showOnOff: true,
                onToggle: (bool cathodic) {
                  Provider.of<Data>(context, listen: false)
                      .toggleCathodicAnodic(cathodic);
                },
                value: Provider.of<Data>(context)
                    .getCathodicFirst, // remove `listen: false`
              ),
            ],
          )
        ],
      ),
      SizedBox(
        height: 65,
      ),
      Container(
        width: 500,
        height: 1, // Thickness
        color: Colors.grey,
      )
    ]);
  }
}
