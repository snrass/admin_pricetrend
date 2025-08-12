import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/enums.dart';
import '../models/price_entry.dart';
import '../services/location_service.dart';
import '../models/location_model.dart';
import '../utils/debouncer.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  // Form fields
  final formKey = GlobalKey<FormState>();
  final priceController = TextEditingController();
  final Rx<String?> selectedSpeciesType = Rx(null);
  final Rx<String?> selectedSpecies = Rx<String?>(null);
  final Rx<String?> selectedSizeGrade = Rx<String?>(null);
  final Rx<WestBengalState> selectedState = WestBengalState.kolkata.obs;
  final Rx<ParentFishType?> selectedParentFishType = Rx<ParentFishType?>(null);
  final Rx<UsedForType?> selectedUsedForType = Rx<UsedForType?>(null);
  final locationController = TextEditingController();
  final Rx<LocationModel?> selectedLocation = Rx<LocationModel?>(null);
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Available options from Firestore
  final RxList<String> speciesTypes = <String>[].obs;
  final RxList<Map<String, dynamic>> availableSpecies =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> availableSizeGrades =
      <Map<String, dynamic>>[].obs;
  final RxList<LocationModel> availableLocations = <LocationModel>[].obs;

  // Entries list
  final RxList<PriceEntry> entries = <PriceEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Search functionality
  final RxString locationSearchQuery = ''.obs;
  final _debouncer = Debouncer();
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSpeciesTypes();
    fetchEntries();
    //_locationService.initializeLocations();
    setupLocationListener();
  }

  @override
  void onClose() {
    priceController.dispose();
    locationController.dispose();
    _debouncer.dispose();
    super.onClose();
  }

  void setupLocationListener() {
    ever(selectedUsedForType, (UsedForType? type) {
      if (type != null) {
        _updateLocations();
      }
    });

    ever(locationSearchQuery, (_) {
      _updateLocations();
    });
  }

  void _updateLocations() {
    if (selectedUsedForType.value == null) return;

    String locationType = selectedUsedForType.value == UsedForType.purchase
        ? 'harvesting'
        : 'market';

    if (locationSearchQuery.value.isEmpty) {
      _locationService.getLocationsByType(locationType).listen((locations) {
        availableLocations.value = locations;
      });
    } else {
      _locationService.searchLocations(locationType, locationSearchQuery.value)
          .listen((locations) {
        availableLocations.value = locations;
      });
    }
  }

  Future<void> loadSpeciesTypes() async {
    try {
      final snapshot = await _firestore.collection('species_master').get();
      speciesTypes.value = snapshot.docs.map((doc) => doc.id).toList();
      onSpeciesTypeChanged(speciesTypes.first);
    } catch (e) {
      print('Error loading species types: $e');
      Get.snackbar('Error', 'Failed to load species types');
    }
  }

  Future<void> onSpeciesTypeChanged(String? type) async {
    selectedSpeciesType.value = type;
    selectedSpecies.value = null;
    selectedSizeGrade.value = null;
    availableSpecies.clear();
    availableSizeGrades.clear();

    if (type != null) {
      try {
        final doc =
            await _firestore.collection('species_master').doc(type).get();
        if (doc.exists) {
          final List<dynamic> species = doc.data()?['species'] ?? [];
          // Create a map with Common Name as key to ensure uniqueness
          final Map<String, Map<String, dynamic>> uniqueSpecies = {};
          for (var item in species) {
            final commonName = item['Common Name'] as String;
            uniqueSpecies[commonName] = item;
          }

          availableSpecies.value = uniqueSpecies.values.toList();
        }
      } catch (e) {
        print('Error loading species: $e');
        Get.snackbar('Error', 'Failed to load species list');
      }
    }
  }

  void onSpeciesChanged(String? speciesName) {
    selectedSpecies.value = speciesName;
    selectedSizeGrade.value = null;
    availableSizeGrades.clear();

    if (speciesName != null) {
      final selectedSpeciesData = availableSpecies.firstWhere(
        (species) => species['Common Name'] == speciesName,
        orElse: () => {},
      );

      if (selectedSpeciesData.containsKey('Size/Gradec')) {
        final List<dynamic> sizeGrades = selectedSpeciesData['Size/Gradec'];
        // Ensure unique size grades
        final uniqueSizeGrades = sizeGrades
            .map((grade) => grade as Map<String, dynamic>)
            .toSet()
            .toList();
        availableSizeGrades.value = uniqueSizeGrades;
        log('${availableSizeGrades.toList()}', name: 'Unique Size Grades');
      }
    }
  }

  Future<void> addPriceEntry() async {
    if (!formKey.currentState!.validate() ||
        selectedSpeciesType.value == null ||
        selectedSpecies.value == null ||
        selectedSizeGrade.value == null ||
        selectedParentFishType.value == null ||
        selectedUsedForType.value == null ||
        locationController.text.isEmpty ||
        selectedDate.value == null) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    try {
      isSubmitting.value = true;
      final entry = PriceEntry(
        parentFishType: selectedParentFishType.value!,
        usedForType: selectedUsedForType.value!,
        location: locationController.text,
        date: selectedDate.value,
        speciesType: selectedSpeciesType.value!,
        speciesName: selectedSpecies.value!,
        sizeGrade: selectedSizeGrade.value!,
        price: double.parse(priceController.text),
        state: selectedState.value.label,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('price_entries').add(entry.toJson());
      clearForm();
      await fetchEntries();
      _showSuccessDialog('Price entry added successfully');
    } catch (e) {
      print('Error adding price entry: $e');
      _showErrorDialog('Failed to add price entry: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showSuccessDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void clearForm() {
    //selectedSpeciesType.value = null;
    // selectedSpecies.value = null;
    selectedSizeGrade.value = null;
    selectedState.value = WestBengalState.kolkata;
    priceController.clear();
    availableSpecies.clear();
    availableSizeGrades.clear();
    //selectedParentFishType.value = null;
    //selectedUsedForType.value = null;
    //locationController.clear();
    //selectedDate.value = DateTime.now();
  }

  Future<void> fetchEntries() async {
    try {
      isLoading.value = true;
      final snapshot = await _firestore
          .collection('price_entries')
          .orderBy('createdAt', descending: true)
          .get();

      entries.value = snapshot.docs
          .map((doc) => PriceEntry.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching entries: $e');
      Get.snackbar('Error', 'Failed to fetch entries');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _firestore.collection('price_entries').doc(id).delete();
      await fetchEntries();
      Get.snackbar('Success', 'Entry deleted successfully');
    } catch (e) {
      print('Error deleting entry: $e');
      Get.snackbar('Error', 'Failed to delete entry');
    }
  }

  void onLocationSearchChanged(String query) {
    isSearching.value = true;
    _debouncer.call(() {
      locationSearchQuery.value = query;
      isSearching.value = false;
    });
  }

  void onSelectLocation(LocationModel location) {
    locationController.text = location.name;
    selectedLocation.value = location;
    locationSearchQuery.value = '';
    availableLocations.clear(); // Clear suggestions after selection
    log('Selected Location: ${location.name}, Type: ${location.type}');
  }
}
