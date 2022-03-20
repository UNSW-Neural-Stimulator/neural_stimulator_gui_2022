import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'device_item.dart';
import 'list_devices.dart';

class workspace extends StatelessWidget {
  const workspace({Key? key, required this.deviceNumber}) : super(key: key);

  final int deviceNumber;


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ 
        Expanded(
          child: Container(
            alignment: Alignment.topLeft,
            child: Container(
                height: 300,
                width: 600,
                alignment: Alignment.topCenter,
                margin: EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255)
                ),
                child: const 
                    MyCustomForm(title: "Phase Time"),
                ),
            )
            
        )
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
      
    );
  }
}


class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _MyCustomFormState extends State<MyCustomForm> {
  
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final textField1 = TextEditingController();
  final textField2 = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textField1.dispose();
    textField2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myController = TextEditingController();

    return 
      Container(
        height: 300,
        width: 300,
        child: Column(
          children: [
            Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 102, 102, 102)
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(widget.title, 
                                    style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), 
                                                    fontSize: 30,
                                                    fontFamily: 'Raleway', 
                                                    fontWeight: FontWeight.w300,
                                                    ),
                                    textAlign: TextAlign.center,
                                    
                                    ),
                        )
                      ],
                    ),
                  ),
                  const Text("Phase 1 Time (μs)", 
                                    style: TextStyle(color: Color.fromARGB(255, 48, 48, 48), 
                                                    fontSize: 15,
                                                    fontFamily: 'Raleway', 
                                                    fontWeight: FontWeight.w500,
                                                    ),
                                    textAlign: TextAlign.center,
                                    
                                    ),
                  TextField(
                      keyboardType: TextInputType.number,
                      controller: textField1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: "Enter a numeric value"),
                  ),
                  const Text("Inter-Phase Delay (μs)", 
                                    style: TextStyle(color: Color.fromARGB(255, 48, 48, 48), 
                                                    fontSize: 15,
                                                    fontFamily: 'Raleway', 
                                                    fontWeight: FontWeight.w500,
                                                    ),
                                    textAlign: TextAlign.center,
                                    
                                    ),
                  TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: textField2,
                    decoration: const InputDecoration(labelText: "Enter a numeric value"),
                  ),

          ],

        ),

      );
  }
}




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
                decoration: const BoxDecoration(
                  color: Colors.grey
                ),
                child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 102, 102, 102)
                    ),
                    child: Row(
                      children: const <Widget>[
                        Expanded(
                          
                          child: Text('Beginners Tutorial', 
                                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), 
                                                    fontSize: 30,
                                                    fontFamily: 'Raleway', 
                                                    fontWeight: FontWeight.w300,
                                                    ),
                                    textAlign: TextAlign.center,

                                    
                                    ),
                        )
                      ],
                    ),
                  )
              ),

            )
            
        )
      

      ],
    );

    return Scaffold(
      body: Center(child: content),
    );
  }
}