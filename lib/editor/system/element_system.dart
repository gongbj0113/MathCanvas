import 'dart:math';
import 'dart:ui';

enum ElementType { basic, bigOperation, accent, layout }

enum ElementAnchor {
  cornerLeftTop,
  cornerLeftBottom,
  cornerRightTop,
  cornerRightBottom,
  leftTop,
  leftMiddle,
  leftBottom,
  topLeft,
  topMiddle,
  topRight,
  rightTop,
  rightMiddle,
  rightBottom,
  bottomLeft,
  bottomMiddle,
  bottomRight,
  none
}

enum ChildrenElementType { necessary, optional }

class ElementFontOption {
  double size;
  Color color;

  ElementFontOption(this.size, this.color);
}

class ChildrenElement {
  late Element children;
  ElementAnchor anchor = ElementAnchor.none;
  late Point position;
  ChildrenElementType type = ChildrenElementType.optional;
}

class Element {
  ElementType type = ElementType.basic;
  late String content;
  late ElementFontOption elementFontOption;
  var childElements = <ChildrenElement>[];
  late double width;
  late double height;
  late Point anchorPoint;

  void measureLayout() {}

  void render(Canvas canvas) {

  }
}
