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
  Future<List<JumpLog>>? _jumpsFuture;

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
          final endIndex = (_currentPage + 1) * _itemsPerPage;
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
                        '${jump.jumpType} en ${jump.location} el ${jump.date}',
                      ),
                      subtitle: Text(
                        '${jump.aircraft}, ${jump.altitude} FT, ${jump.equipment}, ${jump.description}, ${jump.age ?? ''} años, ${jump.weight ?? ''} kg, ${jump.signature}',
                      ),
                      onTap: () {
                        // Navegar a detalles si quieres
                      },
                      onLongPress: () async {
                        final scaffoldContext =
                            context; // GUARDAR contexto local

                        final action = await showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Acciones'),
                              content: const Text(
                                '¿Qué deseas hacer con este salto?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'editar'),
                                  child: const Text('Editar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'eliminar'),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );

                        if (action == null) return;
                        if (!mounted) return;

                        if (action == 'eliminar') {
                          await JumpLogDatabase.deleteJumpByNumber(jump.jumpNumber);
                          if (!mounted) return;

                          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                            const SnackBar(content: Text('✅ Salto eliminado')),
                          );

                          await _refreshJumps();
                        } else if (action == 'editar') {
                          if (!mounted) return;
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddJumpForm(
                                existingJump: jump,
                                onSave: (updatedJump) async {
                                  await JumpLogDatabase.updateJump(updatedJump);
                                  await _refreshJumps();
                                },
                              ),
                            ),
                          );
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
          final scaffoldContext = context; // Guardar contexto local

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddJumpForm(
                  onSave: (jump) async {
                    try {
                      if (jump.id != null) {
                        await JumpLogDatabase.updateJumpAndRecalculate(jump);
                      } else {
                        await JumpLogDatabase.insertJump(jump);
                      }
                      // 🔹 Actualizar el ValueNotifier con el último salto
                      lastJumpNumberNotifier.value =
                          await JumpLogDatabase.getLastJumpNumber();

                      // 🔹 Señalar que Home debe recargar
                      await _refreshJumps();
                    } catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
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
