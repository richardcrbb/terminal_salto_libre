import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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

//!   Clase SettingsLog                                                                                                        

class SettingsLog{
  
  int previousJumps; 
  int previousFreefall; 
  int previousTandems; 
  int previousAffs; 
  int previousCameras; 
  int previousCoaches; 
  int previousFunJumps;

  SettingsLog({
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
  
  static SettingsLog fromMap(Map<String,dynamic> json){
    return SettingsLog(
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

//!      Estilo de Texo 'titulo'                                                                                                     

const TextStyle titulo = TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0);

const List<String> jumpTypeList = [
  'Tandem',
  'AFF',
  'Camera',
  'Coach',
  'Fun Jump',
];

  String formatearFecha(String fechaISO) {
  // Si jump.date ya es un String ISO, lo convertimos a DateTime
  final dateTime = DateTime.parse(fechaISO);
  return DateFormat('dd/MMM/yyyy').format(dateTime);
  }
