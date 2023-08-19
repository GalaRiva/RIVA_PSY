import 'package:flutter/services.dart';

class TextInputLoginFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    String newValueText = newValue.text.replaceAll('', '');

    if (oldValue != newValue) {
      int selectionIndex =
          newValue.text.length - newValue.selection.extentOffset;
      final chars = newValueText.split('');

      String newString = '';
      for (int i = 0; i < chars.length; i++) {
        newString +=chars[i];
        if (i == 0)
          newString = newString.toUpperCase();
      }

      return TextEditingValue(
        text: newString.toString(),
        selection: TextSelection.collapsed(
          offset: newString.length - selectionIndex,
        ),
      );
    }

    // If the new value and old value are the same, just return as-is
    return newValue;
  }
}
