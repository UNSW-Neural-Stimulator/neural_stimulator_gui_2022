import 'data_provider.dart';
import 'package:provider/provider.dart';

import 'full_page_layout.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Data (),
        ),
      ],
      child: MaterialApp (
              theme: ThemeData (
                          primarySwatch: Colors.blue,
                      ),
              home: const FullPageContainer(),

             ),
          ); 
  }
}