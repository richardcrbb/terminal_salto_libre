import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/pages/add_jump.dart';
import 'package:terminal_salto_libre/screens/pages/altimeter.dart';

String formatSecondsToHHMMSS(int seconds) {
  final hours =
      seconds ~/
      3600; //divide entre 3600 y trunca el resultado hacia 0 para tener horas en entero.
  final minutes =
      (seconds % 3600) ~/
      60; //saca el residuo o remainder de la division de horas y las didive entre sesenta truncado hacia cero para tener minutos en entero.
  final secs =
      seconds %
      60; // usa el residuo o reimainder de la division para sacar minutos y serian los sobrantes segundos.

  final hh = hours.toString().padLeft(2, '0');
  final mm = minutes.toString().padLeft(2, '0');
  final ss = secs.toString().padLeft(2, '0');

  return "$hh:$mm:$ss";
}

//$ Esta caja saca una pantalla nueva con tres opciones {EDITAR, ELIMINAR, FAVORITOS, Iniciar tracking y Detener tracking}.
Future<String?> showActionDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Acciones'),
        content: const Text('¿Qué deseas hacer con este salto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'Editar'),
            child: const Text('Editar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'Eliminar'),
            child: const Text('Eliminar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'Favoritos'),
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
}


//$     Funcion que decide que hacer dependiendo del resultado de actions y si es llamado desde skydiving logbook o basejump logbook.                      

void ifActionFunction(
  Deporte deporte,
  String action,
  bool mounted,
  JumpLog jump,
  ScaffoldMessengerState messenger,
  NavigatorState ctx,
  Function refreshJumps,
) async {
  //@ Eliminar
  // En esta seccion se intenta ELIMINAR un basejump
    if (action == 'Eliminar' && deporte == Deporte.basejump) {
      try {
        await JumpLogDatabase.deleteJumpByNumberInBasejumptable(jump.jumpNumber);
        // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
        lastJumpNumberBaseNotifier.value =
            await JumpLogDatabase.getLastJumpNumberBase();
        lastTotalFreefallBaseNotifier.value =
            await JumpLogDatabase.getLastTotalFreefallBase();
        // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
        await refreshJumps();
        messenger.showSnackBar(
          const SnackBar(content: Text('✅ Salto eliminado')),
        );
      } catch (error) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('❌ No se puedo eliminar el salto: $error')),
        );
      }
    }
  //. Eliminar
  // En esta seccion se intenta ELIMINAR un skydive
      if (action == 'Eliminar' && deporte ==Deporte.skydiving) {
        try {
          await JumpLogDatabase.deleteJumpByNumber(
            jump.jumpNumber,
          );
          // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
          lastJumpNumberNotifier.value =
              await JumpLogDatabase.getLastJumpNumber();
          lastTotalFreefallNotifier.value =
              await JumpLogDatabase.getLastTotalFreefall();
          // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
          await refreshJumps();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('✅ Salto eliminado'),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '❌ No se puedo eliminar el salto: $error',
              ),
            ),
          );
        }
      }
  //@ Editar
  // En esta seccion se intenta EDITAR un basejump
    else if (action == 'Editar' && deporte == Deporte.basejump) {
      if (!mounted) return;
      try {
        await ctx.push(
          MaterialPageRoute(
            builder: (_) => AddJumpForm(
              index: 1, //hardcoded index para basejump
              //aqui se envia el objeto JumpLog y un callback de edicion. [push data]
              existingJump: jump,
              onSave: (updatedJump) async {
                await JumpLogDatabase.updateJumpAndRecalculateBaseJump(
                  updatedJump,
                );
                // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
                lastJumpNumberBaseNotifier.value =
                    await JumpLogDatabase.getLastJumpNumberBase();
                lastTotalFreefallBaseNotifier.value =
                    await JumpLogDatabase.getLastTotalFreefallBase();
                // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
                await refreshJumps();
                messenger.showSnackBar(
                  const SnackBar(content: Text('✅ Salto editado')),
                );
              },
            ),
          ),
        );
      } catch (error) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(content: Text('❌ No se puedo editar el salto: $error')),
        );
      }
    }
  //. Editar
  // En esta seccion se intenta EDITAR un skydive
      else if (action == 'Editar' && deporte == Deporte.skydiving) {
        if (!mounted) return;
        try {
          await ctx.push(
            MaterialPageRoute(
              builder: (_) => AddJumpForm(
                index: 0, //hardcoded index para skydiving
                //aqui se envia el objeto JumpLog y un callback de edicion. [push data]
                existingJump: jump,
                onSave: (updatedJump) async {
                  await JumpLogDatabase.updateJumpAndRecalculate(
                    updatedJump,
                  );
                  // Actualizar el ValueNotifier con el último salto y el notifier de acomulado de caida libre
                  lastJumpNumberNotifier.value =
                      await JumpLogDatabase.getLastJumpNumber();
                  lastTotalFreefallNotifier.value =
                      await JumpLogDatabase.getLastTotalFreefall();
                  // Señala que esta ruta logbook debe reconstruirse con los datos actuales de la db.
                  await refreshJumps();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('✅ Salto editado'),
                    ),
                  );
                },
              ),
            ),
          );
        } catch (error) {
          if (!mounted) return;
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '❌ No se puedo editar el salto: $error',
              ),
            ),
          );
        }
      }
  //@ Favorito
  // En esta seccion se intenta marcar como Favorito en basejump
    else if (action == 'Favoritos'&& deporte == Deporte.basejump) {
      try {
        await JumpLogDatabase.favoriteBase(jump.id);
        messenger.showSnackBar(const SnackBar(content: Text('✅ Salto Favorito')));
        await refreshJumps();
      } catch (error) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('❌ No se puedo marcar como favorito el salto: $error'),
          ),
        );
      }
    }
  //. Favorito
  // En esta seccion se intenta marcar como Favorito un Skydive
      else if (action == 'Favoritos' && deporte == Deporte.skydiving) {
        try {
          await JumpLogDatabase.favorite(jump.id);
          messenger.showSnackBar(
            const SnackBar(content: Text('✅ Salto Favorito')),
          );
          await refreshJumps();
        } catch (error) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '❌ No se puedo marcar como favorito el salto: $error',
              ),
            ),
          );
        }
      }
  //@ Tracking
  // En esta seccion se empieza a guardar el registro de posicion altitud y tiempo del salto en un basejump.
    else if (action == 'StartTracking' && deporte == Deporte.basejump) {
      final List<Map<String, dynamic>> puntos =
          await JumpLogDatabase.getPointsOfJump(jump.id!);
      if (puntos.isEmpty) {
        try {
          // Aquí pasas el jump.id a AltimeterPage
          ctx.push(
            MaterialPageRoute(
              builder: (_) {
                isTracking.value = true;
                return AltimeterPage(jumpId: jump.id);
              },
            ),
          );
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text('$e')));
        }
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '❌ este salto ya cuenta con puntos de posicion registrados.',
            ),
          ),
        );
      }
    }
  //. Tracking
  // En esta seccion se empieza a guardar el registro de posicion altitud y tiempo del salto en un skydive.
      else if (action == 'StartTracking' && deporte ==Deporte.skydiving) {
        final List<Map<String, dynamic>> puntos =
            await JumpLogDatabase.getPointsOfJump(jump.id!);
        if (puntos.isEmpty) {
          try {
            // Aquí pasas el jump.id a AltimeterPage
            ctx.push(
              MaterialPageRoute(
                builder: (_) {
                  isTracking.value = true;
                  return AltimeterPage(jumpId: jump.id);
                },
              ),
            );
          } catch (e) {
            messenger.showSnackBar(
              SnackBar(content: Text('$e')),
            );
          }
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '❌ este salto ya cuenta con puntos de posicion registrados.',
              ),
            ),
          );
        }
      }
  }

//$ Snapshot State Function

Center? snapshotStateFunction (AsyncSnapshot snapshot){
  if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
  } else if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('No hay saltos registrados.'));
  }
  return null;
}