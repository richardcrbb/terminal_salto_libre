                                                          //! logbook_basejump.dart

import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart'; // aquí está JumpLog
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';

class BasejumpLogbook extends StatefulWidget {
  const BasejumpLogbook({super.key});

  @override
  State<BasejumpLogbook> createState() => BasejumpLogbookState();
}

class BasejumpLogbookState extends State<BasejumpLogbook> {

//. Propiedades de la clase/ variables.   
  final int _itemsPerPage = 6;
  late Future<List<JumpLog>>? _jumpsFuture;

//.Carga Inicial
  @override
  void initState() {currentPageNotifier.value = 0;_loadJumps();super.initState();}

//. Metodos
  Future<void> _loadJumps() async{_jumpsFuture = JumpLogDatabase.getJumpsBase();}

  Future<void> refreshJumps() async {setState(() {_loadJumps();});}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<JumpLog>>(
        future: _jumpsFuture,
        builder: (context, snapshot) {
          
          //Funcion para obtener errores de la obtencion de datos y mostrarlo en un Center.
          final Center? snapshotState = snapshotStateFunction(snapshot);
          if (snapshotState != null){return snapshotState;}

          // En esta seccion se recibe los datos de la db y se asignan a variables de la ruta, tambien se definen variables para paginacion de la ruta.
          final jumps = snapshot.data!;
          final startIndex = currentPageNotifier.value * _itemsPerPage;
          final endIndex =(currentPageNotifier.value + 1) *_itemsPerPage; //endIndex de una sublista es exclusivo no inclusivo, quiere decir que no incluye el valor de endIndex, se detiene en el anterior a endIndex.
          final visibleJumps = jumps.sublist(startIndex,endIndex > jumps.length ? jumps.length : endIndex,);
          
          //asigna el valor del notifier despues de construir el widget para no tener error de setState en el build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            totalPagesNotifier.value = (jumps.length / _itemsPerPage).ceil();  
          },);

//.Aqui empieza el widgetTree de esta ruta.
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: visibleJumps.length,
                  itemBuilder: (context, index) {
                    final jump = visibleJumps[index];
                    final ListTileOfLogbook listTileOfLogbook = ListTileOfLogbook(jump); // instancia con metodos para ser llamados en el ListTile
//. ListTile de Saltos
                    return ListTile(
                      leading: listTileOfLogbook.leading(),
                      title: listTileOfLogbook.title(),
                      subtitle: listTileOfLogbook.subtitle(),
                      trailing: listTileOfLogbook.trailing (),
                      onTap: () => listTileOfLogbook.onTap(context), 
//. onLongPress.                                       
                      onLongPress: () async {
                        final messenger = ScaffoldMessenger.of(context,); //guarda la ruta hacia ScaffoldMessenger
                        final ctx = Navigator.of(context,); //guarda la ruta hacia Nav que maneja que pantalla se proyecta.
                        final action = await showActionDialog(context); //Funcion que muestra un dialogo y retorna un string que se asigna a la variable action, sus opciones son eliminar, editar, marcar como favorito y empezar tracking de posiones.
                        if (!mounted || action == null) return; // si se sale del dialogo sin elegir una accion se termina onLongPress.
                        ifActionFunction(Deporte.basejump ,action,mounted,jump,messenger,ctx,refreshJumps); // Funcion para evaluar que hacer dependiendo de action.
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
