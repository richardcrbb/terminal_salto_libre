import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _saltosPrevios = TextEditingController(text: '0');
  final TextEditingController _caidaLibrePrevia = TextEditingController(
    text: '0',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("SETTINGS")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          child: ListView(
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: _saltosPrevios,
                decoration: InputDecoration(
                  labelText: 'Numero de saltos previos.',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _caidaLibrePrevia,
                decoration: InputDecoration(
                  labelText: 'Caida libre previa en segundos.',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final saltos = int.tryParse(_saltosPrevios.text) ?? 0;
                    final caida = int.tryParse(_caidaLibrePrevia.text) ?? 0;

                    //graba estos saltos y caida libre en tabla 'settings'
                    await JumpLogDatabase.savePreviousSettings(saltos, caida);
                    //actualiza el notifier de ultimo salto y totalcaidalibre
                    lastJumpNumberNotifier.value =
                        await JumpLogDatabase.getLastJumpNumber();
                    lastTotalFreefallNotifier.value =
                        await JumpLogDatabase.getLastTotalFreefall();

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('✅ Valores guardados correctamente'),
                      ),
                    );

                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
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
