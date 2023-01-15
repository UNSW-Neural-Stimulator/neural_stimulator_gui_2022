import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nstim_app/widgets/workspaceWidgets/workspaceForms/left_inputs.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:win_ble/win_ble.dart';
import '../workspaceComponents/connection_bar.dart';
class WorkspaceLeft extends StatefulWidget {
  final BleDevice device;
  final StreamSubscription? connection;
  const WorkspaceLeft({Key? key, required this.device, this.connection})
      : super(key: key);

  @override
  _WorkspaceLeftState createState() => _WorkspaceLeftState();
}



class _WorkspaceLeftState extends State<WorkspaceLeft> {
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 600.0,
            height: 650.0,
            child: Column(children: [
              SizedBox(height: 10,),
              ConnectionBar(device: widget.device),
              LeftInputs(device: widget.device),
            ]),
            ),
          ),
        ),
      );
  }
}
