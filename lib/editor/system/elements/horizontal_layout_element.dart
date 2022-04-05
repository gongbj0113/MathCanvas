import 'dart:math';
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:tuple/tuple.dart';
import '../element_system.dart';

class HorizontalLayoutElement extends ElementLayout {
  static const double padding = 5;

  HorizontalLayoutElement(double fontSize)
      : super(elementFontOption: ElementFontOption(size: fontSize));

  @override
  void addElement(int index, Element element) {
    childElements.insert(
      index,
      ChildrenElement(ChildrenElementType.necessary, children: element),
    );
  }

  @override
  void deleteElement(int index) {
    childElements.removeAt(index);
  }

  @override
  Tuple3<double, double, Point<double>> measureLayout() {
    double maxAnchorY = 0;
    double maxAfterAnchorY = 0;
    for (int i = 0; i < childElements.length; i++) {
      childElements[i].children!.layout();
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

    return Tuple3(curX - padding, maxAnchorY + maxAfterAnchorY, anchorPoint);
  }

  @override
  int requestCursorDown(int pos, CursorPosition cursorPosition) {
    return -1;
  }

  @override
  int requestCursorLeft(int pos, CursorPosition cursorPosition) {
    if (cursorPosition.index[pos] > 0) {
      return cursorPosition.index[pos] - 1;
    } else {
      return -1;
    }
  }

  @override
  int requestCursorRight(int pos, CursorPosition cursorPosition) {
    if (childElements.length > cursorPosition.index[pos]) {
      return cursorPosition.index[pos] + 1;
    } else {
      return -1;
    }
  }

  @override
  int requestCursorUp(int pos, CursorPosition cursorPosition) {
    return -1;
  }

  @override
  bool shouldMergeEndIndex() {
    return true;
  }

  @override
  bool shouldMergeStartIndex() {
    return true;
  }

  @override
  String toLatex() {
    return "";
  }
}
