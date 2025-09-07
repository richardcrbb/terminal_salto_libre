import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';

class SettingsBasejump extends StatefulWidget {
  const SettingsBasejump({super.key});

  @override
  State<SettingsBasejump> createState() => _SettingsBasejumpState();
}

class _SettingsBasejumpState extends State<SettingsBasejump> {
  
  //. Controladores
  final TextEditingController _previousJumpsController = TextEditingController(text: '');
  final TextEditingController _previousFreefallController = TextEditingController();
  final TextEditingController _previousAsistedController = TextEditingController();
  final TextEditingController _previousBellyController = TextEditingController();
  final TextEditingController _previousTARDController = TextEditingController();
  final TextEditingController _previousFreeflyController = TextEditingController();
  final TextEditingController _previousTrackingController = TextEditingController();
  final TextEditingController _previousWingsuitController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _loadSettings();
  }

  //. Metodo para limpiar memoria cache.
  @override
  void dispose() {
    super.dispose();
    _previousJumpsController.dispose();
    _previousFreefallController.dispose();
    _previousAsistedController.dispose();
    _previousBellyController.dispose();
    _previousTARDController.dispose();
    _previousFreeflyController.dispose();
    _previousTrackingController.dispose();
    _previousWingsuitController.dispose();
  }

  //. Funcion para crear objeto initSettingsBasejumpLog y asignarlo en la carga de la ruta.  Tambien traer LandingAltitude de db
  Future<void> _loadSettings () async{
    SettingsBasejumpLog log = await JumpLogDatabase.getSettingsLogBase();
    _previousJumpsController.text = log.previousJumps.toString();
    _previousFreefallController.text = log.previousFreefall.toString();
    _previousAsistedController.text = log.previousAsisted.toString();
    _previousBellyController.text = log.previousBelly.toString();
    _previousTARDController.text = log.previousTARD.toString();
    _previousFreeflyController.text = log.previousFreefly.toString();
    _previousTrackingController.text = log.previousTracking.toString();
    _previousWingsuitController.text = log.previousWingsuit.toString();
  }

    //. Funcion para crear objeto SettingBasejumpLog para guardarlo en db

  Future<void> _onSave() async {
    final SettingsBasejumpLog log = SettingsBasejumpLog(
      previousJumps: int.tryParse(_previousJumpsController.text) ?? 0,
      previousFreefall: int.tryParse( _previousFreefallController.text) ?? 0,
      previousAsisted: int.tryParse(_previousAsistedController.text) ?? 0,
      previousBelly: int.tryParse(_previousBellyController.text) ?? 0,
      previousTARD: int.tryParse(_previousTARDController.text) ?? 0,
      previousFreefly: int.tryParse(_previousFreeflyController.text) ?? 0,
      previousTracking: int.tryParse(_previousTrackingController.text) ?? 0,
      previousWingsuit: int.tryParse(_previousWingsuitController.text) ?? 0, );
    await JumpLogDatabase.savePreviousSettingsBase(log);
  }

//.Aqui empieza el widgetTree de esta ruta.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          child: ListView(
            children: [
//.Campos del formulario settings              
              //SizedBox(height: 20),
              TextFormField(
                controller: _previousJumpsController,
                decoration: InputDecoration(
                  labelText: 'Numero de saltos BASE previos total.',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _previousFreefallController,
                decoration: InputDecoration(
                  labelText: 'Caida libre previa en segundos de saltos BASE total.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousAsistedController,
                decoration: InputDecoration(
                  labelText: 'Saltos previos asistidos.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousBellyController,
                decoration: InputDecoration(
                  labelText: 'Saltos previos en Belly.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousTARDController,
                decoration: InputDecoration(
                  labelText: 'Saltos previos T.A.R.D.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousFreeflyController,
                decoration: InputDecoration(
                  labelText: 'Saltos previos en Freefly.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousTrackingController,
                decoration: InputDecoration(
                  labelText: 'Saltos previos en tracking/tracksuit.',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _previousWingsuitController,
                decoration: InputDecoration(
                  labelText: 'Cuantos saltos en Wingsuit-Base.',
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
                    lastJumpNumberBaseNotifier.value = await JumpLogDatabase.getLastJumpNumberBase();
                    lastTotalFreefallBaseNotifier.value = await JumpLogDatabase.getLastTotalFreefallBase();
                    messenger.showSnackBar(SnackBar(content: Text('✅ Valores guardados correctamente'),),);
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text('❌ No se pudo guardar estos settings, $e')));
                  }
                },
                child: Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}