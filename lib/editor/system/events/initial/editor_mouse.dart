import 'package:flutter/material.dart' show Offset;
import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:math_canvas/editor/system/components/elevation_component.dart';
import 'package:math_canvas/editor/system/events/initial/add_new_equation.dart';
import 'package:math_canvas/editor/system/events/initial/editor_translate.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/initial/select_equations.dart';

class MouseInteractedData {
  late Offset global;
  late Offset local;
  MathCanvasEquationData? nearEquation;
  CursorPosition? cursor;

  MouseInteractedData(ComponentCursor componentCursor,
      MathCanvasData mathCanvasData, double mx, double my) {
    global = Offset(mx, my);
    local = mathCanvasData.editorData.globalToLocal(global);
    nearEquation = componentCursor.findNearEquationBorder(local);
    cursor = componentCursor.findNearCursorPosition(local);
  }
}

class EditorMouseEvent extends Event {
  EditorMouseEvent();

  bool mDown = false;
  bool mDrag = false;
  double preMx = 0;
  double preMy = 0;
  MouseInteractedData? interactedDown;

  @override
  void mouseDown(double dx, double dy) {
    mDown = true;
    preMx = dx;
    preMy = dy;
    interactedDown = MouseInteractedData(
        findComponentAsType<ComponentCursor>()!, mathCanvasData, dx, dy);
  }

  @override
  void mouseExistEditor() {
    mDown = false;
  }

  @override
  void mouseUp(double dx, double dy) {
    if (mDrag == false) {
      // it's just tap event.
      interactedDown ??= MouseInteractedData(
          findComponentAsType<ComponentCursor>()!, mathCanvasData, dx, dy);

      if (interactedDown!.nearEquation != null) {
        startNewEventStack(
            SelectEquationsEventStack(interactedDown!.nearEquation!));
      } else if (interactedDown!.cursor != null) {
        findComponentAsType<ComponentCursor>()!
            .focusTo(interactedDown!.cursor!);
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
      } else {
        startNewEventStack(EditorAddNewEquationEventStack(
            interactedDown!.local.dx, interactedDown!.local.dy, 20));
      }
    }
    mDown = false;
    mDrag = false;
  }

  int elevatedCursorId = -1;

  @override
  void mouseMove(double dx, double dy) {
    if (mDown) {
      if (interactedDown!.cursor != null) {
      } else {
        var deltaX = dx - preMx;
        var deltaY = dy - preMy;
        if (deltaY.abs() > 0.1 || deltaX.abs() > 0.1) {
          mDrag = true;
          if (interactedDown!.nearEquation != null) {
            startNewEventStack(DragSelectedEquationsEventStack(
                preMx, preMy, [interactedDown!.nearEquation!],
                dismissOnEnd: true), tag: "drag_elevation");
          } else {
            startNewEventStack(EditorMovingEventStack(preMx, preMy));
          }
        }
      }
    }
  }

  @override
  void onEventStackResultReceived(result, String? tag) {
    if(tag == "drag_elevation"){
      findComponentAsType<ComponentElevation>()!.hoverEquation((result as List)[0]);
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
      var interaction = MouseInteractedData(
          findComponentAsType<ComponentCursor>()!, mathCanvasData, dx, dy);

      if (interaction.nearEquation != null) {
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
        findComponentAsType<ComponentElevation>()!
            .hoverEquation(interaction.nearEquation!);
      } else if (interaction.cursor != null) {
        findComponentAsType<ComponentElevation>()!
            .showElevatedCursor(interaction.cursor!);
        findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
      } else {
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
        findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
      }
    }
  }
}
