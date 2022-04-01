import 'package:flutter/material.dart' show Colors;

import '../element_system.dart';

class TextSymbolElement extends Element {
  TextSymbolElement(String text, {double fontSize = 10})
      : super(
          content: text,
          elementFontOption: ElementFontOption(fontSize, Colors.black),
          type: ElementType.basic,
        ) {
    childElements.add(
      ChildrenElement(null)
        ..type = ChildrenElementType.optional
        ..anchor = ElementAnchor.cornerRightTop,
    );
    childElements.add(
      ChildrenElement(null)
        ..type = ChildrenElementType.optional
        ..anchor = ElementAnchor.cornerRightBottom,
    );
  }

}
