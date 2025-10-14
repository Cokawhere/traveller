import 'package:cloud_firestore/cloud_firestore.dart';

class TripModel {
  final String tripId;
  final String origin;
  final String destination;
  final DateTime time;
  final String locationId;

  TripModel({
    required this.tripId,
    required this.origin,
    required this.destination,
    required this.time,
    required this.locationId,
  });

  Map<String, dynamic> toMap() {
    return {
      'tripId': tripId,
      'origin': origin,
      'destination': destination,
      'time': time.toIso8601String(),
      'locationId': locationId,
    };
  }

  factory TripModel.fromMap(Map<String, dynamic> map) {
    return TripModel(
      tripId: map['tripId'] ?? '',
      origin: map['origin'] ?? '',
      destination: map['destination'] ?? '',
      time: DateTime.parse(map['time'] ?? DateTime.now().toIso8601String()),
      locationId: map['locationId'] ?? '',
    );
  }

  factory TripModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TripModel.fromMap(data);
  }
}