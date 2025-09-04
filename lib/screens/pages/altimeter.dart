                                                //!altimeter.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terminal_salto_libre/data/logbook_db.dart';
import 'package:terminal_salto_libre/data/models.dart';
import 'package:terminal_salto_libre/data/notifiers.dart';
import 'dart:async';

class AltimeterPage extends StatefulWidget {
  final int? jumpId;
  const AltimeterPage({super.key, this.jumpId});

  @override
  State<AltimeterPage> createState() => _AltimeterPageState();
}

class _AltimeterPageState extends State<AltimeterPage> {
  
  final LocationSettings settings = LocationSettings(accuracy: LocationAccuracy.bestForNavigation,);
  double alt = 0;
  double lat = 0;
  double lon = 0;
  int _insercionesDb = 0;
  int _updateCount = 0;
  int _segundos = 0;
  late Timer? _timer;
  late StreamSubscription<Position>? _positionStream;
  late final int landingAltitude;
  //late VoidCallback _trackingListener;
  void _trackingListener(){
    if (isTracking.value) {
        _startStream();
      } else {
        _stopStream();
      }
  }

  

  //. Metodo para cargar datos.
  @override
  initState(){
    super.initState();
    _checkPermissions();
    _obtenerLandingAltitude().then((value) => _trackingListener(),);
    isTracking.addListener(_trackingListener);
    

  }

  //. Metodo para limpiar cache.
  @override
  dispose(){
    _timer?.cancel();
    _positionStream?.cancel();
    isTracking.removeListener(_trackingListener);
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
       alt= position.altitude - landingAltitude;
    });
  }

  //. Funcion para obtener Landing Altitude

  Future<void> _obtenerLandingAltitude () async{
    int landingAltitude = await JumpLogDatabase.getLandingAltitude();
    setState(() {
      this.landingAltitude=landingAltitude;
    });
  }

  //. Funcio inicia el stream de actualización en tiempo real
  void _startStream() {
    //final messenger = ScaffoldMessenger.of(context);
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1, // actualiza si cambia 1 metro
      ),
    ).listen((Position position) async {
     try{
      alt = position.altitude - landingAltitude;
      lon = position.longitude;
      lat = position.latitude;

      // Guardar solo si está activado el tracking
      if (widget.jumpId != null)  {
        await JumpLogDatabase.insertPosAlti(
          jumpId: widget.jumpId!,
          alt: alt,
          lon:lon,
          lat:lat,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          );
          _insercionesDb++;
        }
        
        setState(() {
          _updateCount++;
        });
     }catch(error){if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $error")));}}
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

  //. Funcion para formatear altitud
  String _formatAltitud(double posicion, bool isImperial) {
    if (isImperial) {
      double altitudFt = posicion * 3.28084;
      if (altitudFt < 1000) {
        return "${altitudFt.toInt()}\nft"; // menos de 1000 → enteros
      } else {
        return "${(altitudFt / 1000).toStringAsFixed(2)}\nkft"; // más de 1000 → miles
      }
    } else {
      if (posicion < 1000){
        return "${posicion.toInt()}\nm"; // metros siempre con 2 decimales
      }
      return "${(posicion/1000).toStringAsFixed(2)}\nkm"; // más de 1000 → miles
    }
  }

  



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: ValueListenableBuilder(
                valueListenable:  isImperialSystemNotifier,
                builder: (BuildContext context, bool isImperialSystem, Widget? child) {
                  return  AltitudeText(text: _formatAltitud(alt, isImperialSystem));
                },
              ),),
              SizedBox(height: 5,),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),child: Row(children: [
                SizedBox(width: 300,child: Text("Actualizaciones de posicion: ",style: subtitulo,),),
                CircleAvatar(child: Text(_updateCount.toString()),)
              ],),),
              SizedBox(height: 5,),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),child: Row(children: [
                SizedBox(width: 300, child: Text("Inserciones en la db de posicion: ",style: subtitulo,),),
                CircleAvatar(child: Text("$_insercionesDb"),)
              ],),),
              SizedBox(height: 5,),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),child: Row(children: [
                SizedBox(width: 300,child: Text("Segundos activos: ",style: subtitulo,),),
                CircleAvatar(child: Text("$_segundos"),)//
              ],),),
              ValueListenableBuilder(
                valueListenable: isTracking,
                builder: (BuildContext context, bool isTrackingbool, Widget? child) {
                  return  SwitchListTile.adaptive(value: isTrackingbool,
                    onChanged:(value) => isTracking.value = value,
                    title: Text("Altitud en tiempo real"),);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
