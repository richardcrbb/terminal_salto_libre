import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:terminal_salto_libre/data/shared_functions.dart';

//!  Clase JumpLog                                                                                                         

class JumpLog {
  final int? id;
  final int jumpNumber;
  final String date;
  final String location;
  final String aircraft;
  final String equipment;
  final int altitude;
  final int freefallDelay;
  final int? totalFreefall;
  final String jumpType;
  final int? weight;
  final int? age;
  final String description;
  final String signature;
  final int favorites;

  JumpLog({
    this.id,
    required this.jumpNumber,
    required this.date,
    required this.location,
    required this.aircraft,
    required this.equipment,
    required this.altitude,
    required this.freefallDelay,
    required this.jumpType,
    this.weight,
    this.age,
    this.totalFreefall,
    required this.description,
    required this.signature,
    this.favorites=0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jumpNumber': jumpNumber,
      'date': date,
      'location': location,
      'aircraft': aircraft,
      'equipment': equipment,
      'altitude': altitude,
      'freefallDelay': freefallDelay,
      'totalFreefall': totalFreefall,
      'jumpType': jumpType,
      'weight': weight,
      'age' : age,
      'description': description,
      'signature': signature,
      'favorites': favorites,
    };
  }

  static JumpLog fromMap(Map<String, dynamic> map) {
    return JumpLog(
      id: map['id'],
      jumpNumber: map['jumpNumber'],
      date: map['date'],
      location: map['location'],
      aircraft: map['aircraft'],
      equipment: map['equipment'],
      altitude: map['altitude'],
      freefallDelay: map['freefallDelay'],
      totalFreefall: map['totalFreefall'],
      jumpType: map['jumpType'],
      weight: map['weight'],
      age : map['age'],
      description: map['description'],
      signature: map['signature'],
      favorites: map['favorites'],
    );
  }
}

//!   Clase SettingsSkydivingLog                                                                                                        

class SettingsSkydivingLog{
  
  int previousJumps; 
  int previousFreefall; 
  int previousTandems; 
  int previousAffs; 
  int previousCameras; 
  int previousCoaches; 
  int previousFunJumps;

  SettingsSkydivingLog({
    required this.previousJumps,
    required this.previousFreefall,
    required this.previousTandems,
    required this.previousAffs,
    required this.previousCameras,
    required this.previousCoaches,
    required this.previousFunJumps,
  });

  Map<String,dynamic>  toMap(){
    return {
      'previousJumps':previousJumps,
      'previousFreefall':previousFreefall,
      'previousTandems':previousTandems,
      'previousAffs':previousAffs,
      'previousCameras':previousCameras,
      'previousCoaches':previousCoaches,
      'previousFunJumps':previousFunJumps,
    };
  }
  
  static SettingsSkydivingLog fromMap(Map<String,dynamic> json){
    return SettingsSkydivingLog(
      previousJumps: json['previousJumps'],
      previousFreefall: json['previousFreefall'],
      previousTandems: json['previousTandems'],
      previousAffs: json['previousAffs'],
      previousCameras: json['previousCameras'],
      previousCoaches: json['previousCoaches'],
      previousFunJumps: json['previousFunJumps'],
      );
  }
  
  
}

//#   Clase SettingsBasejumpLog                                                                                                        

 class SettingsBasejumpLog {
  int previousJumps;
  int previousFreefall;
  int previousAsisted;
  int previousBelly;
  int previousTARD;
  int previousFreefly;
  int previousTracking;
  int previousWingsuit;

  SettingsBasejumpLog({
  required this.previousJumps,
  required this.previousFreefall,
  required this.previousAsisted,
  required this.previousBelly,
  required this.previousTARD,
  required this.previousFreefly,
  required this.previousTracking,
  required this.previousWingsuit,
  });

  Map<String,dynamic> toMap (){
    return{
      'previousJumps': previousJumps,
      'previousFreefall': previousFreefall,
      'previousAsisted': previousAsisted,
      'previousBelly': previousBelly,
      'previousTARD': previousTARD,
      'previousFreefly': previousFreefly,
      'previousTracking': previousTracking,
      'previousWingsuit': previousWingsuit,
    };
  }

  static SettingsBasejumpLog fromMap (Map<String,dynamic> json){
    return SettingsBasejumpLog(
      previousJumps: json['previousJumps'],
      previousFreefall: json['previousFreefall'],
      previousAsisted: json['previousAsisted'],
      previousBelly: json['previousBelly'],
      previousTARD: json['previousTARD'],
      previousFreefly: json['previousFreefly'],
      previousTracking: json['previousTracking'],
      previousWingsuit: json['previousWingsuit'],
      );
  }
 }

//$       ListTile de ruta Logbook                                                                                                                    

class ListTileOfLogbook{
  JumpLog jump;
  
  ListTileOfLogbook(this.jump);

  CircleAvatar leading () {return CircleAvatar(child: Text('${jump.jumpNumber}'));}
  
  Text title () {return Text(
    '${jump.jumpType} en ${jump.location} el ${formatearFecha(jump.date)}',
    );}

  Text subtitle () { return Text(
    '${jump.aircraft}, ${jump.altitude} FT, ${jump.freefallDelay}\'s Delay, ${formatSecondsToHHMMSS(jump.totalFreefall!)}, ${jump.signature}',);
    }
  Icon trailing (){return jump.favorites == 0 ? Icon(Icons.star_outline_sharp): Icon(Icons.stars_rounded);}

  Future onTap(BuildContext context)async{
    double spacer = 110;
    Padding jumpDetails = Padding(
      padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [SizedBox(width: spacer, child: Text('Jump Number:')),SizedBox(child: Text('${jump.jumpNumber}'),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Date:')),SizedBox(child: Text(formatearFecha(jump.date)),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Location:')),SizedBox(child: Text(jump.location),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Aircraft:')),SizedBox(child: Text(jump.aircraft),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Equipment:')),SizedBox(child: Text(jump.equipment),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Altitude:')),SizedBox(child: Text('${jump.altitude}'),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Freefall Delay:')),SizedBox(child: Text('${jump.freefallDelay}'),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Total Freefall:')),SizedBox(child: Text('${jump.totalFreefall}'),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Jump Type:')),SizedBox(child: Text(jump.jumpType),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Weight:')),SizedBox(child: Text('${jump.weight}'),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Age:')),SizedBox(child: Text('${jump.age}'),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Description:')),Expanded(child: Text(jump.description),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Signature:')),SizedBox(child: Text(jump.signature),),],),
            SizedBox(height: 10,),
            Row(children: [SizedBox(width: spacer, child: Text('Favorites:')),SizedBox(child: trailing()),],),
            ],
          ),
        ),
    );
    return showDialog(context: context, builder: (_) {
      return Dialog(child: jumpDetails,);
    },);
  }
}

//$       Tipo de deporte                                                                                                                                     
enum Deporte {
  skydiving,
  basejump,
  }


//!      Listado de tipo de salto.                                                                                                    
const List<String> jumpTypeList = [
  'Tandem',
  'AFF',
  'Camera',
  'Coach',
  'Fun Jump',
];

//#      Listado de tipo de salto en BASEJUMP.                                                                                                    
const List<String> jumpTypeListInBase = [
  'Asisted',
  'Belly',
  'TARD',
  'Freefly',
  'Tracking',
  'Wingsuit',
];



//!      Formato de fecha                                                                                                            
String formatearFecha(String fechaISO) {
  // Si jump.date ya es un String ISO, lo convertimos a DateTime
  final dateTime = DateTime.parse(fechaISO);
  return DateFormat('dd/MMM/yyyy').format(dateTime);
  }

//!      Estilo de Texo 'titulo'                                                                                                     

const TextStyle titulo = TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0);

//!      Estilo de Texo 'subtitulo' de altimetro                                                                                        

const TextStyle subtitulo = TextStyle(fontSize: 18, color: Colors.white70);



//!      Estilo de widget Altimetro                                                                                                     
  class AltitudeText extends StatelessWidget {
    final String text;

    const AltitudeText({super.key, required this.text});

    @override
    Widget build(BuildContext context) {
      return Container(
        width: double.infinity, // ocupa todo el ancho
        alignment: Alignment.center, // centra el texto horizontalmente
        padding: const EdgeInsets.symmetric(vertical: 16), // opcional: separación vertical
        child: Center(child: Text(
          text,
          textAlign: TextAlign.center, // asegura centrado en múltiples líneas
          style: const TextStyle(
            fontSize: 180, // tamaño grande para que destaque
            fontWeight: FontWeight.bold,
            color: Colors.white60, // puedes cambiar el color si quieres
            height: 1 
          ),
        ),)
      );
    }
  }

