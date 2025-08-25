String formatSecondsToHHMMSS(int seconds) {
  final hours = seconds ~/ 3600; //divide entre 3600 y trunca el resultado hacia 0 para tener horas en entero.
  final minutes = (seconds % 3600) ~/ 60; //saca el residuo o remainder de la division de horas y las didive entre sesenta truncado hacia cero para tener minutos en entero.
  final secs = seconds % 60; // usa el residuo o reimainder de la division para sacar minutos y serian los sobrantes segundos.

  final hh = hours.toString().padLeft(2, '0');
  final mm = minutes.toString().padLeft(2, '0');
  final ss = secs.toString().padLeft(2, '0');

  return "$hh:$mm:$ss";
}