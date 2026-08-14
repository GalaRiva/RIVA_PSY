import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_icons.dart';

const List<String> medicationIconTypes = ['capsule', 'tablet', 'drops', 'spray'];

const List<Color> medicationColorPalette = [
  Color(0xFF30D5C8),
  Color(0xFF8E24AA),
  Color(0xFFFFA726),
  Color(0xFF66BB6A),
  Color(0xFFEF5350),
  Color(0xFF42A5F5),
  Color(0xFFFFD54F),
];

IconData medicationIconForType(String type) {
  switch (type) {
    case 'tablet':
      return AppIcons.pillTablet;
    case 'drops':
      return AppIcons.pillDrops;
    case 'spray':
      return AppIcons.pillSpray;
    default:
      return AppIcons.pillCapsule;
  }
}

class MedicationIconColorPicker extends StatelessWidget {
  final String selectedIconType;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;
  final ValueChanged<Color> onColorSelected;

  const MedicationIconColorPicker({
    Key? key,
    required this.selectedIconType,
    required this.selectedColor,
    required this.onIconSelected,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: medicationIconTypes.map((type) {
            final isSelected = type == selectedIconType;
            return Padding(
              padding: getPadding(right: 14),
              child: GestureDetector(
                onTap: () => onIconSelected(type),
                child: Container(
                  width: getHorizontalSize(48),
                  height: getHorizontalSize(48),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? selectedColor : selectedColor.withOpacity(0.15),
                    border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                  ),
                  child: Icon(
                    medicationIconForType(type),
                    color: isSelected ? Colors.white : selectedColor,
                    size: getHorizontalSize(24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: getVerticalSize(16)),
        Row(
          children: medicationColorPalette.map((color) {
            final isSelected = color.value == selectedColor.value;
            return Padding(
              padding: getPadding(right: 12),
              child: GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  width: getHorizontalSize(28),
                  height: getHorizontalSize(28),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: isSelected ? Border.all(color: Colors.black87, width: 2) : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
