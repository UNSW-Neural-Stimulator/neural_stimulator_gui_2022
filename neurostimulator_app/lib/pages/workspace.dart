import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ns_2022/util/consts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import "../data_provider.dart";
import '../workspace_widgets/right_side_workspace_widgets.dart';
import '../workspace_widgets/left_side_workspace_widgets.dart';
import 'package:win_ble/win_ble.dart';
import 'package:google_fonts/google_fonts.dart';

class workspace extends StatefulWidget {
  final BleDevice device;
  final StreamSubscription? connection;
  const workspace({Key? key, required this.device, this.connection})
      : super(key: key);

  @override
  _workspaceState createState() => _workspaceState();
}

class _workspaceState extends State<workspace> {
  late StreamSubscription? connectionstream;
  @override
  Widget build(BuildContext context) {
    int width;
    final content = Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: [
          SizedBox(
              width: 600,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: leftTextFields(device: widget.device))),
          SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 600,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RightSideInputs(
                  device: widget.device,
                )),
          )
        ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        leading: IconButton(
          icon:
              const Icon(Icons.home, color: Color.fromARGB(255, 116, 116, 116)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Workspace for " + widget.device.name,
          style: TextStyle(color: Color.fromARGB(255, 61, 61, 61)),
        ),
      ),
      body: ListView(children: [content]),
   
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
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    SizedBox(
                      height: 70,
                    ),
                                        Image.asset('assets/images/StimpactLogo.png',
                         width: 600,
                        height: 300,
                        fit:BoxFit.fill),
                    // Text(
                    //   "Stimpact",
                    //   style: GoogleFonts.orbitron(
                    //       fontSize: 80, color: Color.fromARGB(255, 0, 60, 109)),
                    // ),
                    Text(
                      "Stimulating Research | v5.0",
                      style: GoogleFonts.montserrat(
                          fontSize: 20, color: Color.fromARGB(255, 0, 60, 109)),
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
                )))
      ],
    );

    return Scaffold(
      body: Center(child: content),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Need help connecting?'),
        icon: Icon(Icons.question_mark_sharp),
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Connecting your Stimpact device:',
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 0, 60, 109),
              ),
            ),
            content: Text(
                "- To connect a device, click the \"Scan for 10 seconds\" button \n  and select a device from the list generated to connect with it."
                "\n\nIf you still can't connect to your device:"
                "\n\n- Check if bluetooth is enabled on your computer's settings."
                "\n- Try turning the neurostimulator off and on."
                "\n\n\n* The current version of this application is compatible for  Windows version 10.0.15014 and above."),
            actions: <Widget>[
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

