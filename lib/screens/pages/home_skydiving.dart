import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';

class HomeSkydiving extends StatefulWidget {
  final List<JumpLog> jumps;
  final List<JumpLog> favList;
  final Map<String,int> counts;
  final List<JumpLog> sobrecuposDelDia;
  const HomeSkydiving({super.key, required this.jumps,required this.favList, required this.counts,required this.sobrecuposDelDia,});

  @override
  State<HomeSkydiving> createState() => _HomeSkydivingState();
}

class _HomeSkydivingState extends State<HomeSkydiving> {
  @override
  Widget build(BuildContext context) {
     //.Aqui empieza el widgetTree de esta ruta.
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 18,),
              Text('Número de saltos en Skydiving: ${lastJumpNumberNotifier.value}'),
              Text(
                "Total de caída libre en Skydiving: ${formatSecondsToHHMMSS(lastTotalFreefallNotifier.value)}",
              ),
              const SizedBox(height: 10),
              Text('Resumen del último día', style: titulo),
              const SizedBox(height: 10),
//.Esta caja muestra total de saltos del ultimo dia
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 100, child: Text('Saltos del día ')),
                    CircleAvatar(child: Text('${widget.jumps.length}')),
                  ],
                ),
              ),
//. Esta caja muestra los sobrecupos
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 100, child: Text('Sobrecupos ')),
                    CircleAvatar(child: Text('${widget.sobrecuposDelDia.length}')),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
//. Esta caja muestra la lista de los saltos del ultimo dia
              SizedBox(
                height: 300,
                child: widget.jumps.isEmpty
                    ? const Center(
                        child: Text('No hay saltos para mostrar.'),
                      )
                    : ListView.builder(
                        itemCount: widget.jumps.length,
                        itemBuilder: (context, index) {
                          final jump = widget.jumps[index];
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
              Text('RESUMEN DE CARRERA',style: titulo),
              const SizedBox(height: 10),
//. Esta caja muestra la un resumen por categorias de mis saltos totalizado.
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: widget.counts.length,
                  itemBuilder: (context, index) {
                    // Convertimos el Map a una lista de entradas (entries)
                    final entry = widget.counts.entries.elementAt(index);
                    final tipo = entry.key;
                    final cantidad = entry.value;
          
                    return ListTile(
                      leading: Text('#${index+1}'),
                      title: Text(tipo), // clave del mapa
                      trailing: CircleAvatar(
                        child: Text(cantidad.toString()),
                      ), // valor del mapa
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text('FAVORITOS',style: titulo),
              const SizedBox(height: 10),
//. Esta caja muestra lista de favoritos.
              SizedBox(
                height: 200,
                child: widget.favList.isEmpty? Text('No hay saltos Favoritos')
                  :ListView.builder(itemCount: widget.favList.length,itemBuilder: (context, index) {
                  final fJump = widget.favList[index];
                  return ListTile(
                    leading: Text('#${index+1}'),
                    title: Text('Salto # ${fJump.jumpNumber}'),
                    subtitle: Text(fJump.description),
                    trailing: Text(formatearFecha(fJump.date)),
                  );
                },),
              ),
            ],
          ),
        );
  }
}