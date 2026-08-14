import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_style.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

List<String> medicationSuggestions(String languageCode) {
  switch (languageCode) {
    case 'es':
      return const [
        'Vitamina D', 'Vitamina C', 'Magnesio', 'Omega-3', 'Zinc', 'Hierro',
        'Calcio', 'Multivitamínico', 'Probióticos', 'Colágeno', 'Vitamina B12',
        'Melatonina', 'Ácido fólico', 'Potasio',
      ];
    case 'en':
      return const [
        'Vitamin D', 'Vitamin C', 'Magnesium', 'Omega-3', 'Zinc', 'Iron',
        'Calcium', 'Multivitamin', 'Probiotics', 'Collagen', 'Vitamin B12',
        'Melatonin', 'Folic acid', 'Potassium',
      ];
    default:
      return const [
        'Витамин D', 'Витамин C', 'Магний', 'Омега-3', 'Цинк', 'Железо',
        'Кальций', 'Мультивитамины', 'Пробиотики', 'Коллаген', 'Витамин B12',
        'Мелатонин', 'Фолиевая кислота', 'Калий',
      ];
  }
}

class MedicationNameField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final String? hintText;
  final FormFieldValidator<String>? validator;

  const MedicationNameField({
    Key? key,
    required this.controller,
    required this.suggestions,
    this.hintText,
    this.validator,
  }) : super(key: key);

  @override
  State<MedicationNameField> createState() => _MedicationNameFieldState();
}

class _MedicationNameFieldState extends State<MedicationNameField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue value) {
        if (value.text.trim().isEmpty) return const Iterable<String>.empty();
        final query = value.text.toLowerCase();
        return widget.suggestions
            .where((s) => s.toLowerCase().contains(query))
            .take(6);
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return CustomTextFormField(
          height: 70,
          controller: textController,
          focusNode: focusNode,
          counterText: '',
          variant: TextFormFieldVariant.FillGray200,
          hintText: widget.hintText,
          validator: widget.validator,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(getHorizontalSize(3)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: getVerticalSize(220),
                minWidth: MediaQuery.of(context).size.width - 32,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: getPadding(left: 16, right: 16, top: 12, bottom: 12),
                      child: Text(
                        option,
                        style: AppStyle.txtSFProDisplayLight14
                            .copyWith(color: ColorConstant.gray800),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
