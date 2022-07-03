
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import "data_provider.dart";
import 'workspace_widgets/right_side_workspace_widgets.dart';
import 'workspace_widgets/left_side_workspace_widgets.dart';

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
    var endbyburst = Provider.of<Data>(context).endByBurst;
    var stimforever = Provider.of<Data>(context).stimilateForever;

    /////////////////////////////////////////////////////////////////////////

    //must change all values to 0 when not in screen

    /////////////////////////////////////////////////////////////////////////

    int width;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
          alignment: Alignment.topLeft,
          child: Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.all(20),
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
            child: Row(children: const [
              SizedBox(width: 10),
              leftTextFields(),
              RightSideInputs(),
            ]),
          ),
        ))
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
            content: Text(
                "Phase 1 Time (μs): $phase1Time\nInter-Phase Delay (μs): $interPhaseDelayTime\n"
                "Phase 2 Time (μs): $phase2Time\nInter-stim Delay (μs): $interstimDelayTime\n"
                "start: $start"
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
