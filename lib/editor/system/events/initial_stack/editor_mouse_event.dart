import 'package:flutter/material.dart' show Offset;
import 'package:math_canvas/editor/system/events/initial_stack/editor_add_new_equation_es.dart';
import 'package:math_canvas/editor/system/events/initial_stack/editor_moving_es.dart';
import 'package:math_canvas/editor/system/event_system.dart';

class EditorDragEvent extends Event {
  EditorDragEvent();

  bool mDown = false;
  bool mDrag = false;
  double preMx = 0;
  double preMy = 0;

  @override
  void mouseDown(double dx, double dy) {
    mDown = true;
    preMx = dx;
    preMy = dy;
  }

  @override
  void mouseExistEditor() {
    mDown = false;
  }

  @override
  void mouseUp(double dx, double dy) {
    if (mDrag == false) {
      // it's just tap event.
      Offset local = mathCanvasData.editorData.globalToLocal(Offset(dx, dy));
      startNewEventStack(EditorAddNewEquationEventStack(local.dx, local.dy, 10));
    }
    mDown = false;
    mDrag = false;
  }

  @override
  void mouseMove(double dx, double dy) {
    if (mDown) {
      var deltaX = dx - preMx;
      var deltaY = dy - preMy;
      if (deltaY.abs() > 0.1 || deltaX.abs() > 0.1) {
        mDrag = true;
        startNewEventStack(EditorMovingEventStack(preMx, preMy));
      }
    }
  }
}
