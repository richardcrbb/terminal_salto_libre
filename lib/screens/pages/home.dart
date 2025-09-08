import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/pages/home_basejump.dart';
import 'package:terminal_salto_libre/screens/pages/home_skydiving.dart';

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
    lastJumpNumberBaseNotifier.value = await JumpLogDatabase.getLastJumpNumberBase();
    lastTotalFreefallBaseNotifier.value = await JumpLogDatabase.getLastTotalFreefallBase();
    
    //Necesito cargar este notifier para mostrar las unidades correctas.
    isImperialSystemNotifier.value =  await JumpLogDatabase.isImperialSystem() == 1; // con solo comprar[==] el resultado devuelve automaticamente true o false, no se necestia evaluar el restulado con un operador ternario [?]

    final jumps = await JumpLogDatabase.getJumpsWithLastDate();
    final counts = await JumpLogDatabase.getJumpTypeCounts();
    final favList = await JumpLogDatabase.favList();
    final jumpsBase = await JumpLogDatabase.getJumpsWithLastDateBase();
    final countsBase = await JumpLogDatabase.getJumpTypeCountsBase();
    final favListBase = await JumpLogDatabase.favListBase();

    return {'jumps': jumps, 'counts': counts, 'favList':favList, 'jumpsBase': jumpsBase, 'countsBase': countsBase, 'favListBase':favListBase,};
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
        final favList= data['favList'] as List<JumpLog>;
        final counts = data['counts'] as Map<String, int>;
        final jumpsBase = data['jumpsBase'] as List<JumpLog>;
        final favListBase= data['favListBase'] as List<JumpLog>;
        final countsBase = data['countsBase'] as Map<String, int>;
        final sobrecuposDelDia = jumps
            .where((jump) => (jump.weight ?? 0) > 85)
            .toList();
        
        return DefaultTabController(length: 2, child: Scaffold(
          body: Column(children: [
            TabBar(unselectedLabelColor: Colors.grey,tabs: [Tab(text: "Skydiving",),Tab(text: "Basejump",)]),
            Expanded(
              child: TabBarView(children: [
                HomeSkydiving(jumps: jumps, favList: favList, counts: counts,sobrecuposDelDia: sobrecuposDelDia,),
                HomeBasejump(jumpsBase: jumpsBase, favListBase: favListBase, countsBase: countsBase,),
                ]),
            ),
            ]
          ),
        ));

      },
    );
  }
}
