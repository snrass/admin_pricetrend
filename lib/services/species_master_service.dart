import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/species_model.dart';

class SpeciesMasterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadSpeciesMasterData() async {
    try {
      // Read the JSON file
      final String jsonString = await rootBundle.loadString(
          'assets/species_master_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Convert to our model
      final speciesData = SpeciesMasterData.fromJson(jsonData);

      // Create a batch for atomic operation
      final WriteBatch batch = _firestore.batch();

      // Reference to the master collection
      final CollectionReference masterCollection = _firestore.collection('species_master');

      // Add each category and its species
      speciesData.data.forEach((category, speciesList) {
        final categoryDoc = masterCollection.doc(category);

        // Create a map of species for this category
        final Map<String, dynamic> categoryData = {
          'species': speciesList.map((species) => species.toJson()).toList(),
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        batch.set(categoryDoc, categoryData);
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error uploading species master data: $e');
      rethrow;
    }
  }

  Future<void> updateSpeciesPrice({
    required String category,
    required String commonName,
    required String size,
    required double price,
  }) async {
    try {
      final DocumentReference categoryDoc = _firestore.collection('species_master').doc(category);

      // Get the current data
      final DocumentSnapshot snapshot = await categoryDoc.get();
      if (!snapshot.exists) {
        throw Exception('Category not found');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> species = data['species'] as List<dynamic>;

      // Find and update the specific species and size
      for (var i = 0; i < species.length; i++) {
        if (species[i]['Common Name'] == commonName) {
          final sizeGrades = species[i]['Size/Gradec'] as List<dynamic>;
          for (var j = 0; j < sizeGrades.length; j++) {
            if (sizeGrades[j]['size'] == size) {
              sizeGrades[j]['price'] = price;
              break;
            }
          }
          break;
        }
      }

      // Update the document
      await categoryDoc.update({
        'species': species,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating species price: $e');
      rethrow;
    }
  }
}
