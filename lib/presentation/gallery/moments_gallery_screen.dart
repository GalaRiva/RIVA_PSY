import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/presentation/main/path/path_final_screen/repository.dart';
import 'package:riva_psy/widgets/custom_app_bar.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_pop_button.dart';
import 'package:riva_psy/widgets/emotion_color_blob.dart';
import '../../theme/app_colors.dart';

class MomentsGalleryScreen extends StatefulWidget {
  const MomentsGalleryScreen({Key? key}) : super(key: key);

  @override
  State<MomentsGalleryScreen> createState() => _MomentsGalleryScreenState();
}

class _MomentsGalleryScreenState extends State<MomentsGalleryScreen> {
  List<DayEventModel>? _moments;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final events = await K39Repo().getEvent();
    final positive = events.where((e) => e.emotionInDayEvent == EmotionInDayEvent.POSITIVE).toList();
    positive.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    if (mounted) setState(() => _moments = positive);
  }

  @override
  Widget build(BuildContext context) {
    final moments = _moments;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: getPadding(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: getPadding(top: 39),
                  child: CustomAppBar(widget: CustomPopButton(text: 'records_title'.tr())),
                ),
                Padding(
                  padding: getPadding(top: 25),
                  child: Text('moments_gallery_title'.tr(), style: AppStyle.txtH1),
                ),
                if (moments != null)
                  Padding(
                    padding: getPadding(top: 10),
                    child: Text(
                      'moments_gallery_subtitle'.tr(namedArgs: {'count': '${moments.length}'}),
                      style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800),
                    ),
                  ),
                SizedBox(height: getVerticalSize(24)),
                if (moments == null)
                  Center(
                    child: Padding(
                      padding: getPadding(top: 60),
                      child: CircularProgressIndicator(color: ColorConstant.cyan700),
                    ),
                  )
                else if (moments.isEmpty)
                  Padding(
                    padding: getPadding(top: 20),
                    child: Text(
                      'moments_gallery_empty'.tr(),
                      style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800),
                    ),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: moments.map((moment) => _MomentSticker(
                          moment: moment,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.record_edit, arguments: moment)
                              .then((_) => _load()),
                        )).toList(),
                  ),
                SizedBox(height: getVerticalSize(90)),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(onChanged: (BottomBarEnum type) {}),
    );
  }
}

class _MomentSticker extends StatelessWidget {
  final DayEventModel moment;
  final VoidCallback onTap;

  const _MomentSticker({required this.moment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final emotion = (moment.whatEmotion ?? []).isNotEmpty ? moment.whatEmotion!.first : null;
    final color = emotion != null
        ? emotionBlobColor(emotion.identity, EmotionMood.positive)
        : const Color(0xFFFFC98B);
    final date = moment.date;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(getHorizontalSize(16)),
      child: Container(
        width: (size.width - 44) / 2,
        padding: getPadding(all: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(getHorizontalSize(16)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: getHorizontalSize(36),
              height: getHorizontalSize(36),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 16, spreadRadius: 2),
                ],
              ),
            ),
            SizedBox(height: getVerticalSize(10)),
            Text(
              emotion?.localizedName ?? 'normal'.tr(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w500),
            ),
            if (date != null)
              Padding(
                padding: getPadding(top: 4),
                child: Text(
                  '${date.day} ${date.month.monthInText()}',
                  style: AppStyle.txtSFProDisplayLight11.copyWith(color: ColorConstant.gray800),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
