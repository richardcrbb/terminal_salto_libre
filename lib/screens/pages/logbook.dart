import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/screens/pages/logbook_basejump.dart';
import 'package:terminal_salto_libre/screens/pages/logbook_skydiving.dart';

class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2, child: Scaffold(
      body: Column(children: [TabBar(tabs:[Tab(text: 'Skydiving',),Tab(text: 'Basejump',)]),Expanded(child: TabBarView(children: [SkydivingLogbook(),BasejumpLogbook()]))]),
    ));
  }
} 