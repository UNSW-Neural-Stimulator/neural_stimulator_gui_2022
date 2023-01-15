import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:ns_2022/util/consts.dart';
// import 'package:provider/provider.dart';
// import 'package:win_ble/win_ble.dart';

  
class homeDisplay extends StatelessWidget {
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