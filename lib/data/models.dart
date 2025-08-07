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
  final String description;
  final String signature;

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
    this.totalFreefall,
    required this.description,
    required this.signature,
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
      'description': description,
      'signature': signature,
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
      description: map['description'],
      signature: map['signature'],
    );
  }
}
