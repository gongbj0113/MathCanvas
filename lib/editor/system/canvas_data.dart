import 'package:flutter/material.dart' show Offset, Positioned, Widget;
import 'package:math_canvas/editor/system/element_system.dart';

class MathCanvasData {
  MathCanvasEditorData editorData = MathCanvasEditorData();
  List<MathCanvasEquationData> equationData = <MathCanvasEquationData>[];
}

class MathCanvasEditorData {
  final List<Function()> _dataChanged = [];
  final List<Widget> _additionalWidgetForeground = [];
  final List<Widget> _additionalWidgetBackground = [];

  Offset localToGlobal(Offset offset) {
    return Offset((offset.dx - x) * scale, (offset.dy - y) * scale);
  }

  Offset globalToLocal(Offset offset) {
    return Offset((offset.dx / scale) + x, (offset.dy / scale) + y);
  }

  void attachDataChangedListener(Function() onDataChanged) {
    _dataChanged.add(onDataChanged);
  }

  Widget _buildAdditionalWidget(Widget widget, Offset globalPosition) =>
      Positioned(
        left: globalPosition.dx,
        top: globalPosition.dy,
        child: widget,
      );

  //returns id
  int attachWidgetForeground(Widget widget, Offset position,
      {bool localPosition = true}) {
    _additionalWidgetForeground.add(
      _buildAdditionalWidget(
        widget,
        localPosition ? localToGlobal(position) : position,
      ),
    );
    return _additionalWidgetForeground.length - 1;
  }

  void detachWidgetForeground(int id) {
    _additionalWidgetForeground.removeAt(id);
  }

  void updateWidgetForeground(int id, Widget widget, Offset position,
      {bool localPosition = true}) {
    _additionalWidgetForeground.insert(
      id,
      _buildAdditionalWidget(
        widget,
        localPosition ? localToGlobal(position) : position,
      ),
    );
    _additionalWidgetForeground.removeAt(id + 1);
  }

  int attachWidgetBackground(Widget widget, Offset position,
      {bool localPosition = true}) {
    _additionalWidgetBackground.add(
      _buildAdditionalWidget(
        widget,
        localPosition ? localToGlobal(position) : position,
      ),
    );
    return _additionalWidgetBackground.length - 1;
  }

  void detachWidgetBackground(int id) {
    _additionalWidgetBackground.removeAt(id);
  }

  void updateWidgetBackground(int id, Widget widget, Offset position,
      {bool localPosition = true}) {
    _additionalWidgetBackground.insert(
      id,
      _buildAdditionalWidget(
        widget,
        localPosition ? localToGlobal(position) : position,
      ),
    );
    _additionalWidgetBackground.removeAt(id + 1);
  }

  List<Widget> getAdditionalWidgetForeground() => _additionalWidgetForeground;

  List<Widget> getAdditionalWidgetBackground() => _additionalWidgetBackground;

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
  late final Element rootElement;

  //position of the anchor inside the editor
  double x = 0;
  double y = 0;

  MathCanvasEquationData(this.rootElement);

  final List<Function()> _repaint = [];

  void attachDataChangedListener(Function() onRepaintRequest) {
    _repaint.add(onRepaintRequest);
  }

  void requestRepaint() {
    for (var f in _repaint) {
      f();
    }
  }
}
