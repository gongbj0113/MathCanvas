import 'package:flutter/material.dart' show Offset;

import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/elements/horizontal_layout_element.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/element_system.dart';

class DataEventCreateEquation extends DataEvent {
  Offset position;
  Element? initialElement;
  void Function(MathCanvasEquationData)? onEquationCreated;

  late MathCanvasEquationData equationData;

  DataEventCreateEquation(this.position,
      {this.initialElement, this.onEquationCreated});

  @override
  void evaluate(MathCanvasData mathCanvasData) {
    HorizontalLayoutElement horizontalLayoutElement =
        HorizontalLayoutElement(18);
    if (initialElement != null) {
      horizontalLayoutElement.addElement(0, initialElement!);
    }

    equationData = MathCanvasEquationData(horizontalLayoutElement);
    equationData.anchorX = position.dx;
    equationData.anchorY = position.dy;
    equationData.rootElement.layout();

    mathCanvasData.equationData.add(equationData);
    if (onEquationCreated != null) {
      onEquationCreated!(equationData);
    }
    mathCanvasData.editorData.finishDataChange();
  }

  @override
  void undo(MathCanvasData mathCanvasData) {
    mathCanvasData.equationData.remove(equationData);
  }
}
