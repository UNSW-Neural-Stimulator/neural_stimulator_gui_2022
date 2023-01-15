import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:nstim_app/widgets/workspaceWidgets/workspaceComponents/end_stimulation_settings.dart';
import 'package:nstim_app/widgets/workspaceWidgets/workspaceComponents/right_command_bar.dart';
import 'package:nstim_app/widgets/workspaceWidgets/workspaceForms/right_inputs.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:win_ble/win_ble.dart';

class WorkspaceRight extends StatelessWidget {
  final BleDevice device;
  final StreamSubscription? connection;
  const WorkspaceRight({Key? key, required this.device, this.connection})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
              width: 600.0,
            height: 700.0,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  RightCommandBar(device: device),
                  RightInputs(device: device),
                  EndStimulationSettings(device: device)
                ],
              )),
        ),
      ),
    );
  }
}
