//! logbook_skydiving.dart

import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart'; // aquí está JumpLog
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';

class SkydivingLogbook extends StatefulWidget {
  const SkydivingLogbook({super.key});

  @override
  State<SkydivingLogbook> createState() => SkydivingLogbookState();
}

class SkydivingLogbookState extends State<SkydivingLogbook> {
  //. Propiedades de la clase/ variables.
  late Future<List<JumpLog>> _jumpsFuture;
  final int itemsPerPage = 6;

  //.Carga Inicial
  @override
  void initState() {currentPageNotifier.value = 0;_loadJumps();super.initState();}

  //. Metodos
  Future<void> _loadJumps() async {_jumpsFuture = JumpLogDatabase.getJumps();}
  
  Future<void> refreshJumps() async {setState(() {_loadJumps();});}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _jumpsFuture,
        builder: (context, snapshot) {
          
          //Funcion para obtener errores de la obtencion de datos.
          final Center? snapshotState = snapshotStateFunction(snapshot);
          if (snapshotState != null){return snapshotState;}
          
          // En esta seccion se recibe los datos de la db y se asignan a variables de la ruta, tambien se definen variables para paginacion de la ruta.
          final jumps = snapshot.data!;
          final startIndex = currentPageNotifier.value * itemsPerPage;
          final endIndex =(currentPageNotifier.value + 1) * itemsPerPage; 
          final visibleJumps = jumps.sublist(startIndex, endIndex> jumps.length? jumps.length : endIndex);
          
          //asigna el valor del notifier despues de construir el widget para no tener error de setState en el build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            totalPagesNotifier.value = (jumps.length / itemsPerPage).ceil();
          });
          
//. Aqui empieza el widgetTree de esta ruta.
          return
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: visibleJumps.length,
                  itemBuilder: (context, index) {
                    final jump = visibleJumps[index];
                    final ListTileOfLogbook listTileOfLogbook = ListTileOfLogbook(jump);
//. ListTile de Saltos
                    return ListTile(
                      leading: listTileOfLogbook.leading(),
                      title: listTileOfLogbook.title(),
                      subtitle: listTileOfLogbook.subtitle(),
                      trailing: listTileOfLogbook.trailing(),
                      onTap: () => listTileOfLogbook.onTap(context), 
//. onLongPress.  
                      onLongPress: () async {
                        final messenger = ScaffoldMessenger.of(context,); //guarda la ruta hacia ScaffoldMessenger
                        final ctx = Navigator.of(context,); //guarda la ruta hacia Nav que maneja que pantalla se proyecta.
                        final action = await showActionDialog(context);
                        if (!mounted || action == null) return;
                        ifActionFunction(Deporte.skydiving,action,mounted,jump,messenger,ctx,refreshJumps);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
