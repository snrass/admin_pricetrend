import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../components/dropdown.dart';
import '../components/input.dart';
import '../components/button.dart';
import '../components/card.dart';
import '../widgets/sidebar.dart';
import '../models/fish_entry.dart';
import '../theme/app_theme.dart';
import '../constants/enums.dart';

class DashboardScreen extends StatelessWidget {
  final controller = Get.put(DashboardController());

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
                    padding: EdgeInsets.zero,
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.secondaryColor.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ),
                            ),
                            child: TabBar(
                              tabs: [
                                Tab(text: 'New Entry'),
                                Tab(text: 'Manage Entries'),
                              ],
                              labelColor: AppTheme.primaryColor,
                              unselectedLabelColor: AppTheme.secondaryColor,
                              indicatorColor: AppTheme.primaryColor,
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildNewEntryTab(),
                                _buildManageEntriesTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
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
          bottom: BorderSide(color: AppTheme.secondaryColor.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewEntryTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: controller.formKey,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDropdown(
                label: 'Fish Type',
                value: controller.selectedFishType.value.label.obs,
                items: FishType.values.map((type) => type.label).toList(),
                onChanged: (value) {
                  controller.selectedFishType.value = FishType.values
                      .firstWhere((type) => type.label == value);
                },
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please select a fish type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                child: CustomDropdown(
                  label: 'State',
                  value: controller.selectedState.value.label.obs,
                  items: WestBengalState.values
                      .map((state) => state.label)
                      .toList(),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      controller.selectedState.value = WestBengalState.values
                          .firstWhere((state) => state.label == value);
                    }
                  },
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a state';
                    }
                    return null;
                  },
                  searchable: true,
                ),
              ),
              SizedBox(height: 24),
              CustomInput(
                label: 'Price per Weight (₹)',
                controller: controller.priceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              CustomInput(
                label: 'Weight (Kg)',
                controller: controller.weightController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              CustomButton(
                onPressed: controller.addEntry,
                child: Text('Add Entry'),
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageEntriesTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.secondaryColor.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 200,
                child: CustomDropdown(
                  label: 'Filter by Fish Type',
                  value: (controller.filterFishType.value?.label ?? '').obs,
                  items: [...FishType.values.map((type) => type.label)],
                  onChanged: (value) {
                    controller.filterFishType.value = value.isEmpty
                        ? null
                        : FishType.values.firstWhere(
                            (type) => type.label == value,
                          );
                    controller.fetchEntries();
                  },
                ),
              ),
              SizedBox(width: 16),
              CustomButton(
                variant: ButtonVariant.secondary,
                onPressed: controller.selectDateRange,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, size: 20),
                    SizedBox(width: 8),
                    Obx(() {
                      if (controller.filterStartDate.value == null) {
                        return Text('Select Date Range');
                      }
                      return Text(
                        '${_formatDate(controller.filterStartDate.value!)} - '
                        '${_formatDate(controller.filterEndDate.value!)}',
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(width: 8),
              CustomButton(
                variant: ButtonVariant.outline,
                onPressed: controller.clearFilters,
                child: Text('Clear Filters'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              );
            }

            if (controller.entries.isEmpty) {
              return Center(
                child: Text(
                  'No entries found',
                  style: TextStyle(color: AppTheme.secondaryColor),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: controller.entries.length,
              itemBuilder: (context, index) {
                final entry = controller.entries[index];
                return CustomCard(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.fishType.label,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Price: \₹${entry.pricePerWeight.toStringAsFixed(2)} / kg',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              Text(
                                'Weight: ${entry.weight.toStringAsFixed(2)} kg',
                                style: TextStyle(
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Total: ₹${(entry.pricePerWeight * entry.weight).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CustomButton(
                                variant: ButtonVariant.secondary,
                                onPressed: () => _showEditDialog(entry),
                                child: Icon(Icons.edit_rounded),
                              ),
                              SizedBox(width: 8),
                              CustomButton(
                                variant: ButtonVariant.destructive,
                                onPressed: () => _showDeleteDialog(
                                  entry.id!,
                                  onDelete: () {
                                    controller.deleteEntry(entry.id!);
                                  },
                                ),
                                child: Icon(Icons.delete_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showEditDialog(FishEntry entry) {
    final priceCtrl = TextEditingController(
      text: entry.pricePerWeight.toString(),
    );
    final weightCtrl = TextEditingController(text: entry.weight.toString());
    final selectedType = entry.fishType.obs;
    final selectedState = entry.state.obs;
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 500,
          padding: EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Entry',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 24),
                CustomDropdown(
                  label: 'Fish Type',
                  value: selectedType.value.label.obs,
                  items: FishType.values.map((e) => e.label).toList(),
                  onChanged: (value) =>
                      selectedType.value = FishType.values.firstWhere(
                        (type) => type.label == value,
                        orElse: () => FishType.seaFish,
                      ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a fish type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                CustomDropdown(
                  label: 'State',
                  value: selectedState.value.label.obs,
                  items: WestBengalState.values.map((e) => e.label).toList(),
                  onChanged: (value) =>
                      selectedState.value = WestBengalState.values.firstWhere(
                        (state) => state.label == value,
                        orElse: () => WestBengalState.kolkata,
                      ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a state';
                    }
                    return null;
                  },
                  searchable: true,
                ),
                SizedBox(height: 24),
                CustomInput(
                  label: 'Price per Weight (₹)',
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter price';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                CustomInput(
                  label: 'Weight (Kg)',
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter weight';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      variant: ButtonVariant.outline,
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 16),
                    CustomButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final updatedEntry = FishEntry(
                            id: entry.id,
                            fishType: selectedType.value,
                            state: selectedState.value,
                            pricePerWeight: double.parse(priceCtrl.text),
                            weight: double.parse(weightCtrl.text),
                            createdAt: entry.createdAt,
                          );
                          controller.updateEntry(entry.id!, updatedEntry);
                          Get.back();
                        }
                      },
                      child: Text('Save Changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ));
    }
  }

  void _showDeleteDialog(String id, {void Function()? onDelete}) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          CustomButton(
            variant: ButtonVariant.secondary,
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          CustomButton(
            variant: ButtonVariant.destructive,
            onPressed: () {
              if (onDelete != null) onDelete();
              Get.back();
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
