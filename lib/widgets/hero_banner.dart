import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/size_utils.dart';

/// A rounded picture header for a main screen: the image fills the card,
/// a soft dark layer keeps white text readable on any picture. Each main
/// screen gets its own picture so they are recognisable at a glance.
class HeroBanner extends StatelessWidget {
  final String asset;
  final Widget child;
  final double height;
  final Alignment imageAlignment;

  const HeroBanner({
    Key? key,
    required this.asset,
    required this.child,
    this.height = 124,
    this.imageAlignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: double.infinity,
        height: getVerticalSize(height),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(asset, fit: BoxFit.cover, alignment: imageAlignment),
            Container(color: const Color(0xFF061218).withOpacity(0.46)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: getHorizontalSize(18), vertical: getVerticalSize(14)),
              child: Align(alignment: Alignment.bottomLeft, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
