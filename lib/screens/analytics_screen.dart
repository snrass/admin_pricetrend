import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../components/card.dart';
import '../components/dropdown.dart';
import '../controllers/analytics_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

class AnalyticsScreen extends StatelessWidget {
  final controller = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          drawer: isMobile ? Drawer(child: Sidebar()) : null,
          appBar: isMobile
              ? AppBar(
                  title: Text('Price Analytics'),
                  backgroundColor: AppTheme.backgroundColor,
                  iconTheme: IconThemeData(color: AppTheme.primaryColor),
                  elevation: 0,
                )
              : null,
          body: isMobile
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      _buildFilterSection(),
                      SizedBox(height: 16),
                      Expanded(
                        child: CustomCard(
                          child: _buildChart(
                            isMobile: isMobile
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Sidebar(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Analytics',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 24),
                            _buildFilterSection(),
                            SizedBox(height: 24),
                            Expanded(
                              child: CustomCard(
                                child: _buildChart(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => CustomDropdown(
                label: 'Species Type',
                value: controller.selectedSpeciesType.value?.obs,
                items: controller.speciesTypes,
                onChanged: controller.loadSpeciesData,
              )),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Obx(() => CustomDropdown(
                label: 'Species',
                value: controller.selectedSpecies.value?.obs,
                items: controller.availableSpecies,
                onChanged: (value) {
                  controller.selectedSpecies.value = value;
                  controller.fetchPriceData();
                },
                enabled: controller.selectedSpeciesType.value != null,
              )),
        ),
      ],
    );
  }

  Widget _buildChart({bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading price data...',
                  style: TextStyle(color: AppTheme.secondaryColor),
                ),
              ],
            ),
          );
        }

        final entries = controller.entries;

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart,
                    size: 48, color: AppTheme.secondaryColor.withOpacity(0.5)),
                SizedBox(height: 16),
                Text(
                  'No price data available for selected species',
                  style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate min and max values for Y axis
        final prices = entries.map((e) => e.price).toList();
        final maxY = prices.reduce(max);
        final minY = prices.reduce(min);
        final padding = (maxY - minY) * 0.1;

        return Column(
          children: [
            // Chart Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price Trend',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        controller.selectedSpecies.value ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timeline,
                            size: 18, color: AppTheme.primaryColor),
                        SizedBox(width: 8),
                        Text(
                          '${entries.length} Entries',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Price Summary
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildPriceSummaryCard(
                        'Lowest',
                        '₹${minY.toStringAsFixed(2)}',
                        Icons.arrow_downward,
                        Colors.red,
                      ),
                      SizedBox(width: 16),
                      _buildPriceSummaryCard(
                        'Average',
                        '₹${(prices.reduce((a, b) => a + b) / prices.length).toStringAsFixed(2)}',
                        Icons.equalizer,
                        Colors.orange,
                      ),
                      SizedBox(width: 16),
                      _buildPriceSummaryCard(
                        'Highest',
                        '₹${maxY.toStringAsFixed(2)}',
                        Icons.arrow_upward,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: BarChart(
                  BarChartData(
                    maxY: maxY + padding,
                    minY: (minY - padding).clamp(0, double.infinity),
                    alignment: BarChartAlignment.spaceAround,
                    backgroundColor: Colors.white,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.white,
                        tooltipPadding: EdgeInsets.all(16),
                        tooltipRoundedRadius: 8,
                        tooltipMargin: 8,
                        tooltipBorder: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final entry = entries[group.x.toInt()];
                          final percentageFromMin =
                              ((entry.price - minY) / (maxY - minY) * 100)
                                  .round();
                          return BarTooltipItem(
                            'Date: ${DateFormat('dd MMM yyyy').format(entry.createdAt)}\n',
                            TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '₹${entry.price.toStringAsFixed(2)}\n',
                                style: TextStyle(
                                  color: entry.price == maxY
                                      ? Colors.green
                                      : entry.price == minY
                                          ? Colors.red
                                          : AppTheme.primaryColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: '$percentageFromMin% from lowest price\n',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: 'Size: ${entry.sizeGrade}\n',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: 'State: ${entry.state}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
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
                        axisNameWidget: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Date',
                            style: TextStyle(
                              color: AppTheme.secondaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: max(1, (entries.length / 10).floor().toDouble()),
                          getTitlesWidget: (value, meta) {
                            if (value < 0 || value >= entries.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Text(
                                  DateFormat('dd MMM').format(entries[value.toInt()].createdAt),
                                  style: TextStyle(
                                    color: AppTheme.secondaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        // axisNameWidget: Padding(
                        //   padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                        //   child: Text(
                        //     'Price (₹)',
                        //     style: TextStyle(
                        //       color: AppTheme.secondaryColor,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          interval: max(1, (maxY - minY) / 5),
                          getTitlesWidget: (value, meta) {
                            return Container(
                              padding: const EdgeInsets.only(bottom: 8.0, right: 2),
                              child: Text(
                                '₹${NumberFormat('#,##0').format(value.toInt())}',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(
                        axisNameWidget: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            'Price Trend Over Time',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: max(1, (maxY - minY) / 5),
                      verticalInterval: max(1, entries.length / 10),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          strokeWidth: 1,
                          dashArray: [4, 4], // Dotted line
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          strokeWidth: 1,
                          dashArray: [4, 4], // Dotted line
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    barGroups: entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final value = entry.value;
                      final isHighest = value.price == maxY;
                      final isLowest = value.price == minY;

                      // Responsive bar width based on number of entries
                      final double width = entries.length > 30
                          ? 8
                          : entries.length > 20
                              ? 12
                              : 16;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value.price,
                            gradient: LinearGradient(
                              colors: isHighest
                                  ? [
                                      Colors.green.shade300,
                                      Colors.green.shade500,
                                    ]
                                  : isLowest
                                      ? [
                                          Colors.red.shade300,
                                          Colors.red.shade500,
                                        ]
                                      : [
                                          AppTheme.primaryColor
                                              .withOpacity(0.7),
                                          AppTheme.primaryColor,
                                        ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: width,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4),
                              bottom: Radius.circular(1),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxY + padding,
                              color: isHighest
                                  ? Colors.green.withOpacity(0.05)
                                  : isLowest
                                      ? Colors.red.withOpacity(0.05)
                                      : AppTheme.secondaryColor
                                          .withOpacity(0.05),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  swapAnimationDuration: Duration(milliseconds: 500),
                  swapAnimationCurve: Curves.easeInOutQuart,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPriceSummaryCard(
      String title, String price, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
