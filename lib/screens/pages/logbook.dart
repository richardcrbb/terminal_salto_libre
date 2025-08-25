import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart'; // aquí está JumpLog
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/pages/add_jump.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  int _currentPage = 0;
  final int _itemsPerPage = 20;
  late Future<List<JumpLog>>? _jumpsFuture;

  @override
  void initState() {
    super.initState();
    _loadJumps();
  }

  void _loadJumps() {
    _jumpsFuture = JumpLogDatabase.getJumps();
  }

  Future<void> _refreshJumps() async {
    _loadJumps();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logbook"), centerTitle: true),
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

          final jumps = snapshot.data!;
          final totalPages = (jumps.length / _itemsPerPage).ceil();

          final startIndex = _currentPage * _itemsPerPage;
          final endIndex =
              (_currentPage + 1) *
              _itemsPerPage; //endIndex de una sublista es exclusivo no inclusivo, quiere decir que no incluye el valor de endIndex, se detiene en el anterior a endIndex.
          final visibleJumps = jumps.sublist(
            startIndex,
            endIndex > jumps.length ? jumps.length : endIndex,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: visibleJumps.length,
                  itemBuilder: (context, index) {
                    final jump = visibleJumps[index];
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
                              ],
                            );
                          },
                        );
                        if (!mounted || action == null) return;

                        if (action == 'Eliminar') {
                          try{
                            await JumpLogDatabase.deleteJumpByNumber(jump.jumpNumber,);
                            lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
                            lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();
                          if (!mounted) return;
                          messenger.showSnackBar(const SnackBar(content: Text('✅ Salto eliminado')),);
                          await _refreshJumps();
                          } catch(error){
                            if (!mounted) return;
                            messenger.showSnackBar(SnackBar(content: Text('❌ No se puedo eliminar el salto: $error')),);
                          }
                        } else if (action == 'Editar') {
                          if (!mounted) return;
                          try{
                            await ctx.push(
                            MaterialPageRoute(
                              builder: (_) => AddJumpForm(
                                existingJump: jump,
                                onSave: (updatedJump) async {
                                  await JumpLogDatabase.updateJumpAndRecalculate(updatedJump,);
                                  lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
                                  lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();
                                  messenger.showSnackBar(const SnackBar(content: Text('✅ Salto editado')),);
                                  await _refreshJumps();
                                },
                              ),
                            ),
                          );
                          }catch(error){if (!mounted) return;
                                        messenger.showSnackBar(SnackBar(content: Text('❌ No se puedo editar el salto: $error')),);
                                        }
                        } else if (action == 'Favoritos'){
                          try{await JumpLogDatabase.favorite(jump.id);
                              messenger.showSnackBar(const SnackBar(content: Text('✅ Salto Favorito')),);
                              await _refreshJumps();
                              }catch(error){messenger.showSnackBar(SnackBar(content: Text('❌ No se puedo marcar como favorito el salto: $error')),);}
                        }
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                _currentPage--;
                              });
                            }
                          : null,
                      child: const Text('Anterior'),
                    ),
                    const SizedBox(width: 20),
                    Text('Página ${_currentPage + 1} de $totalPages'),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _currentPage < totalPages - 1
                          ? () {
                              setState(() {
                                _currentPage++;
                              });
                            }
                          : null,
                      child: const Text('Siguiente'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                final messenger = ScaffoldMessenger.of(context);
                return AddJumpForm(
                  onSave: (jump) async {
                    try {
                      await JumpLogDatabase.insertJump(jump);
                      // 🔹 Actualizar el ValueNotifier con el último salto
                      lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
                      lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();
                      // 🔹 Señalar que Home debe recargar
                      await _refreshJumps();
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
    );
  }
}
