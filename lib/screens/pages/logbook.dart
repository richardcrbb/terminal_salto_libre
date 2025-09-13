import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/pages/add_jump.dart';
import 'package:terminal_salto_libre/screens/pages/logbook_basejump.dart';
import 'package:terminal_salto_libre/screens/pages/logbook_skydiving.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage>with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<SkydivingLogbookState> _skydivingKey =GlobalKey<SkydivingLogbookState>();
  final GlobalKey<BasejumpLogbookState> _basejumpKey =GlobalKey<BasejumpLogbookState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //. Metodo para cambiar paginas.
  void anterior() {
    if (currentPageNotifier.value > 0) {
      setState(() {
        currentPageNotifier.value--;
      });
    }
  }

  void siguiente() {
    if (currentPageNotifier.value < totalPagesNotifier.value - 1) {
      setState(() {
        currentPageNotifier.value++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logbook"), centerTitle: true),
      body: Column(
        children: [
//. Pestañas de encabezado.          
          TabBar(
            tabs: [
              Tab(text: 'Skydiving'),
              Tab(text: 'Basejump'),
            ],
            controller: _tabController,
          ),
//. Pestañas de skydiving o basejump.          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SkydivingLogbook(key: _skydivingKey,),
                BasejumpLogbook(key: _basejumpKey),
              ],
            ),
          ),
//. Botones de paginacion.          
          ValueListenableBuilder(
            valueListenable: totalPagesNotifier,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: currentPageNotifier.value > 0 ? anterior : null,
                    child: const Text('Anterior'),
                  ), //_previousPage
                  const SizedBox(width: 20),
                  Text(
                    'Página ${currentPageNotifier.value + 1} de ${totalPagesNotifier.value}',
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed:
                        currentPageNotifier.value < totalPagesNotifier.value - 1
                        ? siguiente
                        : null,
                    child: Text('Siguiente'),
                  ), //_nextPage
                ],
              );
            }
          ),
        ],
      ),
//. Este boton presenta el formato para agregar un salto nuevo y lo guarda, actualiza los notifiers .
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 35.0),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  final messenger = ScaffoldMessenger.of(context);
                  return AddJumpForm(
                    index: _tabController.animation!.value.round(),
                    onSave: (jump) async {
                      try {
                        if(_tabController.animation!.value.round() == 0){
                            await JumpLogDatabase.insertJump(jump);
                          // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
                          lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
                          lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();
                          // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
                          await _skydivingKey.currentState?.refreshJumps();
                          }else{
                            await JumpLogDatabase.insertBaseJump(jump);
                          // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
                          lastJumpNumberBaseNotifier.value = await JumpLogDatabase.getLastJumpNumberBase();
                          lastTotalFreefallBaseNotifier.value = await JumpLogDatabase.getLastTotalFreefallBase();
                          // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
                          await _basejumpKey.currentState?.refreshJumps();
                          }
                      } catch (error) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              '❌ Ocurrió un error al guardar el salto. $error',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            );
          },
          child: const Icon(Icons.playlist_add_rounded),
        ),
      ),
    );
  }
}
