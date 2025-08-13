import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final TextEditingController _saltosPrevios = TextEditingController(text: '0');
  final TextEditingController _caidaLibrePrevia = TextEditingController(text: '0');



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("SETTINGS")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Form(child: ListView(
          children: [
            SizedBox(height: 20,),
            TextFormField(
              controller: _saltosPrevios,
              decoration: InputDecoration(labelText: 'Numero de saltos previos.'),
              keyboardType: TextInputType.number,
              
            ),
            SizedBox(height: 20,),
            TextFormField(
              controller: _caidaLibrePrevia,
              decoration: InputDecoration(labelText: 'Caida libre previa en segundos.'),
              keyboardType: TextInputType.number,
            ),
          ],
        )),
      ),
    );
  }
}
