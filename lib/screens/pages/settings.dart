import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/pages/settings_basejump.dart';
import 'package:terminal_salto_libre/screens/pages/settings_skydiving.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

 //. Controladores
final TextEditingController _landingAltitudeController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings () async {
    int altitud = await JumpLogDatabase.getLandingAltitude();
    _landingAltitudeController.text = altitud.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("SETTINGS")),
      body: Column(children: [
        TabBar(tabs: [Tab(text: "Skydiving",),Tab(text: "Basejump",)]),
        Expanded(
          child: TabBarView(children: [
            SettingsSkydiving(),
            SettingsBasejump()
          ]),
        ),
        //.Boton sistema de medidas.
              SizedBox(height: 5),
              ValueListenableBuilder(
                valueListenable: isImperialSystemNotifier,
                builder: (BuildContext context, bool valorcito, Widget? child) {
                  return  SwitchListTile.adaptive(value: valorcito,
                            onChanged: (newValue) async{
                              JumpLogDatabase.updateImperialSystem(newValue?1:0); //actualizo la base de datos
                              isImperialSystemNotifier.value = await JumpLogDatabase.isImperialSystem() == 1; // actualizo el notifer
                            },
                            title: Text("Imperial System of units."),
                            );
                },
              ),
              SizedBox(height: 5),
              ValueListenableBuilder(
                valueListenable: isImperialSystemNotifier,
                builder: (BuildContext context, bool valorcito, Widget? child) {
                  return  SwitchListTile.adaptive(value: !valorcito,
                            onChanged: (newValue) async{
                              JumpLogDatabase.updateImperialSystem(newValue?0:1); //actualizo la base de datos
                              isImperialSystemNotifier.value = await JumpLogDatabase.isImperialSystem() == 1; // actualizo el notifer
                            },
                            title: Text("International System of units."),
                            );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: _landingAltitudeController,
                  keyboardType: TextInputType.numberWithOptions(),
                  decoration: InputDecoration(labelText: 'Landing Altitude en metros.'),
                  onEditingComplete: () async {
                    ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                    try{
                      int updated = await JumpLogDatabase.setLandingAltitude(int.tryParse(_landingAltitudeController.text) ?? 0);
                      if(updated == 1){messenger.showSnackBar(SnackBar(content: Text('✅ Se actualizo con exito la altura del Landing.')));}
                    }catch(error){messenger.showSnackBar(SnackBar(content: Text('❌ Error: $error')));}
                  },
                  
                ),
              )
        ],),
    ));
  }

}
