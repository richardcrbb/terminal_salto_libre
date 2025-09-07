import 'package:flutter/material.dart';

//Notifiers de index de pagina y modo oscuro
ValueNotifier<int> indexSelected = ValueNotifier(0);
ValueNotifier<bool> darkMode = ValueNotifier(true);

//Notifiers de paginacion ruta logbook
ValueNotifier<int> currentPageNotifier = ValueNotifier(0);
ValueNotifier<int> totalPagesNotifier = ValueNotifier(0);

//Info del ultimo salto en skydiving
ValueNotifier<int> lastJumpNumberNotifier = ValueNotifier(0);
ValueNotifier<int> lastTotalFreefallNotifier = ValueNotifier(0);

//Info del ultimo salto en basejump
ValueNotifier<int> lastJumpNumberBaseNotifier = ValueNotifier(0);
ValueNotifier<int> lastTotalFreefallBaseNotifier = ValueNotifier(0);

//Notifier de sistema de unidades.
ValueNotifier<bool> isImperialSystemNotifier =ValueNotifier(true);

//Registro de posicion y tiempo
ValueNotifier<bool> isTracking =ValueNotifier(false);