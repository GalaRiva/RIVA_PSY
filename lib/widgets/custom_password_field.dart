import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:riva_psy/core/app_export.dart';

import '../routes/app_routes.dart';
import '../../core/user_data/user.dart';
import 'custom_message_box.dart';

class CustomPasswordField {
   String? password;
   VoidCallback? onChange;
    TextEditingController? textEditingController;
   Function(String, String?) onSubmit;

  CustomPasswordField( {this.textEditingController, required this.onSubmit ,this.onChange, this.password = ''});
  var controller = TextEditingController();
  final focus = FocusNode();
  Widget widget(BuildContext context, Color color) {
    return Stack(
      children: [
        SizedBox(
          width: getVerticalSize(42 * 4),
          child: Column(
            children: [
              SizedBox(
                width: getVerticalSize( 42 * 4),
                height: 30,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                    itemCount: textEditingController?.text.length ?? controller.text.length,
                    itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(right: getVerticalSize(12)),
                          child: Container(
                            width: getVerticalSize(30),
                            height: 30,
                            child: Center(
                              child: Text(
                                '*',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )),
              ),
              SizedBox(
                height: 1,
                width: getVerticalSize(42 * 4),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(right: getVerticalSize(12)),
                          child: Container(
                            width: getVerticalSize(30),
                            height: 1,
                            color: color,
                          ),
                        )),
              ),
            ],
          ),
        ),
        Opacity(
          opacity: 0,
          child: SizedBox(
            height: 30,
            width: getVerticalSize(42 * 4),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: textEditingController ?? controller,
              focusNode: focus ,
              onChanged: (text) {
                if(text.length >= 4) {
                  onSubmit!(text, password);
                  focus.unfocus();
                  controller = TextEditingController();
                  if(textEditingController != null) textEditingController = TextEditingController();
                  text = '';
                }
                onChange!();
              },
              maxLength: 4,
            ),
          ),
        )
      ],
    );
  }
}
