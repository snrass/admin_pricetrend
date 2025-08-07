import 'package:get/get.dart';
import '../models/fish_entry.dart';
import '../services/fish_entry_service.dart';
import '../constants/enums.dart';

class AnalyticsController extends GetxController {
  final FishEntryService _fishService = FishEntryService();
  final RxList<FishEntry> entries = <FishEntry>[].obs;
  final RxBool isLoading = false.obs;

  final Rx<TimeFilter> selectedTimeFilter = TimeFilter.day.obs;
  final Rx<FishType?> selectedFishType = Rx<FishType?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchEntries();
  }

  Future<void> fetchEntries() async {
    try {
      isLoading.value = true;
      entries.value = await _fishService.getEntries(
        filterType: selectedFishType.value?.label,
      );
      processData();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void setTimeFilter(TimeFilter filter) {
    selectedTimeFilter.value = filter;
    processData();
  }

  void setFishType(FishType? type) {
    selectedFishType.value = type;
    fetchEntries();
  }

  List<BarData> getChartData() {
    if (entries.isEmpty) return [];

    final Map<String, List<double>> groupedPrices = {};
    final now = DateTime.now();

    // Pre-populate with empty data for continuous timeline
    switch (selectedTimeFilter.value) {
      case TimeFilter.day:
        // Show last 30 days
        for (int i = 29; i >= 0; i--) {
          final date = DateTime.now().subtract(Duration(days: i));
          groupedPrices[_formatDate(date)] = [];
        }
        break;
      case TimeFilter.month:
        // Show last 12 months
        for (int i = 11; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i, 1);
          groupedPrices[_formatDate(date)] = [];
        }
        break;
      case TimeFilter.year:
        // Show last 5 years
        for (int i = 4; i >= 0; i--) {
          final date = DateTime(now.year - i, 1, 1);
          groupedPrices[_formatDate(date)] = [];
        }
        break;
    }

    // Add actual data
    for (var entry in entries) {
      String key = _formatDate(entry.createdAt!);
      if (groupedPrices.containsKey(key)) {
        groupedPrices[key]!.add(entry.pricePerWeight);
      }
    }

    return groupedPrices.entries.map((e) {
      final prices = e.value;
      final avgPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a + b) / prices.length;
      final minPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b);
      final maxPrice = prices.isEmpty ? 0 : prices.reduce((a, b) => a > b ? a : b);

      return BarData(
        date: e.key,
        price: avgPrice.toDouble(),
        minPrice: minPrice.toDouble(),
        maxPrice: maxPrice.toDouble(),
        count: prices.length,
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    switch (selectedTimeFilter.value) {
      case TimeFilter.day:
        final month = date.month.toString().padLeft(2, '0');
        final day = date.day.toString().padLeft(2, '0');
        return '$day/$month';
      case TimeFilter.month:
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${months[date.month - 1]} ${date.year}';
      case TimeFilter.year:
        return date.year.toString();
    }
  }

  String getChartTitle() {
    final type = selectedFishType.value?.label ?? 'All Fish Types';
    switch (selectedTimeFilter.value) {
      case TimeFilter.day:
        return '$type Price Trend - Last 30 Days';
      case TimeFilter.month:
        return '$type Price Trend - Last 12 Months';
      case TimeFilter.year:
        return '$type Price Trend - Last 5 Years';
    }
  }

  String getPriceRange(BarData data) {
    if (data.count == 0) return 'No data';
    if (data.minPrice == data.maxPrice) return '₹${data.minPrice.toStringAsFixed(2)}';
    return '₹${data.minPrice.toStringAsFixed(2)} - ₹${data.maxPrice.toStringAsFixed(2)}';
  }

  void processData() {
    update(); // Triggers UI update for the chart
  }
}

class BarData {
  final String date;
  final double price;
  final double minPrice;
  final double maxPrice;
  final int count;

  BarData({
    required this.date,
    required this.price,
    required this.minPrice,
    required this.maxPrice,
    required this.count,
  });
}
