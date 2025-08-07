import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/screens/pages/add_jump.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Logbook"), centerTitle: true),
      body: FutureBuilder(
        future: JumpLogDatabase.getJumps(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot
                  .data!
                  .isEmpty) /* no has data true significa que es nulo */ {
            return const Center(child: Text('No hay saltos registrados.'));
          }

          final jumps = snapshot.data!;
          final totalPages = (jumps.length / _itemsPerPage).ceil(); //.ceil() redondea hacia arriba, para no perder registros en la última página. 50/20 = 2.5 ~ 3 paginas

          // Calcular los índices para los elementos visibles
          final startIndex = _currentPage * _itemsPerPage; //Si estás en la página 0: startIndex = 0 * 20 = 0, Si estás en la página 2:startIndex = 2 * 20 = 40
          final endIndex = (_currentPage + 1) * _itemsPerPage; //Si estás en la página 0: endIndex = (0 + 1) * 20 = 20 Si estás en la página 2: endIndex = (2 + 1) * 20 = 60
          final visibleJumps = jumps.sublist( // hace un listado de a 20 items.
            startIndex,
            endIndex > jumps.length ? jumps.length : endIndex, // asegura que el ultimo listado sea el restante de items, porque si se pone fijo que 20 y solo quedan 15 lanzaria un error ya que no existen.
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
                        '${jump.jumpType} en ${jump.location} el ${jump.date} ',
                      ),
                      subtitle: Text(
                        '${jump.aircraft}, ${jump.altitude} FT, ${jump.equipment}, ${jump.description}',
                      ),
                      onTap: () {
                        // Puedes navegar a una pantalla de detalle o edición si deseas
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddJumpForm(
                  onSave: (jump) async {
                    try {
                      await JumpLogDatabase.insertJump(jump);
                      setState(() {});
                      // Aquí puedes guardar en base de datos, actualizar estado, etc.
                      //print("Salto guardado: ${jump.jumpNumber}");
                    } catch (error) {
                      // Imprimir el error en consola
                      debugPrint("Error al guardar el salto: $error");

                      // Mostrar SnackBar con mensaje de error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Ocurrió un error al guardar el salto. $error',
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
        child: Icon(Icons.playlist_add_rounded),
      ),
    );
  }
}
