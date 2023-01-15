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

class RightInputs extends StatefulWidget {
  final BleDevice device;
  const RightInputs({Key? key, required this.device}) : super(key: key);
  @override
  _RightInputsState createState() => _RightInputsState();
}

class _RightInputsState extends State<RightInputs> {
  late BleDevice device = widget.device;

  // Create text controllers and use them to retrieve the current value
  // of the TextFields.
  TextEditingController? _phase1CurrentTextfield;
  TextEditingController? _phase2CurrentTextfield;
  TextEditingController? _dcCurrentTargetTextfield;
  TextEditingController? _dcHoldTimeTextfield;
  TextEditingController? _rampUpTimeTextfield;
  TextEditingController? _dcBurstGapTextfield;


  /// initstate is called when the widget is built, it initialises all the textfields
  /// with their respective values in provider.
  @override
  void initState() {
    device = widget.device;
    final ServiceLayerProvider serviceLayerProvider =
        Provider.of<ServiceLayerProvider>(context, listen: false);
    super.initState();
    _phase1CurrentTextfield = TextEditingController(
        text:
            serviceLayerProvider.retrieveIntValue("phase1Current").toString());
    _phase2CurrentTextfield = TextEditingController(
        text:
            serviceLayerProvider.retrieveIntValue("phase2Current").toString());
    _dcCurrentTargetTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("DCCurrent").toString());
    _dcHoldTimeTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("DCHoldtime").toString());
    _dcBurstGapTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("DCBurstGap").toString());
    _rampUpTimeTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("RampUpTime").toString());
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

  }

  @override
  Widget build(BuildContext context) {
    final ServiceLayerProvider serviceLayerProvider =
        Provider.of<ServiceLayerProvider>(context);
    final BluetoothLEProvider bluetoothLEProvider =
        Provider.of<BluetoothLEProvider>(context);


    if (serviceLayerProvider.getUpdatePreset) {
      setState(() {
    _phase1CurrentTextfield = TextEditingController(
        text:
            serviceLayerProvider.retrieveIntValue("phase1Current").toString());
    _phase2CurrentTextfield = TextEditingController(
        text:
            serviceLayerProvider.retrieveIntValue("phase2Current").toString());
    _dcCurrentTargetTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("DCCurrent").toString());
    _dcHoldTimeTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("DCHoldtime").toString());
    _dcBurstGapTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("DCBurstGap").toString());
    _rampUpTimeTextfield = TextEditingController(
        text: serviceLayerProvider.retrieveIntValue("RampUpTime").toString());
      });
    }



    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Row(
          children: [
                        const SizedBox(
              width: 30,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                enabled: !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                keyboardType: TextInputType.number,
                controller: _phase1CurrentTextfield,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(18),
                ],
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue("phase1Current", value);
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
                    errorText: GenericErrorString(
                        serviceLayerProvider
                            .retrieveIntValue("phase1Current")
                            .abs(),
                        3000,
                        0,
                        "Must be <= 3000")),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
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
                  serviceLayerProvider.setIntegerValue("DCCurrent", value);
                },
                enabled: serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                decoration: InputDecoration(
                    disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    labelText: 'DC Current Target (µA)',
                    labelStyle: TextStyle(fontSize: 20),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    errorText: GenericErrorString(
                        serviceLayerProvider.retrieveIntValue("DCCurrent"),
                        3000,
                        0,
                        "Must be less than 3000")),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
                                        const SizedBox(
              width: 30,
            ),
            SizedBox(
              width: 250,
              child: TextField(
                enabled: !serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                keyboardType: TextInputType.number,
                controller: _phase2CurrentTextfield,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(18),
                ],
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue("phase2Current", value);
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
                    errorText: GenericErrorString(
                        serviceLayerProvider
                            .retrieveIntValue("phase2Current")
                            .abs(),
                        3000,
                        0,
                        "Must be <= 3000")),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 250,
              child: CustomUnitsTextField(
                enabled: serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                controller: _dcHoldTimeTextfield,
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue("DCHoldtime", value);
                },
                labelText: 'DC Hold Time',
                minValue: 0,
                maxValue: UINT32MAX,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          
          children: [
                                                const SizedBox(
              width: 30,
            ),
            SizedBox(
              width: 250,
              child: CustomUnitsTextField(
                enabled: serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                controller: _rampUpTimeTextfield,
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue("rampUpTime", value);
                },
                labelText: 'Ramp Up/Down Time ',
                minValue: 0,
                maxValue: UINT32MAX,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 250,
              child: CustomUnitsTextField(
                enabled: serviceLayerProvider.retrieveBoolValue("DCModeOn") &&
                    bluetoothLEProvider.getConnected,
                controller: _dcBurstGapTextfield,
                onChanged: (value) {
                  serviceLayerProvider.setIntegerValue("DCBurstGap", value);
                },
                labelText: 'DC Burst Gap',
                minValue: 0,
                maxValue: UINT32MAX,
              ),
            ),
          ],
        ),

      ],
    );
  }
}
