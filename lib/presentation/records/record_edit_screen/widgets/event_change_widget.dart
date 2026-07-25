import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_search_view.dart';
import '../../../../widgets/second_variant_event_card.dart';

class EventChangeWidget extends StatelessWidget {
  final List<List<Widget>> contents;
  final String findHint;
  final String addHint;
  final TextEditingController searchController;
  final TextEditingController addController;
  final Function(String text, BuildContext context)? onSearch;
  final Function(String text)? onAdd;
  final String title;

   EventChangeWidget({Key? key, required this.findHint, required this.addHint, this.onSearch, this.onAdd, required this.searchController, required this.addController, required this.contents, required this.title}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final _focus = FocusNode();
    final _sFocus = FocusNode();
    final _changeToParts = 'change_to'.tr().split('{}');
    final _changeToBefore = _changeToParts[0];
    final _changeToAfter = _changeToParts.length > 1 ? _changeToParts[1].trimLeft() : '';
    return Container(
      margin: getMargin(
        top: 30,
      ),
      padding: getPadding(
        left: 6,
        top: 12,
        right: 6,
        bottom: 12,
      ),
      decoration:
      AppDecoration.outlineBluegray60014.copyWith(
        borderRadius: BorderRadiusStyle.customBorderBL3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle.txtSFProDisplayLight11Gray800
                .copyWith(
              letterSpacing: getHorizontalSize(
                0.44,
              ),
            ),
          ),
          Padding(
            padding: getPadding(
              top: 4,
            ),
            child: Row(
              children: [
                Padding(
                  padding: getPadding(
                    top: 3,
                  ),
                  child: Text(
                    _changeToBefore,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle
                        .txtSFProDisplayLight11Gray800
                        .copyWith(
                      letterSpacing: getHorizontalSize(
                        0.44,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getVerticalSize(17),
                  child: Wrap(
                    children: contents.map((e) => Padding(
                      padding: getPadding(right: 10),
                      child: SecondVariantEventCard(
                        content: e,
                      ),
                    )).toList(),
                  )
                ),
                Padding(
                  padding: getPadding(
                    left: 10,
                    top: 2,
                  ),
                  child: Text(
                    _changeToAfter,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle
                        .txtSFProDisplayLight11Gray800
                        .copyWith(
                      letterSpacing: getHorizontalSize(
                        0.44,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomSearchView(
            focusNode: _focus,
            controller: searchController,
            hintText: findHint,
            margin: getMargin(
              top: 29,
            ),
            onSubmit: (text) {
              _focus.unfocus();
              onSearch!(text, context);
            },
            suffix: Container(
              margin: getMargin(
                left: 30,
                top: 1,
                right: 9,
                bottom: 9,
              ),
              child: CustomImageView(
                svgPath: ImageConstant.imgSearch,
              ),
            ),
            suffixConstraints: BoxConstraints(
              maxHeight: getVerticalSize(
                26,
              ),
            ),
          ),
          CustomSearchView(
            focusNode: _sFocus,
            controller: addController,
            hintText: addHint,
            margin: getMargin(
              top: 26,
            ),
            onSubmit: (text) {
              _sFocus.unfocus();
              onAdd!(text);
            },
            suffix: Container(
            margin: getMargin(
            left: 30,
            top: 1,
            right: 9,
            bottom: 9,
          ),
          child: InkWell(
              onTap: () => onAdd!(addController.text),
              child: Icon(Icons.add))
          ),
            suffixConstraints: BoxConstraints(
              maxHeight: getVerticalSize(
                26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
