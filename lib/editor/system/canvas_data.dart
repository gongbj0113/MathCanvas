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
    _additionalWidgetForeground
        .add(_AdditionalWidget(idCount++, widget, position, local));
    return idCount - 1;
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

  int attachWidgetBackground(Widget widget, Offset position,
      {bool local = true}) {
    _additionalWidgetBackground
        .add(_AdditionalWidget(idCount++, widget, position, local));
    return idCount - 1;
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
  double anchorX;
  double anchorY;

  double get localX => anchorX - rootElement.anchorPoint.x;
  double get localY => anchorY - rootElement.anchorPoint.y;

  MathCanvasEquationData(this.rootElement, {this.anchorX = 0, this.anchorY = 0});

  void Function()? _repaint;

  void attachDataChangedListener(void Function() onRepaintRequest) {
    _repaint = onRepaintRequest;
  }

  void requestRepaint() {
    rootElement.layout();
    if (_repaint != null) {
      _repaint!();
    }
  }
}
