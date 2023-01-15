import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:nstim_app/providers/bluetooth_le_provider.dart';
import 'package:nstim_app/providers/service_layer_provider.dart';
import 'package:nstim_app/util/textfield_helper_functions.dart';
import 'package:provider/provider.dart';
import 'package:win_ble/win_ble.dart';
import '../workspaceComponents/custom_units_textfield.dart';
import '../../../util/consts.dart';
import '../../../serviceLayer/Input_validation.dart';

class LeftInputs extends StatefulWidget {
  final BleDevice device;
  const LeftInputs({Key? key, required this.device}) : super(key: key);
  @override
  _LeftInputsState createState() => _LeftInputsState();
}

class _LeftInputsState extends State<LeftInputs> {
  late BleDevice device = widget.device;

  // these are used to control and retrive values from the textfields

  TextEditingController? _phase1MicrosecTextfield;
  TextEditingController? _interPhaseDelayTextfield;
  TextEditingController? _phase2MicrosecTextfield;
  TextEditingController? _interStimDelayTexfield;
  TextEditingController? _burstDurationTextfield;
  TextEditingController? _dutyCycleTextfield;
  TextEditingController? _rampUpTimeTextfield;
  TextEditingController? _frequencyTextfield;

  @override
  void initState() {
    final ServiceLayerProvider serviceLayerProvider =
        Provider.of<ServiceLayerProvider>(context, listen: false);

    super.initState();
    device = widget.device;

    _phase1MicrosecTextfield = TextEditingController(
        text: serviceLayerProvider
            .retrieveIntValue("phase1TimeMicroSec")
            .toString());
    _interPhaseDelayTextfield = TextEditingController(
        text: serviceLayerProvider
            .retrieveIntValue("interphaseDelay")
            .toString());
    _phase2MicrosecTextfield = TextEditingController(
        text: serviceLayerProvider
            .retrieveIntValue("phase2TimeMicroSec")
            .toString());
    _interStimDelayTexfield = TextEditingController(
        text:
            serviceLayerProvider.retrieveIntValue("interstimDelay").toString());
    _burstDurationTextfield = TextEditingController(
        text:
            serviceLayerProvider.retrieveIntValue("burstDuration").toString());
    _dutyCycleTextfield = TextEditingController(
        text: serviceLayerProvider
            .retrieveIntValue("dutyCyclePercentage")
            .toString());
    _frequencyTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveDoubleValue("frequency").toString());
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _phase1MicrosecTextfield?.dispose();
    _interPhaseDelayTextfield?.dispose();
    _phase2MicrosecTextfield?.dispose();
    _interStimDelayTexfield?.dispose();
    _burstDurationTextfield?.dispose();
    _dutyCycleTextfield?.dispose();
    _frequencyTextfield?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ServiceLayerProvider serviceLayerProvider =
        Provider.of<ServiceLayerProvider>(context);
    final BluetoothLEProvider bluetoothLEProvider =
        Provider.of<BluetoothLEProvider>(context);

    // final Presets presetProvider = Provider.of<Presets>(context);
    var interstimByFreqString = Provider.of<ServiceLayerProvider>(context)
        .retrieveIntValue("interstimDelay")
        .toString();
    bool showInterstimTextfield = !Provider.of<ServiceLayerProvider>(context)
        .retrieveBoolValue("calculateInterstimByFreq");
// ///////////////////////////////////////
    // if (myProvider.getUpdatePreset) {
    //   setState(() {
    //     _phase1Textfield =
    //         TextEditingController(text: myProvider.getPhase1Time.toString());
    //     _interPhaseDelayTextfield = TextEditingController(
    //         text: myProvider.getInterPhaseDelay.toString());
    //     _phase2Textfield =
    //         TextEditingController(text: myProvider.getPhase2Time.toString());
    //     _interStimDelayTexfield = TextEditingController(
    //         text: myProvider.getInterstimDelay.toString());
    //     _burstDurationTextfield =
    //         TextEditingController(text: myProvider.getBurstDuration.toString());
    //     _dutyCycleTextfield =
    //         TextEditingController(text: myProvider.getDutyCycle.toString());
    //     _frequencyTextfield =
    //         TextEditingController(text: myProvider.getFrequency.toString());
    //     myProvider.setfrequencyNoNotify(myProvider.getFrequency.toString());
    //     interstim_from_freq = myProvider.getinterstimstring;
    //   });
    // }
///////////////////
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 5,
        ),
                SizedBox(
          height: 10,
        ),

        Text(
          "Phase Time Settings",
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: CustomUnitsTextField(
                enabled: !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                controller: _phase1MicrosecTextfield,
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue(
                      "phase1TimeMicroSec", value);
                  if (serviceLayerProvider
                      .retrieveBoolValue("calculateInterstimByFreq")) {
                    serviceLayerProvider.updateInterstimByFrequency();
                    //todo
                    interstimByFreqString = serviceLayerProvider
                        .retrieveIntValue("interstimDelay")
                        .toString();
                  }
                },
                labelText: 'Phase 1 Time',
                minValue: 0,
                maxValue: UINT32MAX,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 250,
              child: CustomUnitsTextField(
                enabled: !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                controller: _phase2MicrosecTextfield,
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue(
                      "phase2TimeMicroSec", value);
                  if (serviceLayerProvider
                      .retrieveBoolValue("calculateInterstimByFreq")) {
                    serviceLayerProvider.updateInterstimByFrequency();

                    //todo
                    interstimByFreqString = serviceLayerProvider
                        .retrieveIntValue("interstimDelay")
                        .toString();
                  }
                },
                labelText: 'Phase 2 Time',
                minValue: 0,
                maxValue: UINT32MAX,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: CustomUnitsTextField(
                enabled: !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                controller: _interPhaseDelayTextfield,
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue(
                      "interphaseDelay", value);
                },
                labelText: 'Inter-phase Delay',
                minValue: 0,
                maxValue: UINT32MAX,
              ),
            ),
            const SizedBox(width: 20),
            if (showInterstimTextfield)
              SizedBox(
                width: 250,
                child: CustomUnitsTextField(
                  enabled:
                      !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                          bluetoothLEProvider.getConnected,
                  controller: _interStimDelayTexfield,
                  onChanged: (value) {
                    serviceLayerProvider.setIntegerValue(
                        "interstimDelay", value);
                  },
                  labelText: 'Inter-stim Delay',
                  minValue: 0,
                  maxValue: UINT32MAX,
                ),
              )
            else
              Column(
                children: [
                  const Text("Inter-stim delay from frequency:",
                      style: TextStyle(
                          color: Color.fromARGB(255, 150, 150, 150),
                          fontWeight: FontWeight.w500,
                          fontSize: 15)),
                  const SizedBox(height: 6),
                  Container(
                    width: 250,
                    height: 1, // Thickness
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 6),
                  Text("$interstimByFreqString µs",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.normal,
                          fontSize: 15)),
                ],
              )
          ],
        ),
        const SizedBox(height: 5),
        Text(
          "Calculate inter-stim delay by frequency:",
          style: Theme.of(context).textTheme.headline2,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const SizedBox(
              width: 85,
            ),
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
                serviceLayerProvider.setBooleanValue(
                    "calculateInterstimByFreq",
                    frequency);
                if (frequency == false) {
                  serviceLayerProvider.setIntegerValue(
                      "interstimDelay",
                      serviceLayerProvider
                          .retrieveIntValue("interstimDelay")
                          .toString());
                  _interStimDelayTexfield?.text = serviceLayerProvider
                      .retrieveIntValue("interstimDelay")
                      .toString();
                } else {
                  serviceLayerProvider.updateInterstimByFrequency();
                  interstimByFreqString = serviceLayerProvider
                      .retrieveIntValue("interstimDelay")
                      .toString();
                  _interStimDelayTexfield?.text = serviceLayerProvider
                      .retrieveIntValue("interstimDelay")
                      .toString();
                }
              },
              value: Provider.of<ServiceLayerProvider>(context)
                  .retrieveBoolValue(
                      "calculateInterstimByFreq"), // remove `listen: false`
            ),
            const SizedBox(
              width: 110,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                enabled: (serviceLayerProvider
                        .retrieveBoolValue("calculateInterstimByFreq") &&
                    !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected),
                controller: _frequencyTextfield,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r"([0-9]+\.?[0-9]*|\.[0-9]+)")),
                ],
                onChanged: (value) {
                  serviceLayerProvider.setDoubleValue("frequency", value);
                  serviceLayerProvider.updateInterstimByFrequency();
                  interstimByFreqString = serviceLayerProvider
                      .retrieveIntValue("interstimDelay")
                      .toString();
                },
                decoration: InputDecoration(
                  disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  labelText: 'Frequency (pps)',
                  errorText: frequencyInputErrorText(
                      serviceLayerProvider.retrieveDoubleValue("frequency"),
                      serviceLayerProvider
                          .retrieveIntValue("phase1TimeMicroSec"),
                      serviceLayerProvider
                          .retrieveIntValue("phase2TimeMicroSec"),
                      serviceLayerProvider.retrieveIntValue("interphaseDelay"),
                      0),
                  labelStyle: const TextStyle(fontSize: 20),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                ),
              ),
            ),
          ],
        ),
        Text(
          "Burst Mode Settings",
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: CustomUnitsTextField(
                enabled: (serviceLayerProvider
                        .retrieveBoolValue("continuousStimOn") &&
                    !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected),
                controller: _burstDurationTextfield,
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue("burstDuration", value);
                },
                labelText: 'Burst Duration',
                minValue: serviceLayerProvider.getpulsePeriod,
                maxValue: UINT32MAX,
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 250,
              child: TextField(
                enabled: (serviceLayerProvider
                        .retrieveBoolValue("continuousStimOn") &&
                    !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected),
                keyboardType: TextInputType.number,
                controller: _dutyCycleTextfield,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  NumberRangeFormatter(min: 0, max: 100),
                ],
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue(
                      "dutyCyclePercentage", value);
                },
                decoration: InputDecoration(
                    disabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    labelText: 'Duty Cycle (%)',
                    labelStyle: const TextStyle(fontSize: 20),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    errorText:
                        DutyCycleErrorText(1, 100, _dutyCycleTextfield!.text)),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Text(
              "Toggle AC stimulation type:",
              style: Theme.of(context).textTheme.headline2,
            ),
            SizedBox(
              width: 90,
            ),
            Text(
              "Toggle anodic or cathodic first:",
              style: Theme.of(context).textTheme.headline2,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
              width: 250,
              child: FlutterSwitch(
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
                      serviceLayerProvider.setBooleanValue(
                          "continuousStimOn",
                          continuous);
                    });
                  },
                  value: serviceLayerProvider
                      .retrieveBoolValue("continuousStimOn")),
            ),
            SizedBox(
              width: 250,
              child: FlutterSwitch(
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
                    serviceLayerProvider.setBooleanValue(
                        "cathodicFirst",
                        cathodic);
                  },
                  value: serviceLayerProvider.retrieveBoolValue(
                      "cathodicFirst")), // remove `listen: false`
            )
          ],
        ),

      ],
    );
  }
}
