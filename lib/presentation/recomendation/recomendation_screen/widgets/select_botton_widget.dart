import 'package:flutter/material.dart';
import 'glass_panel.dart';

import '../../../../../widgets/exercise_instruction_dialog.dart';

class SelectButtonWidget extends StatefulWidget {
  final String title;
  final String content;
  final double? height;
  final bool? isSelect;

  const SelectButtonWidget({Key? key, required this.title, required this.content, this.height, this.isSelect}) : super(key: key);

  @override
  State<SelectButtonWidget> createState() => _SelectButtonWState();
}

class _SelectButtonWState extends State<SelectButtonWidget> {
  bool opened = false;

  @override
  Widget build(BuildContext context) {
    return GlassChip(
        text: widget.title,
        pressed: opened,
        onTap: () {
        setState(() {
          opened = !opened;
        });
          showDialog(
              barrierColor: Colors.black.withOpacity(0.35),
              context: context,
              builder: (context) =>
                  ExerciseInstructionDialog(title: widget.title,
                    content: widget.content.split('.').join('.\n').split('?').join('.\n').split('!').join('.\n'),
                    )).then((value) {
            setState(() {
              opened = !opened;
            });
          });
        },
    );
  }
}
