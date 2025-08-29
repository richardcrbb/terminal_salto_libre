import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'dart:async';

class AltimeterPage extends StatefulWidget {
  const AltimeterPage({super.key});

  @override
  State<AltimeterPage> createState() => _AltimeterPageState();
}

class _AltimeterPageState extends State<AltimeterPage> {
  
  final LocationSettings settings = LocationSettings(accuracy: LocationAccuracy.bestForNavigation,);
  double posicion = 0;
  int _updateCount = 0;
  int _segundos = 0;
  Timer? _timer;
  StreamSubscription<Position>? _positionStream;
  late int dzaltitude;
  

  //. Metodo para cargar datos.
  @override
  initState(){
    super.initState();
    _checkPermissions();
    _obtenerDzAltitude();
  }

  //. Metodo para limpiar cache.
  @override
  dispose(){
    _timer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  //. Funcion para obtener permisos
  Future<void> _checkPermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
  }
  _getLocation();
  }

  //. Funcion para obtener altura
  Future _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: settings,
    );
    setState(() {
       posicion= position.altitude -dzaltitude;
    });
  }

  //. Funcion para obtener DZ Altitude

  Future<void> _obtenerDzAltitude () async{
    int dzaltitude = await JumpLogDatabase.getDzAltitude();
    setState(() {
      this.dzaltitude=dzaltitude;
    });
  }

  //. Funcio inicia el stream de actualización en tiempo real
  void _startStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // actualiza si cambia 1 metro
      ),
    ).listen((Position position) {
      setState(() {
        posicion = position.altitude - dzaltitude;
        _updateCount++;
      });
    });

    // Timer para contar segundos activos
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => _segundos++);
    });
  }

  //. Detiene el stream y el contador
  void _stopStream() {
    _positionStream?.cancel();
    _positionStream = null;
    _timer?.cancel();
    _timer = null;

    setState(() {
      _updateCount = 0;
      _segundos = 0;
    });
  }

  //. Toggle de encendido/apagado
  void _toggleAltitud() {
    if (_positionStream == null) {
      _startStream();
    } else {
      _stopStream();
    }
  }

  //. Funcion para formatear altitud
  String _formatAltitud(double posicion, bool isImperial) {
    if (isImperial) {
      double altitudFt = posicion * 3.28084;
      if (altitudFt < 1000) {
        return "${altitudFt.toInt()} ft"; // menos de 1000 → enteros
      } else {
        return "${(altitudFt / 1000).toStringAsFixed(2)} ft"; // más de 1000 → miles
      }
    } else {
      return "${posicion.toInt()} m"; // metros siempre con 2 decimales
    }
  }

  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: ValueListenableBuilder(
              valueListenable:  isImperialSystemNotifier,
              builder: (BuildContext context, bool isImperialSystem, Widget? child) {
                return  AltitudeText(text: _formatAltitud(posicion, isImperialSystem));
              },
            ),),
            Text(
              "Actualizaciones: $_updateCount",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),
            Text(
              "Segundos activos: $_segundos",
              style: TextStyle(fontSize: 18, color: Colors.white70),
            ),        
            SwitchListTile.adaptive(value: _positionStream != null,
             onChanged:(value) => _toggleAltitud(),
             title: Text("Altitud en tiempo real"),)
          ],
        ),
      ),
    );
  }
}
