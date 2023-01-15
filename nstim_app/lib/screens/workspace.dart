import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

import 'package:win_ble/win_ble.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/workspaceWidgets/workspaceSections/workspace_left.dart';
import '../widgets/workspaceWidgets/workspaceSections/workspace_right.dart';

class Workspace extends StatefulWidget {
  final BleDevice device;
  final StreamSubscription? connection;
  const Workspace({Key? key, required this.device, this.connection})
      : super(key: key);

  @override
  _WorkspaceState createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  late StreamSubscription? connectionstream;
  @override
  Widget build(BuildContext context) {
    final content = Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        direction: Axis.horizontal,
        children: [
          WorkspaceLeft(device: widget.device),
          SizedBox(
            width: 10,
          ),
          WorkspaceRight(device: widget.device),
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
