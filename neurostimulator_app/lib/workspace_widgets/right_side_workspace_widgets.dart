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

  TextEditingController? _endStimulationTextField;
  List<bool> fixedLengthList = [true, false, false];
  String error = "none";
  String result = "";
  bool connected = false;

  //the below may be unneccesary
  List<BleCharacteristic> characteristics = [];
  List<String> services = [];
//////////////////////////////////////////////////
  /// this shouldn't be here, this is to fix an error where the device disconnects upon
  /// navigating to the workspace. this should be fixed soon with the BLE code being moved to provider
  connect(BleDevice device) async {
    final address = device.address;
    try {
      await WinBle.connect(address);
      ;
    } catch (e) {
      setState(() {
        error = e.toString();
        showError(error);
      });
    }
  }
///////////////////////////////////////////////////

  void showSuccess(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 700)));

  void showError(String value) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(value),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 300)));

  writeCharacteristic(String address, String serviceID, String charID,
      Uint8List data, bool writeWithResponse) async {
    try {
      await WinBle.write(
          address: address,
          service: serviceID,
          characteristic: charID,
          data: data,
          writeWithResponse: true);
      //print("i Have just written in writeCharacteristics $data");
    } catch (e) {
      showError("writeCharError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  subsCribeToCharacteristic(address, serviceID, charID) async {
    try {
      await WinBle.subscribeToCharacteristic(
          address: address, serviceId: serviceID, characteristicId: charID);
      showSuccess("Subscribe Successfully");
    } catch (e) {
      showError("SubscribeCharError : $e");
      setState(() {
        error = e.toString() + " Date ${DateTime.now()}";
      });
    }
  }

  unSubscribeToCharacteristic(address, serviceID, charID) async {
    try {
      await WinBle.unSubscribeFromCharacteristic(
          address: address, serviceId: serviceID, characteristicId: charID);
      showSuccess("Unsubscribed Successfully");
    } catch (e) {
      showError("UnSubscribeError : $e");
      setState(() {
        error = e.toString() + " Date ${DateTime.now()}";
      });
    }
  }

  disconnect(address) async {
    try {
      await WinBle.disconnect(address);
      showSuccess("Disconnected");
    } catch (e) {
      if (!mounted) return;
      showError(e.toString());
    }
  }

  readCharacteristic(address, serviceID, charID) async {
    try {
      List<int> data = await WinBle.read(
          address: address, serviceId: serviceID, characteristicId: charID);
      print(String.fromCharCodes(data));
      setState(() {
        result =
            "Read => List<int> : $data    ,    ToString :  ${String.fromCharCodes(data)}   , Time : ${DateTime.now()}";
      });
    } catch (e) {
      showError("ReadCharError : $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  StreamSubscription? _connectionStream;
  StreamSubscription? _characteristicValueStream;

  @override
  void initState() {
    device = widget.device;
    final Data myProvider = Provider.of<Data>(context, listen: false);

    _connectionStream =
        WinBle.connectionStreamOf(device.address).listen((event) {
      //////////////////////
      //this is to be removed when the BLE is sorted as an abstraction layer
      connect(device);
      //////////////////////
    });
    _characteristicValueStream =
        WinBle.characteristicValueStream.listen((event) {
      print("CharValue : $event");
    });
    super.initState();
    _phase1CurrentTextfield =
        TextEditingController(text: myProvider.getPhase1Current.toString());
    _phase2CurrentTextfield =
        TextEditingController(text: myProvider.getPhase2Current.toString());
    _dcCurrentTargetTextfield =
        TextEditingController(text: myProvider.getDCCurrentTarget.toString());
    _dcHoldTimeTextfield =
        TextEditingController(text: myProvider.getDCHoldTime.toString());
    _rampUpTimeTextfield =
        TextEditingController(text: myProvider.getRampUpTime.toString());
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
    _rampUpTimeTextfield?.dispose();
    _endStimulationTextField?.dispose();
    _connectionStream?.cancel();
    _characteristicValueStream?.cancel();
    disconnect(device.address);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Data myProvider = Provider.of<Data>(context);
    var endStimulationTitle = Provider.of<Data>(context).endByDurationTitle;
    var value_one = "";
    return Column(
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

              onPressed: () async {
                Provider.of<Data>(context, listen: false)
                    .prepare_stimulation_values();
                var serial_command_inputs =
                    Provider.of<Data>(context, listen: false)
                        .get_serial_command_input_char;
                print(serial_command_inputs);
                for (var value in serial_command_inputs.values) {
                  writeCharacteristic(device.address, SERVICE_UUID,
                      SERIAL_COMMAND_INPUT_CHAR_UUID, value, true);
                  await Future.delayed(const Duration(milliseconds: 1), () {});
                }
              },
              icon: const Icon(
                Icons.bolt,
                size: 24.0,
              ),
              label: Text('start',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w400)), // <-- Text
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
                writeCharacteristic(
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
              label: Text('stop',
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
                    keyboardType: TextInputType.number,
                    controller: _phase1CurrentTextfield,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      num_range_formatter(min: 0, max: 3000)
                    ],
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      num_range_formatter(min: 0, max: 3000)
                    ],
                    onChanged: (value) {
                      myProvider.setphase2current(value);
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
                    controller: _dcHoldTimeTextfield,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,3}')),
                      num_range_formatter(min: 0, max: UINT32MAX)
                    ],
                    onChanged: (value) {
                      value = value * 1000;
                      myProvider.setDCHoldTime(value);
                    },
                    enabled: myProvider.getDcMode,
                    decoration: const InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber)),
                      labelText: 'DC Hold Time (s)',
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
                    controller: _dcCurrentTargetTextfield,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      num_range_formatter(min: 0, max: 3000)
                    ],
                    onChanged: (value) {
                      myProvider.setDCCurrentTarget(value);
                    },
                    enabled: myProvider.getDcMode,
                    decoration: const InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber)),
                      labelText: 'DC Current Target (µA)',
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
                  "Ramp Up Time",
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
                    controller: _rampUpTimeTextfield,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,3}')),
                      num_range_formatter(min: 0, max: UINT32MAX)
                    ],
                    onChanged: (value) {
                      value = value * 1000;
                      myProvider.setrampUpTime(value);
                    },
                    enabled: myProvider.getDcMode,
                    decoration: const InputDecoration(
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber)),
                      labelText: 'Ramp Up Time (s) (DC mode only)',
                      labelStyle: TextStyle(fontSize: 20),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
              Provider.of<Data>(context, listen: false).toggleEndByBurst(false);
              Provider.of<Data>(context, listen: false)
                  .toggleStimForever(false);
            } else if (index == 1) {
              Provider.of<Data>(context, listen: false)
                  .toggleEndByDuration(false);
              Provider.of<Data>(context, listen: false).toggleEndByBurst(true);
              Provider.of<Data>(context, listen: false)
                  .toggleStimForever(false);
            } else if (index == 2) {
              Provider.of<Data>(context, listen: false)
                  .toggleEndByDuration(false);
              Provider.of<Data>(context, listen: false).toggleEndByBurst(false);
              Provider.of<Data>(context, listen: false).toggleStimForever(true);
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
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              num_range_formatter(min: 1, max: UINT32MAX)
            ],
            onChanged: (value) {
              myProvider.setendbyvalue(value);
            },
            decoration: const InputDecoration(
              hintText: "Enter duration (s) or bursts",
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber)),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          height: 20,
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
