import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:nested/nested.dart';

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

    /////////////////////////////////////////////////////////////////////////

    //must change all values to 0 when not in screen

    /////////////////////////////////////////////////////////////////////////

    final textTheme = Theme.of(context).textTheme;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ 
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: Container(
                height: 300,
                width: 600,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child:  
                    const MyCustomForm(),
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


class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  TextEditingController? _textField1;
  TextEditingController? _textField2;
  TextEditingController? _textField3;
  TextEditingController? _textField4;


  @override
  void initState() {
    final Data myProvider = Provider.of<Data>(context, listen: false);

    super.initState();
    _textField1 = TextEditingController(text: myProvider.getPhase1TimeString);
    _textField2 = TextEditingController(text: myProvider.getInterPhaseDelayString);
    _textField3 = TextEditingController(text: myProvider.getPhase2TimeString);
    _textField4 = TextEditingController(text: myProvider.getInterstimDelayString);
  }

  @override
  void didChangeDependencies() {
    _textField1!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getPhase1TimeString;
    _textField2!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getInterPhaseDelayString;
    _textField3!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getPhase2TimeString;
    _textField4!.text = Provider.of<Data>(
      context,
      listen: true, // Be sure to listen
    ).getInterstimDelayString;
  super.didChangeDependencies();
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textField1?.dispose();
    _textField2?.dispose();
    _textField3?.dispose();
    _textField4?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Data myProvider = Provider.of<Data>(context);    

    return 
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
                      controller: _textField1,
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
                      controller: _textField2,
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
                      controller: _textField3,
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
                      controller: _textField4,
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
          );
  }

}




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