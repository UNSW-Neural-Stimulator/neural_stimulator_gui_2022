import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:nested/nested.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'device_item.dart';
import 'list_devices.dart';
import "data_provider.dart";

class workspace extends StatefulWidget {
  const workspace({Key? key, deviceNumber}) : super(key: key);

  @override
  _workspaceState createState() => _workspaceState();
}



class _workspaceState extends State<workspace> {


  @override
  Widget build(BuildContext context) {
    var phase1Time = Provider.of<Data>(context).getPhase1Time;
    var interPhaseDelayTime = Provider.of<Data>(context).getInterPhaseDelay;
    var phase2Time = Provider.of<Data>(context).getPhase2Time;
    var interstimDelayTime = Provider.of<Data>(context).getInterstimDelay;
    var deviceNumber = Provider.of<Data>(context).getDeviceNumber;
    var start = Provider.of<Data>(context).getstart;
    var endbyduration = Provider.of<Data>(context).endByDuration;
    var endbyburst= Provider.of<Data>(context).endByBurst;
    var stimforever = Provider.of<Data>(context).stimilateForever;



    /////////////////////////////////////////////////////////////////////////

    //must change all values to 0 when not in screen

    /////////////////////////////////////////////////////////////////////////

    final textTheme = Theme.of(context).textTheme;
    final content =       
      Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ 
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child:  Row( children: [
                    const leftTextFields(),
                    const RightSideInputs(),
                ]
                ),
                ),
            )
            
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: const Icon(Icons.home, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
        ), 
        title: Text("Workspace for device: $deviceNumber"),
      ),
      body: Center(child: content),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('AlertDialog Title'),
          content:Text("Phase 1 Time (μs): $phase1Time\nInter-Phase Delay (μs): $interPhaseDelayTime\n"
                       "Phase 2 Time (μs): $phase2Time\nInter-stim Delay (μs): $interstimDelayTime\n"                       
                       "start: $start"
                       "endbyduration: $endbyduration\n"
                       "endbyburst: $endbyburst\n"
                       "stimforever: $stimforever\n"


                        ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      ),


      ),
    );
  }
}


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

  @override
  void initState() {
    final Data myProvider = Provider.of<Data>(context, listen: false);

    super.initState();
    _phase1Textfield = TextEditingController(text: myProvider.getPhase1TimeString);
    _interPhaseDelayTextfield = TextEditingController(text: myProvider.getInterPhaseDelayString);
    _phase2Textfield = TextEditingController(text: myProvider.getPhase2TimeString);
    _interStimDelayTexfield = TextEditingController(text: myProvider.getInterstimDelayString);
    _burstPeriodTextfield = TextEditingController(text: myProvider.getBurstPeriodMsString);
    _dutyCycleTextfield = TextEditingController(text: myProvider.getDutyCycleString);
  }

  @override
  void didChangeDependencies() {
    _phase1Textfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getPhase1TimeString;
    _interPhaseDelayTextfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getInterPhaseDelayString;
    _phase2Textfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getPhase2TimeString;
    _interStimDelayTexfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getInterstimDelayString;
    _burstPeriodTextfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getBurstPeriodMsString;
    _dutyCycleTextfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getDutyCycleString;
  super.didChangeDependencies();
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Data myProvider = Provider.of<Data>(context);    

    return 
        Column( 
          children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(height: 10),
                  const Text("Phase Time", style: TextStyle( color: Color.fromARGB(255, 0, 60, 109), fontWeight: FontWeight.bold, fontSize: 30),),
                  const SizedBox(height: 10),
                  SizedBox( 
                    width: 250,
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _phase1Textfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setphase1(value);},
                      decoration: const InputDecoration(
                        labelText: 'Phase 1 Time (µs)',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        ),
                      ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox( 
                    width: 250,
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _interPhaseDelayTextfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setinterphasedelay(value);},
                      decoration: const InputDecoration(
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
                  const SizedBox(height: 10),
                  const Text("Frequency", style: TextStyle( color: Color.fromARGB(255, 0, 60, 109), fontWeight: FontWeight.bold, fontSize: 30),),
                  const SizedBox(height: 10),
                  SizedBox( 
                    width: 250,
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _phase2Textfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setphase2(value);},
                      decoration: const InputDecoration(
                        labelText: 'Phase 2 Time (µs)',
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        ),
                      ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox( 
                    width: 250,
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _interStimDelayTexfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setinterstimdelay(value);},
                      decoration: const InputDecoration(
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
                  const Text("Burst Cycle", style: TextStyle( color: Color.fromARGB(255, 0, 60, 109), fontWeight: FontWeight.bold, fontSize: 30),),
                  const SizedBox(height: 10),
                  SizedBox( 
                    width: 250,
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _burstPeriodTextfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setburstcycle(value);},
                      decoration: const InputDecoration(
                        labelText: 'Burst Cycle (ms)',
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
                  const Text("Duty cycle", style: TextStyle( color: Color.fromARGB(255, 0, 60, 109), fontWeight: FontWeight.bold, fontSize: 30),),
                  const SizedBox(height: 10),
                  SizedBox( 
                    width: 250,
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _dutyCycleTextfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setdutycycle(value);},
                      decoration: const InputDecoration(
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

        
        ],
      );
  }

}

////////////////////////////////////////////////////////////////////


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
    _phase1CurrentTextfield = TextEditingController(text: myProvider.getPhase1CurrentString);
    _phase2CurrentTextfield = TextEditingController(text: myProvider.getPhase2CurrentString);
    _vref0Textfield = TextEditingController(text: myProvider.getVref0String);
    _vref65535Texfield = TextEditingController(text: myProvider.getVref65535String);
    _endStimulationTextField = TextEditingController(text: myProvider.getendByValue);
    List<bool> fixedLengthList;

  }

  @override
  void didChangeDependencies() {
    _phase1CurrentTextfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getPhase1CurrentString;
    
    _phase2CurrentTextfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getPhase2CurrentString;

    _vref0Textfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getVref0String;

    _vref65535Texfield!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getVref65535String;

    _endStimulationTextField!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getendByValue;

    fixedLengthList = [Provider.of<Data>(context).endByDuration, Provider.of<Data>(context).endByBurst,  Provider.of<Data>(context).stimilateForever];
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
    return 
      Expanded(child: 
        Column( 
          children: [
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  
                  SizedBox(
                    height: 40,
                    width: 100,
                    child:
                      ElevatedButton.icon(
                          onPressed: () {
                              // Respond to button press by saving all values
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.green, textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          icon: Icon(Icons.save, size: 18),
                          label: Text("save"),
                        )               
                  ),
                  SizedBox(width: 50,),
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
                    value: Provider.of<Data>(context).getDcMode,  // remove `listen: false` 
                  ),
                  SizedBox(width: 50,),
                  FlutterSwitch(
                    activeColor: Colors.green,
                    inactiveColor: Colors.red,
                    activeText: "On",
                    inactiveText: "Off",
                    width: 70,
                    height: 40,
                    activeTextColor: Colors.white,
                    showOnOff: true,
                    onToggle: (bool start) {
                      Provider.of<Data>(context, listen: false).togglestart(start);
                    },
                    value: Provider.of<Data>(context).getstart,  // remove `listen: false` 
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
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _phase1CurrentTextfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setphase1current(value);},
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
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _phase2CurrentTextfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setinterphasedelay(value);},
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
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _vref0Textfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setvref0(value);},
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
                    child:
                      TextField(
                      keyboardType: TextInputType.number,
                      controller: _vref65535Texfield,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setvref65535(value);},
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
          SizedBox(height: 10,),
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
                      Provider.of<Data>(context, listen: false).toggleCathodicAnodic(cathodic);
                    },
                    value: Provider.of<Data>(context).getCathodicFirst,  // remove `listen: false` 
            ),
          SizedBox(height: 10,),
          Text("End stimulation by:"),
          SizedBox(height: 10,),
          ToggleButtons(
              constraints: BoxConstraints(minWidth: 160, minHeight: 50),
              children: <Widget>[
                Text("Stimulation Duration (s)"),
                Text("Number of Bursts"),
                Text("Stimulate Forever"),
              ],
              onPressed: (int index) {
                  if (index == 0) {
                    Provider.of<Data>(context, listen: false).toggleEndByDuration(true);
                    Provider.of<Data>(context, listen: false).toggleEndByBurst(false);
                    Provider.of<Data>(context, listen: false).toggleStimForever(false);
                  }
                  else if (index == 1) {
                    Provider.of<Data>(context, listen: false).toggleEndByDuration(false);
                    Provider.of<Data>(context, listen: false).toggleEndByBurst(true);
                    Provider.of<Data>(context, listen: false).toggleStimForever(false);
                  }
                  else if (index == 2) {
                    Provider.of<Data>(context, listen: false).toggleEndByDuration(false);
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
                    child:
                      TextField(
                      enabled: !Provider.of<Data>(context).stimilateForever,
                      keyboardType: TextInputType.number,
                      controller: _endStimulationTextField,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onSubmitted:(value) {myProvider.setendbyvalue(value);},
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




////////////////////////////////////////////////////////////////////



class workspaceHome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ 
        Expanded(
          child: Container(
            alignment: Alignment.topRight,
            child: Container(
                height: 300,
                width: 300,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.grey
                ),
                child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 102, 102, 102)
                    ),
                    child: Row(
                      children: const <Widget>[
                        Expanded(
                          
                          child: Text('Beginners Tutorial', 
                                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), 
                                                    fontSize: 30,
                                                    fontFamily: 'Raleway', 
                                                    fontWeight: FontWeight.w300,
                                                    ),
                                    textAlign: TextAlign.center,

                                    
                                    ),
                        )
                      ],
                    ),
                  )
              ),

            )
            
        )
      

      ],
    );

    return Scaffold(
      body: Center(child: content),
    );
  }
}