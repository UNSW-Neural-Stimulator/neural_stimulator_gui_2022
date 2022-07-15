import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ns_2022/helper_and_const.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import "data_provider.dart";
import 'workspace_widgets/right_side_workspace_widgets.dart';
import 'workspace_widgets/left_side_workspace_widgets.dart';
import 'package:win_ble/win_ble.dart';

class workspace extends StatefulWidget {
  final BleDevice device;
  final StreamSubscription? connection;
  const workspace({Key? key, required this.device, this.connection}) : super(key: key);

  @override
  _workspaceState createState() => _workspaceState();
}

class _workspaceState extends State<workspace> {
  late BleDevice device;
  late StreamSubscription? connectionstream;
  @override
  Widget build(BuildContext context) {
    var phase1Time = Provider.of<Data>(context).getPhase1Time;
    var interPhaseDelayTime = Provider.of<Data>(context).getInterPhaseDelay;
    var phase2Time = Provider.of<Data>(context).getPhase2Time;
    var interstimDelayTime = Provider.of<Data>(context).getInterstimDelay;
    // var start = Provider.of<Data>(context).getstart;
    var endbyduration = Provider.of<Data>(context).endByDuration;
    var endbyburst = Provider.of<Data>(context).endByBurst;
    var stimforever = Provider.of<Data>(context).stimilateForever;
    //debug
    var anodic_cathodic = Provider.of<Data>(context).getCathodicFirst;
    /////////////////////////////////////////////////////////////////////////

    //must change all values to 0 when not in screen

    /////////////////////////////////////////////////////////////////////////

    int width;
    final content = Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: [
          SizedBox(width: 600, child: SingleChildScrollView(scrollDirection: Axis.horizontal, child:leftTextFields())),
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 600,
            child: SingleChildScrollView(scrollDirection: Axis.horizontal, child:RightSideInputs(device: widget.device, )),
          )
        ]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Device Name: " + widget.device.name),
      ),
      body:  ListView(children:[content])
     ,
     // this is a debug feature, must be removed before compilation
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('AlertDialog Title'),
            content: Text(
                "Phase 1 Time (μs): $phase1Time\nInter-Phase Delay (μs): $interPhaseDelayTime\n"
                "Phase 2 Time (μs): $phase2Time\nInter-stim Delay (μs): $interstimDelayTime\n"
                "anodic_cathodic: $anodic_cathodic\n"
                "endbyduration: $endbyduration\n"
                "endbyburst: $endbyburst\n"
                "stimforever: $stimforever\n"),
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

////////////////////////////////////////////////////////////////////

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
              decoration: const BoxDecoration(color: Colors.grey),
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 102, 102, 102)),
                child: Row(
                  children: const <Widget>[
                    Expanded(
                      child: Text(
                        'Beginners Tutorial',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 30,
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              )),
        ))
      ],
    );

    return Scaffold(
      body: Center(child: content),
    );
  }
}
