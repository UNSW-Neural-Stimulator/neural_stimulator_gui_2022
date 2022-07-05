import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import "../data_provider.dart";

class RightSideInputs extends StatefulWidget {
  const RightSideInputs({Key? key}) : super(key: key);
  @override
  _RightSideInputsState createState() => _RightSideInputsState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _RightSideInputsState extends State<RightSideInputs> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  TextEditingController? _phase1CurrentTextfield;
  TextEditingController? _phase2CurrentTextfield;
  TextEditingController? _vref0Textfield;
  TextEditingController? _vref65535Texfield;
  TextEditingController? _endStimulationTextField;
  List<bool> fixedLengthList = [true, false, false];

  @override
  void initState() {
    final Data myProvider = Provider.of<Data>(context, listen: false);

    super.initState();
    _phase1CurrentTextfield =
        TextEditingController(text: myProvider.getPhase1CurrentString);
    _phase2CurrentTextfield =
        TextEditingController(text: myProvider.getPhase2CurrentString);
    _vref0Textfield = TextEditingController(text: myProvider.getVref0String);
    _vref65535Texfield =
        TextEditingController(text: myProvider.getVref65535String);
    _endStimulationTextField =
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
    _vref0Textfield?.dispose();
    _vref65535Texfield?.dispose();
    _endStimulationTextField?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Data myProvider = Provider.of<Data>(context);
    var endStimulationTitle = Provider.of<Data>(context).endByDurationTitle;
    var value_one = "";

    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
              ),
              FlutterSwitch(
                activeColor: Colors.green,
                inactiveColor: Colors.red,
                activeText: "DC mode on",
                inactiveText: "DC mode off",
                width: 150,
                height: 40,
                activeTextColor: Colors.white,
                showOnOff: true,
                onToggle: (bool dcmode) {
                  Provider.of<Data>(context, listen: false).toggleDC(dcmode);
                },
                value: Provider.of<Data>(context)
                    .getDcMode, // remove `listen: false`
              ),
              SizedBox(
                width: 50,
              ),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                  minimumSize: Size(150, 50),
                ),

                onPressed: () {
                  //send ble
                },
                icon: const Icon(
                  Icons.bolt,
                  size: 24.0,
                ),
                label: Text('start',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)), // <-- Text
              ),
              SizedBox(
                width: 50,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  minimumSize: Size(150, 50),
                ),

                onPressed: () {
                  //send ble
                },
                icon: const Icon(
                  Icons.stop_outlined,
                  size: 24.0,
                ),
                label: Text('stop',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)), // <-- Text
              ),
              // FlutterSwitch(
              //   activeColor: Colors.green,
              //   inactiveColor: Colors.red,
              //   activeText: "stimulation on",
              //   inactiveText: "stimulation off",
              //   width: 170,
              //   height: 40,
              //   activeTextColor: Colors.white,
              //   showOnOff: true,
              //   onToggle: (bool start) {
              //     Provider.of<Data>(context, listen: false).togglestart(start);
              //   },
              //   value: Provider.of<Data>(context)
              //       .getstart, // remove `listen: false`
              // ),
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
                      keyboardType: TextInputType.number,
                      controller: _phase1CurrentTextfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        myProvider.setphase1current(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Phase 1 Current (µA)',
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
                      controller: _phase2CurrentTextfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        myProvider.setinterphasedelay(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Phase 2 Current (µA)',
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: _vref0Textfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        myProvider.setvref0(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'VREF 0',
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
                      controller: _vref65535Texfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        myProvider.setvref65535(value);
                      },
                      decoration: const InputDecoration(
                        labelText: 'VREF 65535',
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
          Text("Toggle anodic or cathodic first:"),
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
            height: 10,
          ),
          Text("End stimulation by:"),
          SizedBox(
            height: 10,
          ),
          ToggleButtons(
            constraints: BoxConstraints(minWidth: 160, minHeight: 50),
            children: <Widget>[
              Text("Stimulation Duration (s)"),
              Text("Number of Bursts"),
              Text("Stimulate Forever"),
            ],
            onPressed: (int index) {
              if (index == 0) {
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
          SizedBox(height: 10),
          Text("$endStimulationTitle"),
          SizedBox(height: 10),
          SizedBox(
            width: 250,
            child: TextField(
              enabled: !Provider.of<Data>(context).stimilateForever,
              keyboardType: TextInputType.number,
              controller: _endStimulationTextField,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                myProvider.setendbyvalue(value);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
