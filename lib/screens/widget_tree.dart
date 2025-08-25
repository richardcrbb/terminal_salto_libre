import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:terminal_salto_libre/screens/pages/altimeter.dart';
import 'package:terminal_salto_libre/screens/pages/settings.dart';
import 'package:terminal_salto_libre/screens/pages/glidepath.dart';
import 'package:terminal_salto_libre/screens/pages/home.dart';
import 'package:terminal_salto_libre/screens/pages/logbook.dart';

List<Widget> pages = [
  HomePage(),
  AltimeterPage(),
  LogbookPage(),
  GlidePathPage(),
  SettingsPage(),
];


class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: indexSelected,
      builder: (context, valorcillo, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Terminal Salto Libre'),
            centerTitle: true,
            actions: [
              ValueListenableBuilder(
                valueListenable: darkMode,
                builder: (context, valemia, child) {
                  return IconButton(
                    onPressed: () {
                      valemia ? darkMode.value = false : darkMode.value = true;
                    },
                    icon: valemia
                        ? Icon(Icons.light_mode_outlined)
                        : Icon(Icons.dark_mode_outlined),
                  );
                },
              ),
              IconButton(onPressed: () {
                
              }, icon: Icon(Icons.cloud_upload_outlined))
            ],
          ),
          body: Center(child: pages[valorcillo]),
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.schedule),
                label: 'Altimeter',
              ),
              NavigationDestination(icon: Icon(Icons.book), label: 'Logbook'),
              NavigationDestination(
                icon: Icon(Icons.paragliding),
                label: 'GlidePath',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_applications_rounded),
                label: 'Settings',
              ),
            ],
            onDestinationSelected: (cliked) {
              indexSelected.value = cliked;
            },
            selectedIndex: valorcillo,
          ),
        );
      },
    );
  }
}
