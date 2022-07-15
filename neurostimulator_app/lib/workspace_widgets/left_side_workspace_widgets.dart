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
  TextEditingController? _burstPeriodTextfield;
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
    _burstPeriodTextfield =
        TextEditingController(text: myProvider.getBurstPeriod.toString());
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
    _burstPeriodTextfield?.dispose();
    _dutyCycleTextfield?.dispose();
    _frequencyTextfield?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Data myProvider = Provider.of<Data>(context);

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
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _phase1Textfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 10, max: UINT32MAX)
                  ],
                  onChanged: (value) {
                    myProvider.setphase1(value);
                  },
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber)),
                    labelText: 'Phase 1 Time (µs)',
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _interPhaseDelayTextfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 0, max: UINT32MAX)
                  ],
                  onChanged: (value) {
                    myProvider.setinterphasedelay(value);
                  },
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber)),
                    labelText: 'Inter-phase delay (µs)',
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
                  ),
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
                  keyboardType: TextInputType.number,
                  controller: _phase2Textfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 10, max: UINT32MAX)
                  ],
                  onChanged: (value) {
                    myProvider.setphase2(value);
                  },
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber)),
                    labelText: 'Phase 2 Time (µs)',
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _interStimDelayTexfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 0, max: UINT32MAX)
                  ],
                  onChanged: (value) {
                    myProvider.setinterstimdelay(value);
                  },
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber)),
                    labelText: 'Inter-stim delay (µs)',
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
                  ),
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
              const SizedBox(height: 10),
              const Text(
                "Calculate by Frequency",
                style: TextStyle(
                    color: Color.fromARGB(255, 0, 60, 109),
                    fontWeight: FontWeight.normal,
                    fontSize: 30),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: TextField(
                  enabled: Provider.of<Data>(context).getBurstMode,
                  keyboardType: TextInputType.number,
                  controller: _frequencyTextfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 0, max: UINT32MAX)
                  ],
                  onChanged: (value) {
                    myProvider.setfrequency(value);
                  },
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber)),
                    labelText: 'Frequency (pps)',
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 250,
          )
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
                child: TextField(
                  enabled: !Provider.of<Data>(context).getBurstMode,
                  keyboardType: TextInputType.number,
                  controller: _burstPeriodTextfield,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    num_range_formatter(min: 0, max: UINT32MAX)
                  ],
                  onChanged: (value) {
                    myProvider.setburstperiod(value);
                  },
                  decoration: const InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber)),
                    labelText: 'Burst Period (ms)',
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
                  ),
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
                    "Continous Stimulation",
                    style: TextStyle(
                        color: Color.fromARGB(255, 0, 60, 109),
                        fontWeight: FontWeight.w500,
                        fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  FlutterSwitch(
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey,
                      activeText: "on",
                      inactiveText: "off",
                      width: 75,
                      height: 40,
                      activeTextColor: Colors.white,
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
                  enabled: !Provider.of<Data>(context).getBurstMode,
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
                        borderSide: BorderSide(color: Colors.amber)),
                    labelText: 'Duty Cycle (%)',
                    labelStyle: TextStyle(fontSize: 20),
                    border: OutlineInputBorder(),
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
        activeColor: Colors.green,
        inactiveColor: Colors.blue,
        activeText: "cathodic first",
        inactiveText: "anodic first",
        width: 150,
        height: 40,
        activeTextColor: Colors.white,
        showOnOff: true,
        onToggle: (bool cathodic) {
          Provider.of<Data>(context, listen: false)
              .toggleCathodicAnodic(cathodic);
        },
        value: Provider.of<Data>(context)
            .getCathodicFirst, // remove `listen: false`
      ),
      SizedBox(
        height: 20,
      ),
      Container(
        width: 500,
        height: 1, // Thickness
        color: Colors.grey,
      )
    ]);
  }
}
