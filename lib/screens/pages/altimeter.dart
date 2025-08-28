import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'package:units_converter/units_converter.dart';

class AltimeterPage extends StatefulWidget {
  const AltimeterPage({super.key});

  @override
  State<AltimeterPage> createState() => _AltimeterPageState();
}

class _AltimeterPageState extends State<AltimeterPage> {
  final LocationSettings settings = LocationSettings(accuracy: LocationAccuracy.bestForNavigation,);
  double posicion = 0;


  Future getLocation() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: settings,
    );
    setState(() {
       posicion= position.altitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            IconButton(
              onPressed:
                getLocation,icon: Icon(Icons.perm_data_setting_rounded),
            ),
            Text(isImperialSystemNotifier.value? "no lo se en pies": "$posicion metros"  )
          ],
        ),
      ),
    );
  }
}
