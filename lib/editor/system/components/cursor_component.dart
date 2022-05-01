import 'package:flutter/painting.dart';
import 'package:math_canvas/editor/system/element_system.dart';
import 'package:math_canvas/editor/system/elements/horizontal_layout_element.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart'
    show
        Animation,
        AnimationController,
        BuildContext,
        Color,
        Colors,
        Container,
        CurveTween,
        Curves,
        Key,
        Offset,
        Opacity,
        ShapeDecoration,
        SingleTickerProviderStateMixin,
        StadiumBorder,
        State,
        StatefulWidget,
        Transform,
        Widget;
import '../canvas_data.dart';

class CursorPosition {
  CursorPosition(this.rootEquation, this.index);

  MathCanvasEquationData rootEquation;
  List<int> index;

  Offset getLocalPosition() {
    ElementLayout parent = rootEquation.rootElement as ElementLayout;
    double localX = rootEquation.localX;
    double localY = rootEquation.localY;

    for (int i = 0; i < index.length - 1; i++) {
      localX += parent.childElements[index[i]].position.x;
      localY += parent.childElements[index[i]].position.y;
      parent = parent.childElements[index[i]].children! as ElementLayout;
    }
    var lastOffset = parent.getAnchorPosition(index.last);

    return Offset(localX + lastOffset.dx, localY + lastOffset.dy);
  }

  double getFontSize() {
    ElementLayout parent = rootEquation.rootElement as ElementLayout;
    for (int i = 0; i < index.length - 1; i++) {
      parent = parent.childElements[index[i]].children! as ElementLayout;
    }

    return parent.elementFontOption.size;
  }

  ElementLayout getLastElementLayout() {
    ElementLayout parent = rootEquation.rootElement as ElementLayout;
    for (int i = 0; i < index.length - 1; i++) {
      parent = parent.childElements[index[i]].children! as ElementLayout;
    }
    return parent;
  }

  Element? getElement() {
    ElementLayout parent = rootEquation.rootElement as ElementLayout;
    for (int i = 0; i < index.length - 1; i++) {
      parent = parent.childElements[index[i]].children! as ElementLayout;
    }
    if (index.length == parent.childElements.length) {
      return null;
    } else {
      return parent.childElements[index.last].children;
    }
  }

  CursorPosition copy() {
    return CursorPosition(rootEquation, index.map<int>((e) => e).toList());
  }

  CursorPosition popIndex() {
    return copy()..index.removeLast();
  }

  @override
  bool operator ==(Object other) {
    if (other is CursorPosition) {
      return other.rootEquation == rootEquation &&
          const ListEquality().equals(other.index, index);
    } else {
      return super == other;
    }
  }
}

enum CursorStatus { unfocused, focused, selection }

class ComponentCursor extends EventSystemComponent {
  CursorStatus _status = CursorStatus.unfocused;

  CursorStatus get status => _status;

  CursorWidget? _cursorWidget;
  int? _cursorWidgetId;
  CursorPosition? pos;

  CursorPosition? start;
  CursorPosition? end;

  void focusTo(CursorPosition pos) {
    if (_status == CursorStatus.focused) {
      this.pos = pos;
      mathCanvasData.editorData.updateWidgetForeground(
        _cursorWidgetId!,
        _cursorWidget!,
        pos.getLocalPosition(),
        local: true,
      );
      mathCanvasData.editorData.finishDataChange();
    } else {
      _status = CursorStatus.focused;
      _cursorWidget = CursorWidget(fontSize: pos.getFontSize());
      _cursorWidgetId = mathCanvasData.editorData.attachWidgetForeground(
        _cursorWidget!,
        pos.getLocalPosition(),
        local: true,
      );
      this.pos = pos;
    }
  }

  void unFocus() {
    if (status == CursorStatus.focused) {
      _status = CursorStatus.unfocused;
      mathCanvasData.editorData.detachWidgetForeground(_cursorWidgetId!);
    } else if (status == CursorStatus.selection) {
      //TOdo : write selection code.
    }
  }

  bool _containsPoint(
      Offset point, double x, double y, double width, double height) {
    return (x < point.dx && point.dx < x + width) &&
        (y < point.dy && point.dy < y + height);
  }

  CursorPosition? findNearCursorPosition(Offset localPosition) {
    for (int i = 0; i < mathCanvasData.equationData.length; i++) {
      if (mathCanvasData.equationData[i].isPointContained(localPosition)) {
        print("START equationData : $i");
        List<int> pos = [];
        double curX = mathCanvasData.equationData[i].localX;
        double curY = mathCanvasData.equationData[i].localY;

        Element parent = mathCanvasData.equationData[i].rootElement;
        while (parent is ElementLayout) {
          if (parent is HorizontalLayoutElement) {
            double innerX = localPosition.dx - curX;
            var horizontalParent = parent;
            bool finded = false;
            for (int j = 0; j < horizontalParent.childElements.length; j++) {
              if (innerX <
                  horizontalParent.childElements[j].position.x +
                      horizontalParent.childElements[j].children!.width / 2) {
                finded = true;
                if (horizontalParent.childElements[j].position.x < innerX &&
                    innerX <
                        horizontalParent.childElements[j].position.x +
                            horizontalParent.childElements[j].children!.width) {
                  pos.add(j);
                  print("add : $j");
                  curX += horizontalParent.childElements[j].position.x;
                  curY += horizontalParent.childElements[j].position.y;
                  parent = horizontalParent.childElements[j].children!;
                } else if (horizontalParent.childElements[j - 1].position.x <
                        innerX &&
                    innerX <
                        horizontalParent.childElements[j - 1].position.x +
                            horizontalParent
                                .childElements[j - 1].children!.width) {
                  if (horizontalParent.childElements[j - 1].children!
                      is ElementLayout) {
                    print("add : ${j - 1}");
                    pos.add(j - 1);
                    curX += horizontalParent.childElements[j - 1].position.x;
                    curY += horizontalParent.childElements[j - 1].position.y;
                    parent = horizontalParent.childElements[j - 1].children!;
                  } else {
                    print("add : $j");
                    pos.add(j);
                    parent = horizontalParent.childElements[j - 1].children!;
                  }
                } else {
                  print("add : $j");
                  pos.add(j);
                  return CursorPosition(mathCanvasData.equationData[i], pos);
                }
                break;
              }
            }
            if (!finded) {
              print("add : ${horizontalParent.childElements.length}");
              pos.add(horizontalParent.childElements.length);
              return CursorPosition(mathCanvasData.equationData[i], pos);
            }
          } else {
            int inPos = -1;
            for (int j = 0; j < parent.childElements.length; j++) {
              if (parent.childElements[j].children != null) {
                if (_containsPoint(
                    localPosition,
                    parent.childElements[j].position.x + curX,
                    parent.childElements[j].position.y + curY,
                    parent.childElements[j].children!.width,
                    parent.childElements[j].children!.height)) {
                  inPos = j;
                  break;
                }
              }
            }

            if (inPos == -1) {
              return null;
            } else {
              pos.add(inPos);
              curX += parent.childElements[inPos].position.x;
              curY += parent.childElements[inPos].position.y;
              parent = parent.childElements[inPos].children!;
            }
          }
        }
        if (pos.isNotEmpty) {
          return CursorPosition(mathCanvasData.equationData[i], pos);
        }
      }
    }

    return null;
  }

  MathCanvasEquationData? findNearEquationBorder(Offset localPosition) {
    for (int i = 0; i < mathCanvasData.equationData.length; i++) {
      if (mathCanvasData.equationData[i]
          .isPointContainedOutline(localPosition)) {
        return mathCanvasData.equationData[i];
      }
    }
    return null;
  }

  CursorPosition cleanCursorPosition(CursorPosition pos) {
    pos = pos.copy();
    var element = pos.getLastElementLayout();
    while (element is! HorizontalLayoutElement) {
      pos.index.add(0);
      element =
          pos.getLastElementLayout(); //Todo : ElementLayout의 첫 항목은 null일 수 있는가?
    }
    return pos;
  }

  CursorPosition findRightCursorPosition(CursorPosition cur, {int pos = -1}) {
    if (pos == -1) pos = cur.index.length - 1;
    var result = cur.getLastElementLayout().requestCursorRight(pos, cur);
    if (result == -1) {
      if (pos == 0) {
        var a = cur.copy();
        a.index = a.index.sublist(0, 1);
        return a;
      }
      return findRightCursorPosition(cur, pos: pos - 1);
    }
    var a = cur.copy();
    a.index = a.index.sublist(0, pos + 1);
    a.index[a.index.length - 1] = result;
    return cleanCursorPosition(a);
  }

  CursorPosition findLeftCursorPosition(CursorPosition cur, {int pos = -1}) {
    if (pos == -1) pos = cur.index.length - 1;
    var result = cur.getLastElementLayout().requestCursorLeft(pos, cur);
    if (result == -1) {
      if (pos == 0) {
        var a = cur.copy();
        a.index = a.index.sublist(0, 1);
        return a;
      }
      return findLeftCursorPosition(cur, pos: pos - 1);
    }
    var a = cur.copy();
    a.index = a.index.sublist(0, pos + 1);
    a.index[a.index.length - 1] = result;
    return cleanCursorPosition(a);
  }

  CursorPosition findUpCursorPosition(CursorPosition cur, {int pos = -1}) {
    if (pos == -1) pos = cur.index.length - 1;
    var result = cur.getLastElementLayout().requestCursorUp(pos, cur);
    if (result == -1) {
      if (pos == 0) {
        var a = cur.copy();
        a.index = a.index.sublist(0, 1);
        return a;
      }
      return findUpCursorPosition(cur, pos: pos - 1);
    }
    var a = cur.copy();
    a.index = a.index.sublist(0, pos + 1);
    a.index[a.index.length - 1] = result;
    return cleanCursorPosition(a);
  }

  CursorPosition findDownCursorPosition(CursorPosition cur, {int pos = -1}) {
    if (pos == -1) pos = cur.index.length - 1;
    var result = cur.getLastElementLayout().requestCursorDown(pos, cur);
    if (result == -1) {
      if (pos == 0) {
        var a = cur.copy();
        a.index = a.index.sublist(0, 1);
        return a;
      }
      return findDownCursorPosition(cur, pos: pos - 1);
    }
    var a = cur.copy();
    a.index = a.index.sublist(0, pos + 1);
    a.index[a.index.length - 1] = result;
    return cleanCursorPosition(a);
  }
}

class CursorWidget extends StatefulWidget {
  final double fontSize;
  final Color color;
  final bool elevated;

  const CursorWidget(
      {required this.fontSize,
      this.color = Colors.black,
      this.elevated = false,
      Key? key})
      : super(key: key);

  @override
  State<CursorWidget> createState() => _CursorWidgetState();
}

class _CursorWidgetState extends State<CursorWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation _tweenAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _tweenAnimation =
        CurveTween(curve: Curves.easeInOut).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    if (!widget.elevated) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.value = 1.0;
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-1.5, -widget.fontSize / 2),
      child: Opacity(
        opacity: _tweenAnimation.value,
        child: Container(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: widget.color,
            shadows: widget.elevated
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(100),
                      offset: Offset(0, 2.5),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          width: 3,
          height: widget.fontSize,
        ),
      ),
    );
  }
}
