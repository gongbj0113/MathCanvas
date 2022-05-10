import 'package:flutter/material.dart'
    show Alignment, Offset, Transform, Widget;
import 'package:math_canvas/editor/system/element_system.dart';

class MathCanvasData {
  MathCanvasEditorData editorData = MathCanvasEditorData();
  List<MathCanvasEquationData> equationData = <MathCanvasEquationData>[];
}

class _AdditionalWidget {
  _AdditionalWidget(this.id, this.widget, this.position, this.local);

  int id;
  Widget widget;
  Offset position;
  bool local;
}

class MathCanvasEditorData {
  final List<Function()> _dataChanged = [];
  final List<_AdditionalWidget> _additionalWidgetForeground = [];
  final List<_AdditionalWidget> _additionalWidgetBackground = [];

  int idCount = 0;

  Offset localToGlobal(Offset offset) {
    return Offset((offset.dx - x) * scale, (offset.dy - y) * scale);
  }

  Offset globalToLocal(Offset offset) {
    return Offset((offset.dx / scale) + x, (offset.dy / scale) + y);
  }

  void attachDataChangedListener(Function() onDataChanged) {
    _dataChanged.add(onDataChanged);
  }

  Widget _buildAdditionalWidgetGlobal(Widget widget, Offset position) =>
      Transform.translate(
        offset: Offset(position.dx, position.dy),
        child: widget,
      );

  Widget _buildAdditionalWidgetLocal(Widget widget, Offset position) =>
      Transform.translate(
        offset: Offset(
          (position.dx - x) * scale,
          (position.dy - y) * scale,
        ),
        child: Transform.scale(
          alignment: Alignment.topLeft,
          scale: scale,
          child: widget,
        ),
      );

  //returns id
  int attachWidgetForeground(Widget widget, Offset position,
      {bool local = true}) {
    int newId = idCount + 1;
    idCount++;
    _additionalWidgetForeground
        .add(_AdditionalWidget(newId, widget, position, local));
    return newId;
  }

  void detachWidgetForeground(int id) {
    for (int i = 0; i < _additionalWidgetForeground.length; i++) {
      if (_additionalWidgetForeground[i].id == id) {
        _additionalWidgetForeground.removeAt(i);
        return;
      }
    }
    print("Detach: There is no attached Foreground Widget with id : $id");
  }

  void updateWidgetForeground(int id, Widget widget, Offset position,
      {bool local = true}) {
    for (int i = 0; i < _additionalWidgetForeground.length; i++) {
      if (_additionalWidgetForeground[i].id == id) {
        _additionalWidgetForeground[i] =
            _AdditionalWidget(id, widget, position, local);
        return;
      }
    }
    print("Update: There is no attached Foreground Widget with id : $id");
  }

  int getNextId() {
    return idCount + 1;
  }

  int attachWidgetBackground(Widget widget, Offset position,
      {bool local = true}) {
    int newId = idCount + 1;
    idCount++;
    _additionalWidgetBackground
        .add(_AdditionalWidget(newId, widget, position, local));
    return newId;
  }

  void detachWidgetBackground(int id) {
    for (int i = 0; i < _additionalWidgetBackground.length; i++) {
      if (_additionalWidgetBackground[i].id == id) {
        _additionalWidgetBackground.removeAt(i);
        return;
      }
    }
    print("Detach: There is no attached Background Widget with id : $id");
  }

  void updateWidgetBackground(int id, Widget widget, Offset position,
      {bool local = true}) {
    for (int i = 0; i < _additionalWidgetBackground.length; i++) {
      if (_additionalWidgetBackground[i].id == id) {
        _additionalWidgetBackground[i] =
            _AdditionalWidget(id, widget, position, local);
        return;
      }
    }
    print("Update: There is no attached Background Widget with id : $id");
  }

  List<Widget> getAdditionalWidgetForeground() => _additionalWidgetForeground
      .map((e) => (e.local
          ? _buildAdditionalWidgetLocal(e.widget, e.position)
          : _buildAdditionalWidgetGlobal(e.widget, e.position)))
      .toList();

  List<Widget> getAdditionalWidgetBackground() => _additionalWidgetBackground
      .map((e) => (e.local
          ? _buildAdditionalWidgetLocal(e.widget, e.position)
          : _buildAdditionalWidgetGlobal(e.widget, e.position)))
      .toList();

  double x = 0;
  double y = 0;
  double scale = 1;

  void finishDataChange() {
    for (var f in _dataChanged) {
      f();
    }
  }
}

class MathCanvasEquationData {
  final Element rootElement;

  //position of the anchor inside the editor
  double _anchorX;
  double _anchorY;

  double get anchorX => _anchorX;
  double get anchorY => _anchorY;

  set anchorX(double value) {
    _anchorX = value;
    requestPositionChanged();
  }

  set anchorY(double value) {
    _anchorY = value;
    requestPositionChanged();
  }

  Offset get anchorPos => Offset(anchorX, anchorY);

  set anchorPos(Offset value) {
    _anchorX = value.dx;
    _anchorY = value.dy;
    requestPositionChanged();
  }

  double get localX => anchorX - rootElement.anchorPoint.x;

  double get localY => anchorY - rootElement.anchorPoint.y;

  MathCanvasEquationData(this.rootElement,
      {double anchorX = 0, double anchorY = 0})
      : _anchorX = anchorX,
        _anchorY = anchorY;

  final List<void Function()?> _repaint = [];
  final List<void Function()?> _positionChanged = [];

  bool isPointContained(Offset position) {
    return position.dx > localX &&
        position.dx < localX + rootElement.width &&
        position.dy > localY &&
        position.dy < localY + rootElement.height;
  }

  static double outlineMargin = 8;

  bool isPointContainedOutline(Offset position) {
    return (((position.dx > localX - outlineMargin && position.dx < localX) ||
                (position.dx > localX + rootElement.width &&
                    position.dx <
                        localX + rootElement.width + outlineMargin)) &&
            (position.dy > localY - outlineMargin &&
                position.dy < localY + rootElement.height + outlineMargin)) ||
        (((position.dy > localY - outlineMargin && position.dy < localY) ||
                (position.dy > localY + rootElement.height &&
                    position.dy <
                        localY + rootElement.height + outlineMargin)) &&
            (position.dx > localX - outlineMargin &&
                position.dx < localX + rootElement.width + outlineMargin));
  }

  void addRepaintListener(void Function() onRepaintRequest) {
    if (!_repaint.contains(onRepaintRequest)) {
      _repaint.add(onRepaintRequest);
    }
  }

  void removeRepaintListener(void Function() onRepaintRequest) {
    _repaint.remove(onRepaintRequest);
  }

  void addPositionChangedListener(void Function() onPositionChangedRequest) {
    if (!_positionChanged.contains(onPositionChangedRequest)) {
      _positionChanged.add(onPositionChangedRequest);
    }
  }

  void removePositionChangedListener(void Function() onPositionChangedRequest) {
    _positionChanged.remove(onPositionChangedRequest);
  }

  void requestRepaint() {
    rootElement.layout();
    for (var f in _repaint) {
      if (f != null) {
        f();
      }
    }
  }

  void requestPositionChanged() {
    for (var f in _positionChanged) {
      if (f != null) {
        f();
      }
    }
  }
}
