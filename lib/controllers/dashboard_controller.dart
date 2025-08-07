import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/fish_entry.dart';
import '../services/fish_entry_service.dart';
import '../constants/enums.dart';

class DashboardController extends GetxController {
  final FishEntryService _fishService = FishEntryService();

  final RxList<FishEntry> entries = <FishEntry>[].obs;
  final RxBool isLoading = false.obs;

  // Form fields
  final formKey = GlobalKey<FormState>();
  final priceController = TextEditingController();
  final weightController = TextEditingController();
  final Rx<FishType> selectedFishType = FishType.seaFish.obs;
  final Rx<WestBengalState> selectedState = WestBengalState.kolkata.obs;

  // Filters
  final Rx<FishType?> filterFishType = Rx<FishType?>(FishType.seaFish);
  final Rx<DateTime?> filterStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> filterEndDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchEntries();
  }

  @override
  void onClose() {
    priceController.dispose();
    weightController.dispose();
    super.onClose();
  }

  Future<void> fetchEntries() async {
    try {
      isLoading.value = true;
      entries.value = await _fishService.getEntries(
        filterType: filterFishType.value?.label,
        startDate: filterStartDate.value,
        endDate: filterEndDate.value,
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addEntry() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final entry = FishEntry(
        fishType: selectedFishType.value,
        state: selectedState.value,
        pricePerWeight: double.parse(priceController.text),
        weight: double.parse(weightController.text),
        createdAt: DateTime.now(),
      );

      await _fishService.addEntry(entry);
      await fetchEntries();

      clearForm();
      Get.dialog(
        AlertDialog(
          title: Text('Success'),
          content: Text('Entry added successfully'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    }
  }

  void clearForm() {
    selectedFishType.value = FishType.seaFish;
    selectedState.value = WestBengalState.kolkata;
    priceController.clear();
    weightController.clear();
  }

  Future<void> selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: Get.context!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: filterStartDate.value != null && filterEndDate.value != null
          ? DateTimeRange(
              start: filterStartDate.value!,
              end: filterEndDate.value!,
            )
          : null,
    );

    if (picked != null) {
      filterStartDate.value = picked.start;
      filterEndDate.value = picked.end;
      fetchEntries();
    }
  }

  void clearFilters() {
    filterFishType.value = null;
    filterStartDate.value = null;
    filterEndDate.value = null;
    fetchEntries();
  }

  Future<void> updateEntry(String id, FishEntry updatedEntry) async {
    try {
      isLoading.value = true;
      await _fishService.updateEntry(id, updatedEntry);
      await fetchEntries(); // Refresh the list

      Get.dialog(
        AlertDialog(
          title: Text('Success'),
          content: Text('Entry updated successfully'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      isLoading.value = true;
      await _fishService.deleteEntry(id);
      await fetchEntries(); // Refresh the list

      Get.dialog(
        AlertDialog(
          title: Text('Success'),
          content: Text('Entry deleted successfully'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.dialog(
        AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
