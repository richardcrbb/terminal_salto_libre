import 'package:flutter/material.dart';

ValueNotifier<int> indexSelected = ValueNotifier(0);
ValueNotifier<bool> darkMode = ValueNotifier(true);

//Info del ultimo salto
ValueNotifier<int> lastJumpNumberNotifier = ValueNotifier(0);
ValueNotifier<int> lastTotalFreefallNotifier = ValueNotifier(0);