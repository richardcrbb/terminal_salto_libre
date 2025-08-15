import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    lastJumpNumberNotifier.value = await JumpLogDatabase.getLastJumpNumber();
    lastTotalFreefallNotifier.value = await JumpLogDatabase.getLastTotalFreefall();

    final jumps = await JumpLogDatabase.getJumpsWithLastDate();
    final counts = await JumpLogDatabase.getJumpTypeCounts();

    return {'jumps': jumps, 'counts': counts};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return  Center(child: Text('Error al cargar los datos ${snapshot.error}'));
        }

        final data = snapshot.data!;
        final jumps = data['jumps'] as List<JumpLog>;
        final sobrecuposDelDia = jumps
            .where((jump) => (jump.weight ?? 0) > 85)
            .toList();
        final counts = data['counts'] as Map<String, int>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Número de saltos: ${lastJumpNumberNotifier.value}'),
            Text(
              "Total de caída libre: ${formatSecondsToHHMMSS(lastTotalFreefallNotifier.value)}",
            ),
            const SizedBox(height: 10),
            Text('Resumen del último día', style: titulo),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 100, child: Text('Saltos del día ')),
                  CircleAvatar(child: Text('${jumps.length}')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 100, child: Text('Sobrecupos ')),
                  CircleAvatar(child: Text('${sobrecuposDelDia.length}')),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: jumps.isEmpty
                  ? const Center(
                      child: Text('No hay saltos en la última fecha'),
                    )
                  : ListView.builder(
                      itemCount: jumps.length,
                      itemBuilder: (context, index) {
                        final jump = jumps[index];
                        return ListTile(
                          leading: Text('#${index + 1}'),
                          title: Text(jump.location),
                          subtitle: Text(
                            '${jump.weight} kg - ${jump.age} años - con ${jump.signature}',
                          ),
                          trailing: Text(formatearFecha(jump.date)),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: counts.length,
                itemBuilder: (context, index) {
                  // Convertimos el Map a una lista de entradas
                  final entry = counts.entries.elementAt(index);
                  final tipo = entry.key;
                  final cantidad = entry.value;

                  return ListTile(
                    leading: Text(tipo), // clave del mapa
                    trailing: CircleAvatar(
                      child: Text(cantidad.toString()),
                    ), // valor del mapa
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
