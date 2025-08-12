import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_model.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'locations';

  // Initialize predefined locations
  Future<void> initializeLocations() async {
    final harvestingPoints = [
      {'name': 'Moyna', 'type': 'harvesting'},
      {'name': 'Potaspur', 'type': 'harvesting'},
      {'name': 'Sobong', 'type': 'harvesting'},
      {'name': 'Paskura', 'type': 'harvesting'},
      {'name': 'Kolaghat', 'type': 'harvesting'},
    ];

    final marketLocations = [
      {'name': 'Bihar', 'type': 'market'},
      {'name': 'Asansol', 'type': 'market'},
      {'name': 'Farakka', 'type': 'market'},
      {'name': 'Siliguri', 'type': 'market'},
    ];

    final batch = _firestore.batch();
    final locations = [...harvestingPoints, ...marketLocations];

    // Check if collection is empty before initializing
    final snapshot = await _firestore.collection(_collection).get();
    if (snapshot.docs.isEmpty) {
      for (var location in locations) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, location);
      }
      await batch.commit();
    }
  }

  // Get locations by type (harvesting or market)
  Stream<List<LocationModel>> getLocationsByType(String type) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LocationModel.fromJson(doc.data()))
            .toList());
  }

  // Search locations by type and name
  Stream<List<LocationModel>> searchLocations(String type, String query) {
    return _firestore
        .collection(_collection)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LocationModel.fromJson(doc.data()))
            .where((location) =>
                location.name.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }
}
