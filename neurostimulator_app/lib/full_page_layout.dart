import 'workspace.dart';
import 'device_list.dart';
import 'package:flutter/material.dart';

class FullPageLayout extends StatefulWidget {
  const FullPageLayout({Key? key}) : super(key: key);

  @override
  _FullPageLayoutState createState() =>
      _FullPageLayoutState();
}


/*
The full page layout holds the list of devices and the homepage on the right
*/ 

class _FullPageLayoutState extends State<FullPageLayout> {

  Widget _buildFullPageLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
            elevation: 4.0,
            child: DeviceList(),
            ),
          ),
      
        Flexible(
          flex: 3,
          child: workspaceHome(),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
     content = _buildFullPageLayout();
     return Scaffold(
        body: content,
    );
  }
}