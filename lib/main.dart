import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/widget_tree.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(valueListenable: darkMode, builder: (context, valorcito, child) {
      return
      MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: valorcito ? Brightness.dark : Brightness.light,
        )),
      home: WidgetTree(),
    );
    },);
  }
}