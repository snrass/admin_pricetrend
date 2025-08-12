import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final RxString? value;
  final List<String> items;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final bool searchable;

  final bool enabled;

  const CustomDropdown({
    Key? key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.searchable = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: AppTheme.borderRadius,
            border: Border.all(
              color: AppTheme.secondaryColor.withOpacity(0.2),
            ),
          ),
          child: searchable
              ? _buildSearchableDropdown(context)
              : _buildSimpleDropdown(),
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown() {
    return DropdownButtonFormField<String>(
      value:
          value == null || (value?.value.isEmpty == true) ? null : value?.value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 16,
                  ),
                ),
              ))
          .toList(),
      onChanged: (val) => onChanged(val ?? ''),
      validator: validator,
      decoration: InputDecoration(
        enabled: enabled,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppTheme.secondaryColor,
      ),
      dropdownColor: AppTheme.surfaceColor,
      isExpanded: true,
    );
  }

  Widget _buildSearchableDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      enabled: enabled,
      initialValue:
          value == null || (value?.value.isEmpty == true) ? null : value?.value,
      onSelected: (val) {
        onChanged(val);
        value?.value = val; // Update the value immediately
      },
      position: PopupMenuPosition.under,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.3,
        maxWidth: MediaQuery.of(context).size.width * 0.5,
        maxHeight: 300,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null || (value?.value.isEmpty == true)
                    ? 'Select ${label.toLowerCase()}'
                    : value!.value,
                style: TextStyle(
                  color: value == null || (value?.value.isEmpty == true)
                      ? AppTheme.secondaryColor
                      : AppTheme.primaryColor,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.secondaryColor,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          height: 48,
          child: SearchField(
            items: items,
            onSelected: (val) {
              onChanged(val);
              value?.value = val; // Update the value immediately
              Navigator.pop(context); // Close the dropdown
            },
          ),
        ),
        ...items.map((item) => PopupMenuItem(
              value: item,
              height: 40,
              child: Text(
                item,
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            )),
      ],
    );
  }
}

class SearchField extends StatefulWidget {
  final List<String> items;
  final Function(String) onSelected;

  const SearchField({
    Key? key,
    required this.items,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  final filteredItems = RxList<String>([]);

  @override
  void initState() {
    super.initState();
    filteredItems.value = widget.items;

    controller.addListener(() {
      final query = controller.text.toLowerCase();
      filteredItems.value = widget.items
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: 'Search...',
        border: OutlineInputBorder(
          borderRadius: AppTheme.borderRadius,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (value) {
        if (filteredItems.isNotEmpty) {
          widget.onSelected(filteredItems.first);
          Navigator.pop(context);
        }
      },
    );
  }
}
