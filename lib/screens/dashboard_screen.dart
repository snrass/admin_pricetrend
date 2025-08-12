import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/button.dart';
import '../components/card.dart';
import '../components/dropdown.dart';
import '../components/input.dart';
import '../constants/enums.dart';
import '../controllers/dashboard_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final controller = Get.put(DashboardController());
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showLocationOverlay(BuildContext context) {
    // _removeOverlay();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Obx(() {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _removeOverlay,
                    child: Container(color: Colors.transparent),
                  ),
                ),
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: const Offset(0, 48), // height of search field
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        minWidth: 300, // Fixed minimum width for better UI
                        maxWidth:
                            400, // Maximum width to prevent too wide overlay
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: controller.availableLocations.isEmpty
                          ? Container(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.location_off, color: Colors.grey[400]),
                                  SizedBox(width: 12),
                                  Text(
                                    'No locations found',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: controller.availableLocations.length,
                              itemBuilder: (context, index) {
                                final location = controller.availableLocations[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  leading: Icon(
                                    location.type == 'harvesting'
                                        ? Icons.home_work
                                        : Icons.store,
                                    size: 18,
                                    color: location.type == 'harvesting'
                                        ? Colors.green[600]
                                        : Colors.blue[600],
                                  ),
                                  title: Text(
                                    location.name,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    controller.onSelectLocation(location);
                                    _removeOverlay();
                                    FocusScope.of(context).unfocus();
                                  },
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
    overlay.insert(_overlayEntry!);
  }

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
                  title: Text('Dashboard'),
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
                      Expanded(
                        child: CustomCard(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  tabs: [
                                    Tab(text: 'New Entry'),
                                    Tab(text: 'Manage Entries'),
                                  ],
                                  labelColor: AppTheme.primaryColor,
                                  unselectedLabelColor: AppTheme.secondaryColor,
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      _buildNewEntryTab(context),
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
                              'Dashboard',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 24),
                            Expanded(
                              child: CustomCard(
                                child: DefaultTabController(
                                  length: 2,
                                  child: Column(
                                    children: [
                                      TabBar(
                                        tabs: [
                                          Tab(text: 'New Entry'),
                                          Tab(text: 'Manage Entries'),
                                        ],
                                        labelColor: AppTheme.primaryColor,
                                        unselectedLabelColor:
                                            AppTheme.secondaryColor,
                                      ),
                                      Expanded(
                                        child: TabBarView(
                                          children: [
                                            _buildNewEntryTab(context),
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
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildNewEntryTab(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: controller.formKey,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date field at the top
              Obx(() => GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: controller.selectedDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        controller.selectedDate.value = picked;
                      }
                    },
                    child: AbsorbPointer(
                      child: CustomInput(
                        label: 'Date',
                        controller: TextEditingController(
                          text: controller.selectedDate.value
                              .toString()
                              .split(' ')[0],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a date';
                          }
                          return null;
                        },
                      ),
                    ),
                  )),
              SizedBox(height: 24),
              // Parent Fish Type dropdown
              Obx(() => CustomDropdown(
                    label: 'Fish Segment',
                    value: controller.selectedParentFishType.value?.label.obs,
                    items: ParentFishType.values.map((e) => e.label).toList(),
                    onChanged: (value) =>
                        controller.selectedParentFishType.value = ParentFishType
                            .values
                            .firstWhere((e) => e.label == value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select parent fish type';
                      }
                      return null;
                    },
                  )),
              SizedBox(height: 24),
              // Used For radio button
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Used For',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: UsedForType.values
                            .map((type) => Row(
                                  children: [
                                    Radio<UsedForType>(
                                      value: type,
                                      groupValue:
                                          controller.selectedUsedForType.value,
                                      onChanged: (val) => controller
                                          .selectedUsedForType.value = val,
                                    ),
                                    Text(type.label),
                                  ],
                                ))
                            .toList(),
                      ),
                    ],
                  )),
              SizedBox(height: 24),
              // Location field with dynamic label and search
              Obx(() => controller.selectedUsedForType.value ==
                          UsedForType.purchase ||
                      controller.selectedUsedForType.value == UsedForType.sell
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.selectedUsedForType.value ==
                                  UsedForType.purchase
                              ? 'Harvesting Point'
                              : controller.selectedUsedForType.value ==
                                      UsedForType.sell
                                  ? 'Market Location'
                                  : 'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => controller.selectedUsedForType.value ==
                                    UsedForType.purchase ||
                                controller.selectedUsedForType.value ==
                                    UsedForType.sell
                            ? CompositedTransformTarget(
                                link: _layerLink,
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      _showLocationOverlay(context);
                                    }
                                  },
                                  child: TextFormField(
                                    controller: controller.locationController,
                                    decoration: InputDecoration(
                                      hintText: controller
                                                  .selectedUsedForType.value ==
                                              UsedForType.purchase
                                          ? 'Search harvesting point...'
                                          : 'Search market location...',
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.grey[400]),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (controller.isSearching.value)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                              Color>(
                                                          AppTheme
                                                              .primaryColor),
                                                ),
                                              ),
                                            ),
                                          if (controller.locationController.text
                                              .isNotEmpty)
                                            IconButton(
                                              icon: Icon(Icons.clear,
                                                  color: Colors.grey[400]),
                                              onPressed: () {
                                                controller.locationController
                                                    .clear();
                                                controller.locationSearchQuery
                                                    .value = '';
                                                _removeOverlay();
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                            ),
                                        ],
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: AppTheme.primaryColor),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                    onChanged: (value) {
                                      controller.onLocationSearchChanged(value);
                                      if (value.isNotEmpty &&
                                          _overlayEntry == null) {
                                        _showLocationOverlay(context);
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a location';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
                    )
                  : const SizedBox.shrink()),
              SizedBox(height: 24),
              Obx(() => CustomDropdown(
                    label: 'Species Type',
                    value: controller.selectedSpeciesType.value?.obs,
                    items: controller.speciesTypes,
                    onChanged: (value) =>
                        controller.onSpeciesTypeChanged(value),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please select a species type';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 12,
                children: [
                  Expanded(
                    child: Obx(() => CustomDropdown(
                          label: 'Species',
                          value: controller.selectedSpecies.value?.obs,
                          items: controller.availableSpecies
                              .map(
                                  (species) => species['Common Name'] as String)
                              .toSet() // Convert to Set to remove duplicates
                              .toList(),
                          // Convert back to List
                          onChanged: (value) =>
                              controller.onSpeciesChanged(value),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please select a species';
                            }
                            return null;
                          },
                          enabled: controller.selectedSpeciesType.value != null,
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(
                        () => IconButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.addPriceEntry,
                          icon: controller.isSubmitting.value
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              : Icon(Icons.add, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Obx(() {
                return CustomDropdown(
                  label: 'Size/Grade',
                  value: controller.selectedSizeGrade.value?.obs,
                  items: controller.availableSizeGrades
                      .map((grade) => grade['size'] as String?)
                      .toList()
                      .whereType<String>()
                      .toList(),
                  onChanged: (value) =>
                      controller.selectedSizeGrade.value = value,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please select a size/grade';
                    }
                    return null;
                  },
                  enabled: controller.selectedSpecies.value != null,
                );
              }),
              const SizedBox(height: 24),
              CustomDropdown(
                label: 'State',
                value: controller.selectedState.value.label.obs,
                items: WestBengalState.values.map((e) => e.label).toList(),
                onChanged: (value) => controller.selectedState.value =
                    WestBengalState.values.firstWhere(
                  (state) => state.label == value,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please select a state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomInput(
                label: 'Price (₹)',
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
              const SizedBox(height: 32),
              Obx(() => CustomButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.addPriceEntry,
                    width: double.infinity,
                    child: controller.isSubmitting.value
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Adding Entry...'),
                            ],
                          )
                        : const Text('Add Entry'),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManageEntriesTab() {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.speciesName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${entry.speciesType} • ${entry.sizeGrade}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color:
                                    entry.parentFishType == ParentFishType.live
                                        ? Colors.green[50]
                                        : Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: entry.parentFishType ==
                                          ParentFishType.live
                                      ? Colors.green[300]!
                                      : Colors.blue[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                entry.parentFishType.label,
                                style: TextStyle(
                                  color: entry.parentFishType ==
                                          ParentFishType.live
                                      ? Colors.green[700]
                                      : Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red[300]),
                              onPressed: () => _showDeleteDialog(entry.id!),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildInfoChip(
                              Icons.currency_rupee,
                              '${entry.price}',
                              Colors.green,
                            ),
                            _buildInfoChip(
                              Icons.location_on_outlined,
                              entry.location,
                              Colors.blue,
                            ),
                            _buildInfoChip(
                              Icons.business_outlined,
                              entry.state,
                              Colors.orange,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: entry.usedForType == UsedForType.purchase
                                    ? Colors.purple[50]
                                    : Colors.amber[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.usedForType.label,
                                style: TextStyle(
                                  color:
                                      entry.usedForType == UsedForType.purchase
                                          ? Colors.purple[700]
                                          : Colors.amber[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatDate(entry.date),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showDeleteDialog(String id) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteEntry(id);
              Get.back();
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoChip(IconData icon, String label, MaterialColor color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color[700]),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
