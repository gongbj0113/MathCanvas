import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/components/elevation_component.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/initial/editor_translate.dart';

import '../../components/cursor_component.dart';
import '../../keyboard_system.dart';

class SelectEquationsEventStack extends EventStack {
  MathCanvasEquationData selectedEquation;

  SelectEquationsEventStack(this.selectedEquation);

  @override
  void initialize() {
    findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
    findComponentAsType<ComponentCursor>()!.unFocus();

    var event = _SelectEquationsEvent();
    addEvent(event);
    addEvent(EditorScalingEvent());

    event.selectEquation(selectedEquation);
    super.initialize();
  }
}

class _SelectEquationsEvent extends Event {
  final List<MathCanvasEquationData> selectedEquations = [];

  void selectEquation(MathCanvasEquationData eq,
      {bool finishDataChange = true}) {
    selectedEquations.add(eq);
    findComponentAsType<ComponentElevation>()!
        .elevateEquation(eq, finishDataChange: finishDataChange);
  }

  @override
  void dispose() {
    dismissAllSelectedEquations();
    super.dispose();
  }

  void dismissSelectedEquation(MathCanvasEquationData eq,
      {bool finishDataChange = true}) {
    assert(selectedEquations.contains(eq));
    selectedEquations.remove(eq);
    findComponentAsType<ComponentElevation>()!
        .dismissElevatedEquation(eq, finishDataChange: finishDataChange);
  }

  void dismissAllSelectedEquations({bool finishDataChange = true}) {
    int c = selectedEquations.length;
    for (int i = 0; i < c; i++) {
      dismissSelectedEquation(selectedEquations[0], finishDataChange: true);
    }
  }

  bool mDown = false;
  bool mDrag = false;
  double preMx = 0;
  double preMy = 0;

  @override
  void mouseDown(double dx, double dy) {
    mDown = true;
    preMx = dx;
    preMy = dy;

    Offset local = mathCanvasData.editorData.globalToLocal(Offset(dx, dy));
    var cursor =
        findComponentAsType<ComponentCursor>()!.findNearCursorPosition(local);

    if (cursor != null && !shiftDown) {
      closeEventStack(true);
      return;
    }
  }

  @override
  void mouseMove(double dx, double dy) {
    if (!mDown) {
      var local = mathCanvasData.editorData.globalToLocal(Offset(dx, dy));
      var cursorPos =
          findComponentAsType<ComponentCursor>()!.findNearCursorPosition(local);
      var nearEquation =
          findComponentAsType<ComponentCursor>()!.findNearEquationBorder(local);

      if (shiftDown) {
        if (nearEquation != null) {
          findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
          if (!selectedEquations.contains(nearEquation)) {
            findComponentAsType<ComponentElevation>()!
                .hoverEquation(nearEquation);
          }
        } else if (cursorPos != null) {
          findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
          if (!selectedEquations.contains(cursorPos.rootEquation)) {
            findComponentAsType<ComponentElevation>()!
                .hoverEquation(cursorPos.rootEquation);
          }
        } else {
          findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
          findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
        }
      } else {
        if (nearEquation != null) {
          findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
          if (!selectedEquations.contains(nearEquation)) {
            findComponentAsType<ComponentElevation>()!
                .hoverEquation(nearEquation);
          }
        } else if (cursorPos != null) {
          findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
          if (!selectedEquations.contains(cursorPos.rootEquation)) {
            findComponentAsType<ComponentElevation>()!
                .showElevatedCursor(cursorPos);
          }
        } else {
          findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
          findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
        }
      }
    } else {
      var deltaX = dx - preMx;
      var deltaY = dy - preMy;
      if (deltaY.abs() > 0.1 || deltaX.abs() > 0.1) {
        mDrag = true;
        startNewEventStack(EditorMovingEventStack(preMx, preMy));
      }
    }
  }

  @override
  void mouseUp(double dx, double dy) {
    //Todo : close this eventStack when selectedEquation count is 0.
    if (!mDrag) {
      Offset local = mathCanvasData.editorData.globalToLocal(Offset(dx, dy));

      MathCanvasEquationData? nearEquation =
          findComponentAsType<ComponentCursor>()!.findNearEquationBorder(local);
      CursorPosition? cursor =
          findComponentAsType<ComponentCursor>()!.findNearCursorPosition(local);
      findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
      if (shiftDown) {
        if (nearEquation != null) {
          if (selectedEquations.contains(nearEquation)) {
            dismissSelectedEquation(nearEquation);
          } else {
            selectEquation(nearEquation);
          }
        } else if (cursor != null) {
          if (selectedEquations.contains(cursor.rootEquation)) {
            dismissSelectedEquation(cursor.rootEquation);
          } else {
            selectEquation(cursor.rootEquation);
          }
        } else {
          closeEventStack(false);
        }
      } else {
        if (nearEquation != null) {
          if (selectedEquations.contains(nearEquation)) {
            var toDismiss = [];
            for (var eq in selectedEquations) {
              if (eq != nearEquation) toDismiss.add(eq);
            }
            for (var eq in toDismiss) {
              dismissSelectedEquation(eq);
            }
          } else {
            dismissAllSelectedEquations();
            selectEquation(nearEquation);
          }
        } else {
          dismissAllSelectedEquations();
          closeEventStack(false);
        }
      }
    }
    mDown = false;
    mDrag = false;
  }

  @override
  void mouseExistEditor() {
    mDown = false;
  }

  bool shiftDown = false;

  @override
  void keyDown(KeyboardEventData key) {
    if (key.logicalKey == LogicalKeyboardKey.shiftLeft) {
      shiftDown = true;
    }
  }

  @override
  void keyUp(KeyboardEventData key) {
    if (key.logicalKey == LogicalKeyboardKey.shiftLeft) {
      shiftDown = false;
    }
  }
}
