import 'dart:math';
import 'package:flutter/material.dart';
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:tuple/tuple.dart';

enum ElementType { symbol, bigOperation, accent, layout }

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

  ElementFontOption({this.size = 18, this.color = Colors.black});
}

class ChildrenElement {
  ChildrenElement(this.type, {this.anchor = ElementAnchor.none, this.children});

  Element? children;
  ElementAnchor anchor;
  ChildrenElementType type;

  late Point<double> position;

  Point<double> calculateRelativePosition(double mx, double my) {
    assert(children != null);
    late Point<double> relativePosition;
    if (anchor == ElementAnchor.cornerRightTop) {
      relativePosition = Point(mx, -my / 2 - children!.height);
    } else if (anchor == ElementAnchor.cornerRightBottom) {
      relativePosition = Point(mx, my / 2);
    } else if (anchor == ElementAnchor.cornerLeftTop) {
      relativePosition = Point(-children!.width, -my / 2 - children!.height);
    } else if (anchor == ElementAnchor.cornerLeftBottom) {
      relativePosition = Point(-children!.width, my / 2);
    } else if (anchor == ElementAnchor.topMiddle) {
      relativePosition =
          Point(mx / 2 - children!.width / 2, -my / 2 - children!.height);
    } else if (anchor == ElementAnchor.rightMiddle) {
      relativePosition = Point(mx, -children!.height / 2);
    } else if (anchor == ElementAnchor.bottomMiddle) {
      relativePosition = Point(mx / 2 - children!.width / 2, my / 2);
    } else if (anchor == ElementAnchor.leftMiddle) {
      relativePosition = Point(-children!.width, -children!.height / 2);
    } else if (anchor == ElementAnchor.topRight) {
      var ry = -my / 2 - children!.height;
      var rx = min(mx - children!.width, mx / 2);
      relativePosition = Point(rx, ry);
    } else if (anchor == ElementAnchor.topLeft) {
      var ry = -my / 2 - children!.height;
      var rx = max(0.0, mx / 2 - children!.width);
      relativePosition = Point(rx, ry);
    } else if (anchor == ElementAnchor.bottomRight) {
      var ry = my / 2;
      var rx = min(mx - children!.width, mx / 2);
      relativePosition = Point(rx, ry);
    } else if (anchor == ElementAnchor.bottomLeft) {
      var ry = my / 2;
      var rx = max(0.0, mx / 2 - children!.width);
      relativePosition = Point(rx, ry);
    } else if (anchor == ElementAnchor.rightTop) {
      var rx = mx;
      var ry = -my / 2 + min(0.0, my / 2 - children!.height);
      relativePosition = Point(rx, ry);
    } else if (anchor == ElementAnchor.rightBottom) {
      var rx = mx;
      var ry = my / 2 - min(children!.height, my / 2);
      relativePosition = Point(rx, ry);
    } else if (anchor == ElementAnchor.leftTop) {
      var rx = -children!.width;
      var ry = -my / 2 + min(0.0, my / 2 - children!.height);
      relativePosition = Point(rx, ry);
    } else if (anchor == ElementAnchor.leftBottom) {
      var rx = -children!.width;
      var ry = my / 2 - min(children!.height, my / 2);
      relativePosition = Point(rx, ry);
    }
    return relativePosition;
  }
}

class ElementSymbol extends Element {
  ElementSymbol(
      {required this.content, required ElementFontOption elementFontOption})
      : super(type: ElementType.symbol, elementFontOption: elementFontOption);

  String content;

  @override
  Tuple3<double, double, Point<double>> measureLayout() {
    var span = TextSpan(
      text: content,
      style: TextStyle(
        color: elementFontOption.color,
        fontSize: elementFontOption.size,
      ),
    ); //TOdo : apply the font family of math style.
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();

    return Tuple3(tp.width, tp.height, Point(0.0, tp.height / 2));
  }

  @override
  void render(Canvas canvas) {
    TextPainter tp = TextPainter(
      text: TextSpan(
        text: content,
        style: TextStyle(
          fontSize: elementFontOption.size,
          color: elementFontOption.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    ); //TOdo : apply the font family of math style.
    tp.layout();
    tp.paint(canvas, const Offset(0, 0));
  }

  @override
  String toLatex() {
    return "";
  }
}

class ElementBigOperation extends Element {
  ElementBigOperation({
    required this.content,
    required ElementFontOption elementFontOption,
    this.childElements = const [],
  }) : super(
            elementFontOption: elementFontOption,
            type: ElementType.bigOperation);

  String content;
  final List<ChildrenElement> childElements;

  @override
  Tuple3<double, double, Point<double>> measureLayout() {
    var span = TextSpan(
      text: content,
      style: TextStyle(
          color: elementFontOption.color, fontSize: elementFontOption.size * 2),
    ); //TOdo : apply the font family of math style.
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    double mx = tp.width;
    double my = tp.height;
    var relPos = <Point<double>>[];
    var relXMin = 0.0;
    var relYMin = 0.0;
    var relXMax = 0.0;
    var relYMax = 0.0;
    for (int i = 0; i < childElements.length; i++) {
      if (childElements[i].children == null) {
        continue;
        //Todo : write code for rendering optional indicator box.
      }
      childElements[i].children!.measureLayout();
      var relativePoint = childElements[i].calculateRelativePosition(mx, my);
      relPos.add(relativePoint);
      if (relativePoint.x < relXMin) relXMin = relativePoint.x;
      if (relativePoint.y < relYMin) relYMin = relativePoint.y;
      if (relativePoint.x + childElements[i].children!.width > relXMax) {
        relXMax = relativePoint.x + childElements[i].children!.width;
      }
      if (relativePoint.y + childElements[i].children!.height > relYMax) {
        relYMax = relativePoint.y + childElements[i].children!.height;
      }
    }

    var origX = relXMin < 0 ? relXMin : 0.0;
    var origY = relYMin < 0 ? relYMin : 0.0;
    anchorPoint = Point(0.0 - origX, my / 2 - origY);
    for (int i = 0; i < childElements.length; i++) {
      if (childElements[i].children == null) {
        continue; //Todo : write code for rendering optional indicator box.
      }
      childElements[i].position =
          Point(relPos[i].x - origX, relPos[i].y - origY);
    }

    return Tuple3(
      max(anchorPoint.x + width, relXMax - origX),
      max(anchorPoint.y + height / 2, relYMax - origY),
      Point(0.0 - origX, my / 2 - origY),
    );
  }

  @override
  void render(Canvas canvas) {
    TextPainter tp = TextPainter(
      text: TextSpan(text: content),
      textDirection: TextDirection.ltr,
    ); //TOdo : apply the font family of math style.
    tp.layout();
    tp.paint(
        canvas, Offset(anchorPoint.x, anchorPoint.y - elementFontOption.size));
    for (int i = 0; i < childElements.length; i++) {
      if (childElements[i].children == null) {
        continue; //Todo : write code for rendering optional indicator box.
      }
      canvas.save();
      canvas.translate(
          childElements[i].position.x, childElements[i].position.y);
      childElements[i].children!.render(canvas);
      canvas.restore();
    }
  }

  @override
  String toLatex() {
    return "";
  }
}

abstract class ElementLayout extends Element {
  ElementLayout({required ElementFontOption elementFontOption})
      : super(elementFontOption: elementFontOption, type: ElementType.layout);

  var childElements = <ChildrenElement>[];

  @override
  void render(Canvas canvas) {
    for (int i = 0; i < childElements.length; i++) {
      //canvas.save();
      //canvas.translate(
      //    childElements[i].position.x, childElements[i].position.y);
      childElements[i].children!.render(canvas);
      //canvas.restore();
    }
  }

  @override
  String toLatex();

  void addElement(int index, Element element);

  void deleteElement(int index);

  Offset getAnchorPosition(int index);

  // returns -1 if there's no where to go. then, the program should find parent elementlayout.
  int requestCursorRight(int pos, CursorPosition cursorPosition);

  int requestCursorLeft(int pos, CursorPosition cursorPosition);

  int requestCursorUp(int pos, CursorPosition cursorPosition);

  int requestCursorDown(int pos, CursorPosition cursorPosition);

  // returns whether it should merge first or end index with parent horizontal layout.
  bool shouldMergeStartIndex();

  bool shouldMergeEndIndex();
}

//TOdo : Write Accent Element
/*
class ElementAccent extends Element {
  ElementAccent({required this.content, required this.elementFontOption})
      : super(type: ElementType.accent, elementFontOption: elementFontOption);

  Element content;
  ElementFontOption elementFontOption;
  var childElements = <ChildrenElement>[];

  late double width;
  late double height;
  late Point<double> anchorPoint;

  void measureLayout() {
    var span = TextSpan(
      text: content,
      style: TextStyle(
          color: elementFontOption.color,
          fontSize: type == ElementType.bigOperation
              ? elementFontOption.size * 2
              : elementFontOption.size),
    ); //TOdo : apply the font family of math style.
    TextPainter tp = TextPainter(text: span, textAlign: TextAlign.left);
    tp.layout();
    double mx = tp.width;
    double my = tp.height;
    var relPos = <Point<double>>[];
    var relXMin = 0.0;
    var relYMin = 0.0;
    var relXMax = 0.0;
    var relYMax = 0.0;
    for (int i = 0; i < childElements.length; i++) {
      if (childElements[i].children == null) {
        continue;
        //Todo : write code for rendering optional indicator box.
      }
      childElements[i].children!.measureLayout();
      var relativePoint = childElements[i].calculateRelativePosition(mx, my);
      relPos.add(relativePoint);
      if (relativePoint.x < relXMin) relXMin = relativePoint.x;
      if (relativePoint.y < relYMin) relYMin = relativePoint.y;
      if (relativePoint.x + childElements[i].children!.width > relXMax) {
        relXMax = relativePoint.x + childElements[i].children!.width;
      }
      if (relativePoint.y + childElements[i].children!.height > relYMax) {
        relYMax = relativePoint.y + childElements[i].children!.height;
      }
    }

    var origX = relXMin < 0 ? relXMin : 0.0;
    var origY = relYMin < 0 ? relYMin : 0.0;
    anchorPoint = Point(0.0 - origX, my / 2 - origY);
    for (int i = 0; i < childElements.length; i++) {
      if (childElements[i].children == null) {
        continue; //Todo : write code for rendering optional indicator box.
      }
      childElements[i].position =
          Point(relPos[i].x - origX, relPos[i].y - origY);
    }
    width = max(anchorPoint.x + width, relXMax - origX);
    height = max(anchorPoint.y + height / 2, relYMax - origY);
  }

  void render(Canvas canvas) {
    TextPainter tp = TextPainter(
        text: TextSpan(text: content),
        textAlign:
            TextAlign.left); //TOdo : apply the font family of math style.
    tp.layout();
    tp.paint(canvas, Offset(anchorPoint.x, anchorPoint.y));
    for (int i = 0; i < childElements.length; i++) {
      if (childElements[i].children == null) {
        continue; //Todo : write code for rendering optional indicator box.
      }
      canvas.save();
      canvas.translate(
          childElements[i].position.x, childElements[i].position.y);
      childElements[i].children!.render(canvas);
      canvas.restore();
    }
  }

  String toLatex() {
    return "";
  }
}*/

abstract class Element {
  Element({required this.type, required this.elementFontOption});

  final ElementType type;
  ElementFontOption elementFontOption;

  late double width;
  late double height;
  late Point<double> anchorPoint;

  void layout() {
    Tuple3<double, double, Point<double>> result = measureLayout();
    width = result.item1;
    height = result.item2;
    anchorPoint = result.item3;
  }

  Tuple3<double, double, Point<double>> measureLayout();

  void render(Canvas canvas);

  String toLatex();
}
