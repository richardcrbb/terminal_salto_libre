                                                          //! logbook_basejump.dart

import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart'; // aquí está JumpLog
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/pages/add_jump.dart';
import 'package:terminal_salto_libre/screens/pages/altimeter.dart';

class BasejumpLogbook extends StatefulWidget {
  const BasejumpLogbook({super.key});

  @override
  State<BasejumpLogbook> createState() => BasejumpLogbookState();
}

class BasejumpLogbookState extends State<BasejumpLogbook> {

//. Propiedades de la clase/ variables.   
  //int currentPage = 0;
  //int totalPages = 0;
  final int _itemsPerPage = 6;
  late Future<List<JumpLog>>? _jumpsFuture;

//.Carga Inicial
  @override
  void initState() {
    currentPageNotifier.value = 0;
    _loadJumps();
    super.initState();
  }

//. Metodo para cargar datos de db.
  Future<void> _loadJumps() async{_jumpsFuture = JumpLogDatabase.getJumpsBase();}

//. Metodo para recargar datos y UI de esta ruta.
  Future<void> _refreshJumps() async {
    _loadJumps();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<JumpLog>>(
        future: _jumpsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay saltos registrados.'));
          }
//. En esta seccion se recibe los datos de la db y se asignan a variables de la ruta, tambien se definen variables para paginacion de la ruta.
          final jumps = snapshot.data!;
          
          //asigna el valor del notifier despues de construir el widget para no tener error de setState en el build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            totalPagesNotifier.value = (jumps.length / _itemsPerPage).ceil();  
          },);

          final startIndex = currentPageNotifier.value * _itemsPerPage;
          final endIndex =(currentPageNotifier.value + 1) *_itemsPerPage; //endIndex de una sublista es exclusivo no inclusivo, quiere decir que no incluye el valor de endIndex, se detiene en el anterior a endIndex.
          final visibleJumps = jumps.sublist(startIndex,endIndex > jumps.length ? jumps.length : endIndex,);
//.Aqui empieza el widgetTree de esta ruta.
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: visibleJumps.length,
                  itemBuilder: (context, index) {
                    final jump = visibleJumps[index];
//. Esta caja muestra el listado de saltos divididos en paginas de 20 Items, se define funcion onLongPress para editar,eliminar o marcar como favorito.                    
                    return ListTile(
                      leading: CircleAvatar(child: Text('${jump.jumpNumber}')),
                      title: Text(
                        '${jump.jumpType} en ${jump.location} el ${formatearFecha(jump.date)}',
                      ),
                      subtitle: Text(
                        '${jump.aircraft}, ${jump.altitude} FT, ${jump.equipment}, ${jump.description}, ${jump.age ?? ''} años, ${jump.weight ?? ''} kg, ${jump.signature}',),
                      trailing: jump.favorites == 0 ? Icon(Icons.star_outline_sharp): Icon(Icons.stars_rounded),
                      onLongPress: () async {
                        final messenger = ScaffoldMessenger.of(context,); //guarda la ruta hacia ScaffoldMessenger
                        final ctx = Navigator.of(context,); //guarda la ruta hacia Nav que maneja que pantalla se proyecta.
                        final action = await showDialog<String>(
                          context: context,
                          builder: (BuildContext dialogContext) {
//. Esta caja saca una pantalla nueva con tres opciones {EDITAR, ELIMINAR, FAVORITOS, Iniciar tracking y Detener tracking}.
                            return AlertDialog(
                              title: const Text('Acciones'),
                              content: const Text(
                                '¿Qué deseas hacer con este salto?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, 'Editar'),
                                  child: const Text('Editar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, 'Eliminar'),
                                  child: const Text('Eliminar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(dialogContext, 'Favoritos'),
                                  child: const Text('Favoritos'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext, 'StartTracking'),
                                  child: const Text('Iniciar Tracking'),
                                ),
                              ],
                            );
                          },
                        );
                        if (!mounted || action == null) return;
//. En esta seccion se intenta ELIMINAR
                        if (action == 'Eliminar') {
                          try{
                            await JumpLogDatabase.deleteJumpByNumber(jump.jumpNumber,);
                            // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
                            lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
                            lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();
                            // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
                            await _refreshJumps();
                            messenger.showSnackBar(const SnackBar(content: Text('✅ Salto eliminado')),);
                            } catch(error){
                              if (!mounted) return;
                              messenger.showSnackBar(SnackBar(content: Text('❌ No se puedo eliminar el salto: $error')),);}
                        } 
//. En esta seccion se intenta EDITAR
                        else if (action == 'Editar') {
                          if (!mounted) return;
                          try{
                            await ctx.push(
                            MaterialPageRoute(
                              builder: (_) => AddJumpForm(
                                index: 1, //hardcoded index para skydiving
                                //aqui se envia el objeto JumpLog y un callback de edicion. [push data]
                                existingJump: jump,
                                onSave: (updatedJump) async {
                                  await JumpLogDatabase.updateJumpAndRecalculate(updatedJump,);
                                  // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
                                  lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
                                  lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();
                                  // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
                                  await _refreshJumps();
                                  messenger.showSnackBar(const SnackBar(content: Text('✅ Salto editado')),);
                                },
                              ),
                            ),
                          );
                          }catch(error){if (!mounted) return;
                                        messenger.showSnackBar(SnackBar(content: Text('❌ No se puedo editar el salto: $error')),);}
                        } 
//. En esta seccion se intenta marcar como Favorito
                        else if (action == 'Favoritos'){
                          try{await JumpLogDatabase.favorite(jump.id);
                              messenger.showSnackBar(const SnackBar(content: Text('✅ Salto Favorito')),);
                              await _refreshJumps();
                              }catch(error){messenger.showSnackBar(SnackBar(content: Text('❌ No se puedo marcar como favorito el salto: $error')),);}
                        }
//. En esta seccion se empieza a guardar el registro de posicion altitud y tiempo del salto.
                        else if (action == 'StartTracking') {
                          final List<Map<String,dynamic>> puntos = await JumpLogDatabase.getPointsOfJump(jump.id!);
                          if (puntos.isEmpty){
                            try{
                              // Aquí pasas el jump.id a AltimeterPage
                            ctx.push(
                              MaterialPageRoute(
                                builder: (_) {
                                  isTracking.value = true;
                                  return AltimeterPage(jumpId: jump.id,);},
                              ),
                            );
                            }catch(e){messenger.showSnackBar(SnackBar(content: Text('$e'),),);}
                          } else {messenger.showSnackBar(SnackBar(content: Text('❌ este salto ya cuenta con puntos de posicion registrados.'),),);}
                        }
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
