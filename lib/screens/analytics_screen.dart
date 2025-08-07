import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/analytics_controller.dart';
import '../components/card.dart';
import '../components/dropdown.dart';
import '../theme/app_theme.dart';
import '../constants/enums.dart';
import '../widgets/sidebar.dart';

class AnalyticsScreen extends StatelessWidget {
  final controller = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: CustomCard(
                    margin: EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilters(),
                        SizedBox(height: 24),
                        Expanded(
                          child: _buildChart(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.secondaryColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Text(
        'Analytics',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: CustomDropdown(
            label: 'Fish Type',
            value: (controller.selectedFishType.value?.label ?? '').obs,
            items: ['All', ...FishType.values.map((type) => type.label)],
            onChanged: (value) {
              if (value == 'All') {
                controller.setFishType(null);
              } else {
                controller.setFishType(
                  FishType.values.firstWhere((type) => type.label == value),
                );
              }
            },
          ),
        ),
        SizedBox(width: 16),
        ...TimeFilter.values.map(
          (filter) => Padding(
            padding: EdgeInsets.only(right: 8),
            child: Obx(
              () => FilterChip(
                selected: controller.selectedTimeFilter.value == filter,
                label: Text(filter.label),
                onSelected: (_) => controller.setTimeFilter(filter),
                backgroundColor: AppTheme.surfaceColor,
                selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: controller.selectedTimeFilter.value == filter
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return GetBuilder<AnalyticsController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        }

        final data = controller.getChartData();
        if (data.isEmpty) {
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(color: AppTheme.secondaryColor),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                controller.getChartTitle(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: data.map((e) => e.maxPrice).reduce((a, b) => a > b ? a : b) * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: AppTheme.surfaceColor,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: EdgeInsets.all(12),
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final barData = data[group.x.toInt()];
                          return BarTooltipItem(
                            '${barData.date}\n',
                            TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'Average: ₹${barData.price.toStringAsFixed(2)}\n',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: 'Range: ${controller.getPriceRange(barData)}\n',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: 'Entries: ${barData.count}',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= data.length) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle: controller.selectedTimeFilter.value == TimeFilter.day ? 0 : -0.5,
                                child: Text(
                                  data[value.toInt()].date,
                                  style: TextStyle(
                                    color: AppTheme.secondaryColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          },
                          reservedSize: controller.selectedTimeFilter.value == TimeFilter.day ? 30 : 50,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(
                          'Price (₹)',
                          style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 12,
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '₹${value.toInt()}',
                              style: TextStyle(
                                color: AppTheme.secondaryColor,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                        ),
                        left: BorderSide(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                        ),
                      ),
                    ),
                    barGroups: data.asMap().entries.map((entry) {
                      final barData = entry.value;
                      return BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: barData.price,
                            color: AppTheme.primaryColor.withOpacity(barData.count > 0 ? 1 : 0.3),
                            width: 16,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: data.map((e) => e.maxPrice).reduce((a, b) => a > b ? a : b) * 1.2,
                              color: AppTheme.secondaryColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
