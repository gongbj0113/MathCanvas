import 'package:flutter/material.dart' show Colors, Offset;
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:math_canvas/editor/system/events/initial/editor_add_new_equation_es.dart';
import 'package:math_canvas/editor/system/events/initial/editor_moving_es.dart';
import 'package:math_canvas/editor/system/event_system.dart';

class EditorMouseEvent extends Event {
  EditorMouseEvent();

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
      var cursor = findComponentAsType<ComponentCursor>()!.findNearCursorPosition(local);

      if(cursor != null){
        findComponentAsType<ComponentCursor>()!.focusTo(cursor!);
        findComponentAsType<ComponentCursor>()!.hideElevatedCursor();
      }else{
        startNewEventStack(
            EditorAddNewEquationEventStack(local.dx, local.dy, 20));
      }

    }
    mDown = false;
    mDrag = false;
  }

  int elevatedCursorId = -1;

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
    CursorPosition? cursorPos = findComponentAsType<ComponentCursor>()!
        .findNearCursorPosition(
            mathCanvasData.editorData.globalToLocal(Offset(dx, dy)));
    if(cursorPos != null){
      findComponentAsType<ComponentCursor>()!.showElevatedCursor(cursorPos);
    }else{
      findComponentAsType<ComponentCursor>()!.hideElevatedCursor();
    }
  }
}
