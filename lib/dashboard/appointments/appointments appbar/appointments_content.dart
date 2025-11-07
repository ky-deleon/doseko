// APPOINTMENT_CONTENT

import 'package:doseko_checker/dashboard/appointments/appointments appbar/appointments_bg.dart';
import 'package:doseko_checker/dashboard/appointments/appointments appbar/appointments_text.dart';
import 'package:flutter/material.dart';

class ApptAppbarContentPage extends SliverPersistentHeaderDelegate {
  const ApptAppbarContentPage();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var adjustedShrinkOffset =
    shrinkOffset > minExtent ? minExtent : shrinkOffset;
    double offset = (minExtent - adjustedShrinkOffset) * 0.5;
    double topPadding = MediaQuery.of(context).padding.top + 16;

    return Stack(
      children: [
        const ApptAppbarBgPage(
          height: 360,
        ),
        Positioned(
          top: topPadding + offset,
          child: const ApptAppbarTextPage(),
          left: 16,
          right: 16,
        )
      ],
    );
  }

  @override
  double get maxExtent => 360;

  @override
  double get minExtent => 180;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
}