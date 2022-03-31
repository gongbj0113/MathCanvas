import 'package:math_canvas/editor/system/element_system.dart';

class MathCanvasData {
  MathCanvasEditorData editorData = MathCanvasEditorData();
  List<MathCanvasEquationData> equationData = <MathCanvasEquationData>[];
}

class MathCanvasEditorData {
  final List<Function()> _dataChanged = [];

  void attachDataChangedListener(Function() onDataChanged) {
    _dataChanged.add(onDataChanged);
  }

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
