import 'package:flutter/material.dart' show Offset, Widget;
import 'package:math_canvas/editor/system/element_system.dart';

class MathCanvasData {
  MathCanvasEditorData editorData = MathCanvasEditorData();
  List<MathCanvasEquationData> equationData = <MathCanvasEquationData>[];
}

class MathCanvasEditorData {
  final List<Function()> _dataChanged = [];
  final List<Widget> _additionalWidget = [];

  void attachDataChangedListener(Function() onDataChanged) {
    _dataChanged.add(onDataChanged);
  }
  //returns id
  int attachWidget(Widget widget){
    _additionalWidget.add(widget);
    return _additionalWidget.length - 1;
  }
  void detachWidget(int id){
    _additionalWidget.removeAt(id);
  }
  void updateWidget(int id, Widget widget){
    _additionalWidget.insert(id, widget);
    _additionalWidget.removeAt(id + 1);
  }

  List<Widget> getAdditionalWidget() => _additionalWidget;

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
