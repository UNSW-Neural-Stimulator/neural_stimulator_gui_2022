
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nstim_app/util/textfield_helper_functions.dart';
import 'dart:typed_data';
import 'dart:math';
import 'package:provider/provider.dart';
///////////////////////////////////////////
/// Custom textfields with selectable units from microsec to seconds



class CustomUnitsTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType inputType;
  final bool obscureText;
  final bool enabled;
  final Function onChanged;
  final int minValue;
  final int maxValue;

  CustomUnitsTextField({
    required this.controller,
    required this.onChanged,
    this.inputType = TextInputType.text,
    this.obscureText = false,
    required this.labelText,
    required this.enabled,
    required this.minValue,
    required this.maxValue,
  });

  _CustomUnitsTextFieldState createState() => _CustomUnitsTextFieldState();
}

class _CustomUnitsTextFieldState extends State<CustomUnitsTextField> {

  String dropdownValue = 'µs';
  var inputtedNumberAsInt;
  double inputtedNumber = 0.0;
  Map dropDownExponents = {'µs': 0, 'ms': 1, 's': 2};
  @override
  Widget build(BuildContext context) {
    // final Data myProvider = Provider.of<Data>(context, listen: false);
    // if (myProvider.getPrepareUpdatePreset) {
    //   dropdownValue = 'µs';
    // }
    String input = widget.controller!.text;
    inputtedNumber = double.tryParse(input) ?? 0.0;
    return Row(children: [
      SizedBox(
        width: 200,
        child: TextField(
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          controller: widget.controller,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r"([0-9]+\.?[0-9]*|\.[0-9]+)")),
            LengthLimitingTextInputFormatter(20),
          ],
          onChanged: (value) {
            if (value != '') {
              inputtedNumber = double.parse(value);
            }

            switch (dropdownValue) {
              case 'µs':
                inputtedNumberAsInt = (inputtedNumber).round();
                break;
              case 'ms':
                inputtedNumberAsInt = (inputtedNumber * 1000).round();
                break;
              case 's':
                inputtedNumberAsInt = (inputtedNumber * 1000000).round();
                break;
            }

            if (widget.onChanged != null) {
              widget.onChanged(inputtedNumberAsInt.toString());
            }
          },
          decoration: InputDecoration(
            errorText: textfieldInputError(widget.minValue, widget.maxValue,
                dropdownValue, widget.controller!.text),
            disabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            labelText: widget.labelText,
            labelStyle: TextStyle(fontSize: 20),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          ),
        ),
      ),
      SizedBox(
        width: 5,
      ),
      DropdownButton<String>(
        value: dropdownValue,
        elevation: 16,
        style: const TextStyle(color: Colors.black),
        onChanged: (String? newValue) {
          setState(() {
            switch (newValue!) {
              case 'µs':
                widget.controller?.text = (inputtedNumber *
                        pow(
                            1000,
                            (dropDownExponents[dropdownValue] -
                                dropDownExponents[newValue])))
                    .toString();

                break;
              case 'ms':
                widget.controller?.text = (inputtedNumber *
                        pow(
                            1000,
                            (dropDownExponents[dropdownValue] -
                                dropDownExponents[newValue])))
                    .toString();
                break;
              case 's':
                widget.controller?.text = (inputtedNumber *
                        pow(
                            1000,
                            (dropDownExponents[dropdownValue] -
                                dropDownExponents[newValue])))
                    .toString();
                break;
            }
            dropdownValue = newValue;
          });
        },
        items: <String>['µs', 'ms', 's']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )
    ]);
  }
}
