import 'package:flutter/material.dart';
import 'package:riva_psy/widgets/custom_message_box.dart';

Future showMessage(BuildContext context,
    {required String title, required String content}) {
  return showDialog(
      context: context,
      builder: (context) => CustomMessageBox(title: title, content: content));
}
