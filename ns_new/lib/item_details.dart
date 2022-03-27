import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

import 'item.dart';

class ItemDetails extends StatelessWidget {

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