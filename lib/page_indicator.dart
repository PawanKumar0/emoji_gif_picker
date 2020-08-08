import 'dart:math' show max;

import 'package:flutter/material.dart';

class PageIndicator extends AnimatedWidget {
  PageIndicator({
    this.controller,
    this.itemCount,
    this.onPageSelected,
    this.color: Colors.blueGrey,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  // The base size of the dots
  static const double _kDotSize = 24.0;

  // The increase in the size of the selected dot
  static const double _kMaxZoom = 1.3;

  // The distance between the center of each dot
  static const double _kDotSpacing = 36.0;

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(
        0.0,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (_kMaxZoom - 1.0) * selectedness;
    return new Container(
      // color: Colors.red,
      width: _kDotSpacing,
      child: new Container(
        width: _kDotSize * zoom,
        height: _kDotSize * zoom,
        child: new InkWell(
          onTap: () => onPageSelected(index),
          child: index == 0
              ? Icon(
                  Icons.insert_emoticon,
                  size: _kDotSize * zoom,
                  color: zoom == 1.3 ? color : null,
                )
              : index == 1
                  ? Icon(
                      Icons.gif,
                      size: _kDotSize * zoom * 1.2,
                      color: zoom == 1.3 ? color : null,
                    )
                  : Icon(
                      Icons.keyboard_voice,
                      size: _kDotSize * zoom,
                      color: zoom == 1.3 ? color : null,
                    ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
