import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/enums.dart';

class FishEntry {
  final String? id;
  final FishType fishType;
  final WestBengalState state;
  final double pricePerWeight;
  final double size;
  final DateTime? createdAt;

  FishEntry({
    this.id,
    required this.fishType,
    required this.state,
    required this.pricePerWeight,
    required this.size,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'fishType': fishType.label,
      'state': state.label,
      'pricePerWeight': pricePerWeight,
      'weight': size,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory FishEntry.fromJson(Map<String, dynamic> json, String id) {
    return FishEntry(
      id: id,
      fishType: FishType.values.firstWhere(
        (type) => type.label == json['fishType'],
        orElse: () => FishType.seaFish,
      ),
      state: WestBengalState.values.firstWhere(
        (state) => state.label == json['state'],
        orElse: () => WestBengalState.kolkata,
      ),
      pricePerWeight: (json['pricePerWeight'] as num).toDouble(),
      size: (json['weight'] as num).toDouble(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
