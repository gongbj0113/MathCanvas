import 'dart:math';

import 'package:flutter/material.dart' show Colors, Canvas;
import '../element_system.dart';

class HorizontalLayoutElement extends Element {
  static const double padding = 5;

  HorizontalLayoutElement(double fontSize)
      : super(
          content: "",
          elementFontOption: ElementFontOption(fontSize, Colors.black),
          type: ElementType.layout,
        );

  void addElement(Element element) {
    childElements.add(
      ChildrenElement(element)
        ..type = ChildrenElementType.necessary
        ..anchor = ElementAnchor.none,
    );
    element.elementFontOption.size = elementFontOption.size;
  }

  @override
  void measureLayout() {
    double maxAnchorY = 0;
    double maxAfterAnchorY = 0;
    for (int i = 0; i < childElements.length; i++) {
      childElements[i].children!.measureLayout();
      if (childElements[i].children!.anchorPoint.y > maxAnchorY) {
        maxAnchorY = childElements[i].children!.anchorPoint.y;
      }
      if (childElements[i].children!.height -
              childElements[i].children!.anchorPoint.y >
          maxAfterAnchorY) {
        maxAfterAnchorY = childElements[i].children!.height -
            childElements[i].children!.anchorPoint.y;
      }
    }
    anchorPoint = Point(0.0, maxAnchorY);
    double curX = 0;
    for (int i = 0; i < childElements.length; i++) {
      childElements[i].position =
          Point(curX, maxAnchorY - childElements[i].children!.anchorPoint.y);
      curX += childElements[i].children!.width + padding;
    }

    width = curX - padding;
    height = maxAnchorY + maxAfterAnchorY;
  }
// TOdo : write toLatex Function
}
