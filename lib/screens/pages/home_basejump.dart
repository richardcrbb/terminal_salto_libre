import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';
import 'package:terminal_salto_libre/data/models.dart';

class HomeBasejump extends StatefulWidget {
  final List<JumpLog> jumpsBase;
  final List<JumpLog> favListBase;
  final Map<String,int> countsBase;
  const HomeBasejump({super.key, required this.jumpsBase,required this.favListBase, required this.countsBase,});

  @override
  State<HomeBasejump> createState() => _HomeBasejumpState();
}

class _HomeBasejumpState extends State<HomeBasejump> {
  @override
  Widget build(BuildContext context) {
    //.Aqui empieza el widgetTree de esta ruta.
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 18,),
              Text('Número de saltos en B.A.S.E.: ${lastJumpNumberBaseNotifier.value}'),
              Text(
                "Total de caída en B.A.S.E.: ${formatSecondsToHHMMSS(lastTotalFreefallBaseNotifier.value)}",
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
                    SizedBox(width: 100, child: Text('Saltos del día de saltos ')),
                    CircleAvatar(child: Text('${widget.jumpsBase.length}')),
                  ],
                ),
              ),
//. Esta caja muestra la lista de los saltos del ultimo dia
              SizedBox(
                height: 300,
                child: widget.jumpsBase.isEmpty
                    ? const Center(
                        child: Text('No hay saltos para mostrar.'),
                      )
                    : ListView.builder(
                        itemCount: widget.jumpsBase.length,
                        itemBuilder: (context, index) {
                          final jump = widget.jumpsBase[index];
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
                  itemCount: widget.countsBase.length,
                  itemBuilder: (context, index) {
                    // Convertimos el Map a una lista de entradas (entries)
                    final entry = widget.countsBase.entries.elementAt(index);
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
                child: widget.favListBase.isEmpty? Text('No hay saltos Favoritos')
                  :ListView.builder(itemCount: widget.favListBase.length,itemBuilder: (context, index) {
                  final fJump = widget.favListBase[index];
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