import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import 'drop_text_model.dart';
import '../../../theme/app_icons.dart';

class DropTextWidget extends StatefulWidget {
  final DropTextModel model;

  const DropTextWidget({Key? key, required this.model}) : super(key: key);

  @override
  State<DropTextWidget> createState() => _DropTextWidgetState();
}

class _DropTextWidgetState extends State<DropTextWidget>
    with TickerProviderStateMixin {
  late AnimationController fadeController;
  late AnimationController slideController;
  late Animation<Offset> slideAnimation;

  bool wasTapped = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fadeController =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: const Offset(0, 0.0),
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if(wasTapped) {
                fadeController.reverse();
              slideController.reverse();
                wasTapped = !wasTapped;

              } else {
                fadeController.forward();
              slideController.forward();
                wasTapped = !wasTapped;

              }
            });

          },
          child: SizedBox(
          width: size.width - 40, child: Row(
            children: [
                   Flexible(
                     child: Text(widget.model.title.toUpperCase(),
                        textAlign: TextAlign.left,
                        style: AppStyle.txtSFProDisplayLight16),
                   ),
              SizedBox(
                width: 10,
              ),
              Icon(
                wasTapped ? AppIcons.caretUp : AppIcons.caretDown,
              )
            ],
          )),
        ),
        SizedBox(
          height: 10,
        ),
        Visibility(
          visible: wasTapped,
          child: FadeTransition(
            opacity: fadeController,
            child: SlideTransition(
              position: slideAnimation,
              child: Wrap(
                spacing: 10,
                direction: Axis.vertical,
                children: widget.model.contents is List<String>
                    ? (widget.model.contents as List<String>)
                        .map((e) => textWidget(e))
                        .toList()
                    : (widget.model.contents as List<DropTextModel>)
                        .map((e) => DropTextWidget(model: e))
                        .toList(),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget textWidget(String text) {
    return SizedBox(
      width: size.width - 60,
      child: Text(text,
          textAlign: TextAlign.left,
          style: AppStyle.txtSFProDisplayLight10Gray8001),
    );
  }
}
