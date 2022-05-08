import 'package:flutter/material.dart' show Offset;
import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:math_canvas/editor/system/components/elevation_component.dart';
import 'package:math_canvas/editor/system/events/initial/add_new_equation.dart';
import 'package:math_canvas/editor/system/events/initial/editor_translate.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/initial/select_equations.dart';

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

      MathCanvasEquationData? nearEquation =
      findComponentAsType<ComponentCursor>()!.findNearEquationBorder(local);
      var cursor =
      findComponentAsType<ComponentCursor>()!.findNearCursorPosition(local);

      if (nearEquation != null) {
        startNewEventStack(SelectEquationsEventStack(nearEquation));
      }
      else if (cursor != null) {
        findComponentAsType<ComponentCursor>()!.focusTo(cursor);
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
      } else {
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
  }
}

class EditorMouseHoverEvent extends Event {
  bool mDown = false;

  @override
  void mouseDown(double dx, double dy) {
    mDown = true;
  }

  @override
  void mouseExistEditor() {
    mDown = false;
  }

  @override
  void mouseUp(double dx, double dy) {
    mDown = false;
  }

  @override
  void mouseMove(double dx, double dy) {
    if (!mDown) {
      CursorPosition? cursorPos = findComponentAsType<ComponentCursor>()!
          .findNearCursorPosition(
          mathCanvasData.editorData.globalToLocal(Offset(dx, dy)));
      MathCanvasEquationData? nearEquation =
      findComponentAsType<ComponentCursor>()!.findNearEquationBorder(
          mathCanvasData.editorData.globalToLocal(Offset(dx, dy)));

      if (nearEquation != null) {
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
        findComponentAsType<ComponentElevation>()!.hoverEquation(nearEquation);
      } else if (cursorPos != null) {
        findComponentAsType<ComponentElevation>()!
            .showElevatedCursor(cursorPos);
        findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
      } else {
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
        findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
      }
    }
  }
}
