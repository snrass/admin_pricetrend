import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/price_entry.dart';

enum TimeFilter { daily, monthly, yearly }

class AnalyticsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<String> speciesTypes = <String>[].obs;
  final RxList<String> availableSpecies = <String>[].obs;
  final Rx<String?> selectedSpeciesType = Rx<String?>(null);
  final Rx<String?> selectedSpecies = Rx<String?>(null);
  final Rx<TimeFilter> timeFilter = TimeFilter.daily.obs;
  final RxList<PriceEntry> entries = <PriceEntry>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSpeciesTypes().then(
      (value) {
        loadSpeciesData(speciesTypes.first);
      },
    );
  }

  Future<void> loadSpeciesTypes() async {
    try {
      final snapshot = await _firestore.collection('species_master').get();
      speciesTypes.value = snapshot.docs.map((doc) => doc.id).toList()..sort();
      print('Loaded species types: ${speciesTypes.length}');
    } catch (e) {
      print('Error loading species types: $e');
      Get.snackbar('Error', 'Failed to load species types');
    }
  }

  Future<void> loadSpeciesData(String type) async {
    try {
      selectedSpeciesType.value = type;
      selectedSpecies.value = null;
      availableSpecies.clear();

      // First get all unique species names from the price_entries collection
      final entriesSnapshot = await _firestore
          .collection('price_entries')
          .where('speciesType', isEqualTo: type)
          .get();

      final Set<String> uniqueSpecies = {};
      for (var doc in entriesSnapshot.docs) {
        uniqueSpecies.add(doc.data()['speciesName'] as String);
      }

      // If no entries found, try getting species from species_master
      if (uniqueSpecies.isEmpty) {
        final masterDoc =
            await _firestore.collection('species_master').doc(type).get();

        if (masterDoc.exists) {
          final List<dynamic> species = masterDoc.data()?['species'] ?? [];
          for (var item in species) {
            uniqueSpecies.add(item['Common Name'] as String);
          }
        }
      }

      availableSpecies.value = uniqueSpecies.toList()..sort();
      print('Loaded ${availableSpecies.length} species for type: $type');

      selectedSpecies.value = availableSpecies[0];
      await fetchPriceData();
    } catch (e) {
      print('Error loading species data: $e');
      Get.snackbar('Error', 'Failed to load species list');
    }
  }

  Future<void> fetchPriceData() async {
    if (selectedSpeciesType.value == null || selectedSpecies.value == null) {
      print('No species type or species selected');
      return;
    }

    try {
      isLoading.value = true;
      print('Fetching prices for ${selectedSpecies.value}');

      final snapshot = await _firestore
          .collection('price_entries')
          .where('speciesType', isEqualTo: selectedSpeciesType.value)
          .where('speciesName', isEqualTo: selectedSpecies.value)
          .orderBy('createdAt', descending: false)
          .get();

      final loadedEntries = snapshot.docs
          .map((doc) => PriceEntry.fromJson(doc.data(), doc.id))
          .toList();

      print('Loaded ${loadedEntries.length} price entries');
      entries.value = loadedEntries;
    } catch (e) {
      print('Error fetching price data: $e');
      Get.snackbar('Error', 'Failed to fetch price data');
    } finally {
      isLoading.value = false;
    }
  }
}
