import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_style.dart';

class ChipOption<T> {
  final T value;
  final String label;

  const ChipOption({required this.value, required this.label});
}

class ChipSelector<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final T? selected;
  final ValueChanged<T> onSelected;

  const ChipSelector({
    Key? key,
    required this.options,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: getHorizontalSize(10),
      runSpacing: getVerticalSize(10),
      children: options.map((option) {
        final isSelected = option.value == selected;
        return GestureDetector(
          onTap: () => onSelected(option.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: getPadding(left: 16, right: 16, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? ColorConstant.deepPurple600 : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(getHorizontalSize(20)),
              border: Border.all(
                color: isSelected ? ColorConstant.deepPurple600 : ColorConstant.gray300,
                width: 1,
              ),
            ),
            child: Text(
              option.label,
              style: AppStyle.txtSFProDisplayLight14.copyWith(
                color: isSelected ? Colors.white : ColorConstant.gray800,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
