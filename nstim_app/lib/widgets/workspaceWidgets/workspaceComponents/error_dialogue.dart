import 'package:flutter/material.dart';

class ErrorDialogue extends StatefulWidget {
  const ErrorDialogue({
    Key? key,
    required this.description,
  }) : super(key: key);

  final String description;
  @override
  State<ErrorDialogue> createState() => _ErrorDialogueState();
}

class _ErrorDialogueState extends State<ErrorDialogue> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: 
      Container(
        alignment: Alignment.centerLeft,
        height: 220.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
              height: 150,
              width: 200,
              alignment: Alignment.centerLeft,
              child: Column(
                children: [Text(widget.description)],
              )),
          SizedBox(
            height: 10,
          ),
          TextButton(
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red, fontSize: 15),
            ),
            onPressed: () => Navigator.pop(context),
          )
        ]),
      ),
    );
  }
}
