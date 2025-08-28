import 'package:flutter/material.dart';

//Notifiers de index de pagina y modo oscuro
ValueNotifier<int> indexSelected = ValueNotifier(0);
ValueNotifier<bool> darkMode = ValueNotifier(true);

//Info del ultimo salto
ValueNotifier<int> lastJumpNumberNotifier = ValueNotifier(0);
ValueNotifier<int> lastTotalFreefallNotifier = ValueNotifier(0);

//Notifier de sistema de unidades.
ValueNotifier<bool> isImperialSystemNotifier =ValueNotifier(true);