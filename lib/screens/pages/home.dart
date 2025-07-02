import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    FutureBuilder<int>(
      future: JumpLogDatabase.getLastJumpNumber(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error al cargar los saltos');
        } else {
          final lastJumpNumber = snapshot.data ?? 0;
        return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Numero de Saltos $lastJumpNumber'),
      ],
    );
  }},);}}