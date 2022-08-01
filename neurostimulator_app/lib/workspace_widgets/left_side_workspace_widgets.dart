import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import "../data_provider.dart";
import '../helper_and_const.dart';

class leftTextFields extends StatefulWidget {
  const leftTextFields({Key? key}) : super(key: key);
  @override
  _leftTextFieldsState createState() => _leftTextFieldsState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _leftTextFieldsState extends State<leftTextFields> {
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
    var interstim_from_freq = Provider.of<Data>(context).getinterstimstring;
    bool show_interstim_tab =
        !Provider.of<Data>(context).getCalculateByFrequency;

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                "Phase Time Settings",
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 60, 109),
                    fontWeight: FontWeight.normal,
                    fontSize: 30),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  enabled: !myProvider.getDcMode,
                  controller: _phase1Textfield,
                  onChanged: (value) {
                    myProvider.setphase1(value);
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
                  enabled: !myProvider.getDcMode,
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
                  enabled: !myProvider.getDcMode,
                  controller: _phase2Textfield,
                  onChanged: (value) {
                    myProvider.setphase2(value);
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
                        enabled: !myProvider.getDcMode,
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
                //todo: implement frequency calculations
                enabled: (myProvider.getCalculateByFrequency &
                    !myProvider.getDcMode),
                keyboardType: TextInputType.number,
                controller: _frequencyTextfield,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  num_range_formatter(min: 0, max: UINT32MAX)
                ],
                onChanged: (value) {
                  myProvider.setfrequency(value);
                },
                decoration:  InputDecoration(
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  labelText: 'Frequency (pps)',
                  errorText: frequency_input_error(myProvider.getFrequency, myProvider.getPhase1Time, myProvider.getPhase2Time, myProvider.getInterPhaseDelay, 0),
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
              const SizedBox(height: 10),
              const Text(
                "Burst Stimulation",
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 60, 109),
                    fontWeight: FontWeight.normal,
                    fontSize: 30),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: CustomTextField(
                  enabled: (!Provider.of<Data>(context).getBurstMode &
                      !myProvider.getDcMode),
                  controller: _burstDurationTextfield,
                  onChanged: (value) {
                    myProvider.setburstduration(value);
                  },
                  labelText: 'Burst Duration',
                  minValue: 0,
                  maxValue: UINT32MAX,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Continuous Stimulation",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 60, 109),
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  const SizedBox(width: 10),
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
                      onToggle: (bool continuous) {
                        setState(() {
                          Provider.of<Data>(context, listen: false)
                              .toggleburstcont(!continuous);
                        });
                      },
                      value: Provider.of<Data>(context).getBurstMode)
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: TextField(
                  enabled: (!Provider.of<Data>(context).getBurstMode &
                      !myProvider.getDcMode),
                  keyboardType: TextInputType.number,
                  controller: _dutyCycleTextfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 0, max: 100)
                  ],
                  onChanged: (value) {
                    myProvider.setdutycycle(value);
                  },
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    labelText: 'Duty Cycle (%)',
                    labelStyle: TextStyle(fontSize: 20),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
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
