import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  //. Controladores
  final TextEditingController _previousJumps = TextEditingController(text: '');
  final TextEditingController _previousFreefall = TextEditingController();
  final TextEditingController _previousTandems = TextEditingController();
  final TextEditingController _previousAffs = TextEditingController();
  final TextEditingController _previousCameras = TextEditingController();
  final TextEditingController _previousCoaches = TextEditingController();
  final TextEditingController _previousFunJumps = TextEditingController();

  @override
  void initState(){
    super.initState();
    _loadSettings();
  }

  //. Metodo para limpiar memoria cache.
  @override
  void dispose() {
    _previousJumps.dispose();
    _previousFreefall.dispose();
    _previousTandems.dispose();
    _previousAffs.dispose();
    _previousCameras.dispose();
    _previousCoaches.dispose();
    _previousFunJumps.dispose();
    super.dispose();
  }

  //. Funcion para crear objeto initSettingsLog y asignarlo en la carga de la ruta.
  Future<void> _loadSettings() async {
    SettingsLog log = await JumpLogDatabase.getSettingsLog();
      _previousJumps.text = log.previousJumps.toString();
      _previousFreefall.text = log.previousFreefall.toString();
      _previousTandems.text = log.previousTandems.toString();
      _previousAffs.text = log.previousAffs.toString();
      _previousCameras.text = log.previousCameras.toString();
      _previousCoaches.text = log.previousCoaches.toString();
      _previousFunJumps.text = log.previousFunJumps.toString();
    }

  //. Funcion para crear objeto SettingLog para guardarlo en db
  Future<void> _onSave() async{
    
    //construimos un objeto tipo SettingLog para guardarlo en la db en la tabla 'settings'.
    final SettingsLog log =SettingsLog(
      previousJumps: int.tryParse(_previousJumps.text) ?? 0,
       previousFreefall: int.tryParse(_previousFreefall.text) ?? 0,
       previousTandems: int.tryParse(_previousTandems.text) ?? 0,
       previousAffs: int.tryParse(_previousAffs.text) ?? 0,
       previousCameras: int.tryParse(_previousCameras.text) ?? 0,
       previousCoaches: int.tryParse(_previousCoaches.text) ?? 0,
       previousFunJumps: int.tryParse(_previousFunJumps.text) ?? 0,
      );
    await  JumpLogDatabase.savePreviousSettings(log);
  }

  
//.Aqui empieza el widgetTree de esta ruta.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("SETTINGS")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          child: ListView(
            children: [
//.Campos del formulario settings              
              //SizedBox(height: 20),
              TextFormField(
                controller: _previousJumps,
                decoration: InputDecoration(
                  labelText: 'Numero de saltos previos.',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _previousFreefall,
                decoration: InputDecoration(
                  labelText: 'Caida libre previa en segundos.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousTandems,
                decoration: InputDecoration(
                  labelText: 'Saltos previos como Instructor Tandem.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousAffs,
                decoration: InputDecoration(
                  labelText: 'Saltos previos como Instructor AFFI.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousCameras,
                decoration: InputDecoration(
                  labelText: 'Saltos previos como camarografo.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousCoaches,
                decoration: InputDecoration(
                  labelText: 'Saltos previos como Coach.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousFunJumps,
                decoration: InputDecoration(
                  labelText: 'Cuantos saltos de diversion tienes?.',
                ),
                keyboardType: TextInputType.number,
              ),
//.Boton para guardar formulario              
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try { 
                    await _onSave(); //Funcion para guardar
                    //actualiza el notifier de ultimo salto y totalcaidalibre
                    lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
                    lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();
                    messenger.showSnackBar(SnackBar(content: Text('✅ Valores guardados correctamente'),),);
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text('❌ No se pudo guardar estos settings, $e')));
                  }
                },
                child: Text("Guardar"),
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
            ],
          ),
        ),
      ),
    );
  }
}
