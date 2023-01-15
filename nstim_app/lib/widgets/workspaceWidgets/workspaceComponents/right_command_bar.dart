import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nstim_app/providers/service_layer_provider.dart';
import 'package:nstim_app/widgets/workspaceWidgets/workspaceComponents/error_dialogue.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:win_ble/win_ble.dart';

import '../../../providers/bluetooth_le_provider.dart';
import '../../../util/consts.dart';

class RightCommandBar extends StatefulWidget {
  final BleDevice device;
  const RightCommandBar({Key? key, required this.device}) : super(key: key);
  @override
  _RightCommandBarState createState() => _RightCommandBarState();
}

class _RightCommandBarState extends State<RightCommandBar> {
  late BleDevice device = widget.device;

  @override
  Widget build(BuildContext context) {
    final BluetoothLEProvider bluetoothLEProvider =
        Provider.of<BluetoothLEProvider>(context);
    final ServiceLayerProvider serviceLayerProvider =
        Provider.of<ServiceLayerProvider>(context);
    var impedanceString = Provider.of<BluetoothLEProvider>(context).getImpedance.toString();

    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 80,
              width: 340,
              color: const Color.fromARGB(255, 240, 240, 240),
              child: Row(children: [
                SizedBox(
                  width: 10,
                ),
                Icon(
                  Icons.warning_rounded,
                  color: Colors.amber,
                  size: 35,
                ),
        if (!bluetoothLEProvider.getConnected)
                    SizedBox(
            height: 45,
            child: Row(
              children: const [
                Text(
                  "     Device is not connected.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          )

else if (bluetoothLEProvider.getNotifyIntArray.isNotEmpty)
                if (bluetoothLEProvider.getNotifyIntArray[0] > 1 ) 
                  SizedBox(
                  height: 45,
                  child: Row(
                    children: const [

                      Text(
                        "    ERROR: Stimulator receiving invalid inputs.",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )
                else if (bluetoothLEProvider.getNotifyIntArray[0] == 0) 
                 SizedBox(
                  height: 45,
                  child: Row(
                    children: [

                      Text(
                        "   Stimulator is out of compliance. \n   Stimulation is stopped.",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                )



        else if (serviceLayerProvider.retrieveBoolValue("DCModeOn"))
          SizedBox(
            height: 45,
            child: Row(
              children: const [
                Text(
                  "    CAUTION: DC stimulation can be unsafe \n    if not used appropriately.",
                  style: TextStyle(
                                        fontSize: 15,
                    fontWeight: FontWeight.w500, 

                  ),
                )
              ],
            ),
          )
        else if (!serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                 (serviceLayerProvider.retrieveIntValue("phase1Current").abs() * serviceLayerProvider.retrieveIntValue("phase1TimeMicroSec") 
                 != serviceLayerProvider.retrieveIntValue("phase2Current").abs() * serviceLayerProvider.retrieveIntValue("phase1TimeMicroSec")))
        SizedBox(
            height: 45,
            child: Row(
              children: const [

                Text(
                  "    CAUTION: The waveform is charge\n    imbalanced.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          )
        else
          const SizedBox(
            height: 45,
          ),





              ]),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              children: [
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      minimumSize: const Size(150, 50),
                    ),

                    onPressed: () async {
                                              bluetoothLEProvider.clearNotifyArray();
                      setState(() {
                        
                      });
                      String allErrors = serviceLayerProvider.startStimErrorCheck(bluetoothLEProvider.getConnected);
                      if (allErrors != "") {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text(
                                      'Please address the following warnings: '),
                                  content: SingleChildScrollView(
                                    child: ErrorDialogue(description: allErrors),
                                  ));
                            });
                      } else {
                        Provider.of<ServiceLayerProvider>(context, listen: false)
                            .prepare_stimulation_values();
                        var serial_command_inputs =
                            Provider.of<ServiceLayerProvider>(context, listen: false)
                                .getSerialCommandInputChar;
                        for (var value in serial_command_inputs.values) {
                          bluetoothLEProvider.writeCharacteristic(
                              device.address,
                              SERVICE_UUID,
                              SERIAL_COMMAND_INPUT_CHAR_UUID,
                              value,
                              true);
                          await Future.delayed(
                              const Duration(milliseconds: 1), () {});
                        }
                        //Send impedance check request
                        bluetoothLEProvider.writeCharacteristic(
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
                    label: const Text('Run impedance check',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400)), // <-- Text
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 220,
                  color: const Color.fromARGB(255, 230, 230, 240),
                  child: SizedBox(
                  height: 45,
                  child:
                      Text(
                        " $impedanceString Ω",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      )

                ),
                )
              ],
            )
          ],
        ),
        SizedBox(
          height: 10,
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
                  serviceLayerProvider.setBooleanValue("DCModeOn", dcmode);
                },
                value: serviceLayerProvider.retrieveBoolValue("DCModeOn")),
            const SizedBox(
              width: 50,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                minimumSize: const Size(150, 50),
              ),

              onPressed: () async {
                String allErrors = serviceLayerProvider.startStimErrorCheck(bluetoothLEProvider.getConnected);
                if (allErrors != "") {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title:
                                Text('Please address the following warnings: '),
                            content: SingleChildScrollView(
                              child: ErrorDialogue(description: allErrors),
                            ));
                      });
                } else {
                  Provider.of<ServiceLayerProvider>(context, listen: false)
                      .prepare_stimulation_values();
                  var serial_command_inputs =
                      Provider.of<ServiceLayerProvider>(context, listen: false)
                          .getSerialCommandInputChar;
                  for (var value in serial_command_inputs.values) {
                    bluetoothLEProvider.writeCharacteristic(device.address, SERVICE_UUID,
                        SERIAL_COMMAND_INPUT_CHAR_UUID, value, true);
                    await Future.delayed(
                        const Duration(milliseconds: 1), () {});
                  }
                  bluetoothLEProvider.writeCharacteristic(
                    device.address,
                    SERVICE_UUID,
                    SERIAL_COMMAND_INPUT_CHAR_UUID,
                    start_bytearray,
                    true);
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
                bluetoothLEProvider.writeCharacteristic(
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
      ],
    );
  }
}
