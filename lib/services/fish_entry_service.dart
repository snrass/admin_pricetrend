import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fish_entry.dart';

class FishEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _entriesCollection =>
    _firestore.collection('fish_entries');

  Future<void> addEntry(FishEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      await _entriesCollection.add(entry.toJson());
    } catch (e) {
      throw 'Failed to add entry: $e';
    }
  }

  Future<List<FishEntry>> getEntries({
    String? filterType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      Query<Map<String, dynamic>> query = _entriesCollection
          .orderBy('createdAt', descending: true);

      if (filterType != null && filterType.isNotEmpty) {
        query = query.where('fishType', isEqualTo: filterType);
      }

      if (startDate != null) {
        query = query.where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        // Add one day to include the entire end date
        final nextDay = endDate.add(Duration(days: 1));
        query = query.where('createdAt',
          isLessThan: Timestamp.fromDate(nextDay));
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FishEntry.fromJson(data, doc.id);
      }).toList();
    } catch (e) {
      throw 'Failed to get entries: $e';
    }
  }

  Future<void> updateEntry(String id, FishEntry entry) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      await _entriesCollection.doc(id).update(entry.toJson());
    } catch (e) {
      throw 'Failed to update entry: $e';
    }
  }

  Future<void> deleteEntry(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      await _entriesCollection.doc(id).delete();
    } catch (e) {
      throw 'Failed to delete entry: $e';
    }
  }
}
