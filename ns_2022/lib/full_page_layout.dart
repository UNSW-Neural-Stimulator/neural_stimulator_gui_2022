import 'workspace.dart';
import 'list_devices.dart';
import 'package:flutter/material.dart';

class FullPageContainer extends StatefulWidget {
  const FullPageContainer({Key? key}) : super(key: key);

  @override
  _FullPageContainerState createState() =>
      _FullPageContainerState();
}

class _FullPageContainerState extends State<FullPageContainer> {

  Widget _buildFullPageLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
            elevation: 4.0,
            child: ItemListing(),
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