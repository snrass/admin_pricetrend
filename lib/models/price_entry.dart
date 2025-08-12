import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/enums.dart';

class PriceEntry {
  final String? id;
  final ParentFishType parentFishType;
  final UsedForType usedForType;
  final String location;
  final DateTime date;
  final String speciesType; // e.g., "FRESH WATER"
  final String speciesName; // Common Name
  final String sizeGrade;
  final double price;
  final String state;
  final DateTime createdAt;

  PriceEntry({
    this.id,
    required this.parentFishType,
    required this.usedForType,
    required this.location,
    required this.date,
    required this.speciesType,
    required this.speciesName,
    required this.sizeGrade,
    required this.price,
    required this.state,
    required this.createdAt,
  });

  factory PriceEntry.fromJson(Map<String, dynamic> json, [String? id]) {
    return PriceEntry(
      id: id,
      parentFishType: ParentFishType.values.firstWhere((e) => e.name == json['parentFishType']),
      usedForType: UsedForType.values.firstWhere((e) => e.label == json['usedForType']),
      location: json['location'],
      date: (json['date'] as Timestamp).toDate(),
      speciesType: json['speciesType'],
      speciesName: json['speciesName'],
      sizeGrade: json['sizeGrade'],
      price: json['price']?.toDouble() ?? 0.0,
      state: json['state'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parentFishType': parentFishType.name,
      'usedForType': usedForType.label,
      'location': location,
      'date': Timestamp.fromDate(date),
      'speciesType': speciesType,
      'speciesName': speciesName,
      'sizeGrade': sizeGrade,
      'price': price,
      'state': state,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
