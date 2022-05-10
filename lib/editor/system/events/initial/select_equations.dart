import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/components/elevation_component.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/initial/editor_translate.dart';

import '../../components/cursor_component.dart';
import '../../components/scale_indicator_component.dart';
import '../../keyboard_system.dart';
import 'editor_mouse.dart';

class SelectEquationsEventStack extends EventStack {
  MathCanvasEquationData selectedEquation;

  SelectEquationsEventStack(this.selectedEquation);

  @override
  void initialize() {
    findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
    findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
    findComponentAsType<ComponentCursor>()!.unFocus();

    var event = _SelectEquationsEvent();
    addEvent(event);
    event.selectEquation(selectedEquation);

    addEvent(EditorScalingEvent());
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
  MouseInteractedData? interactedDown;

  @override
  void mouseDown(double dx, double dy) {
    mDown = true;
    preMx = dx;
    preMy = dy;

    interactedDown = MouseInteractedData(
        findComponentAsType<ComponentCursor>()!, mathCanvasData, dx, dy);

    if (interactedDown!.cursor != null &&
        !selectedEquations.contains(interactedDown!.cursor!.rootEquation)) {
      closeEventStack(true);
      return;
    }
  }

  @override
  void mouseMove(double dx, double dy) {
    if (!mDown) {
      var interaction = MouseInteractedData(
          findComponentAsType<ComponentCursor>()!, mathCanvasData, dx, dy);
      if (interaction.nearEquation != null) {
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
        if (!selectedEquations.contains(interaction.nearEquation!)) {
          findComponentAsType<ComponentElevation>()!
              .hoverEquation(interaction.nearEquation!);
        }
      } else if (interaction.cursor != null) {
        if (shiftDown) {
          findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
          if (!selectedEquations.contains(interaction.cursor!.rootEquation)) {
            findComponentAsType<ComponentElevation>()!
                .hoverEquation(interaction.cursor!.rootEquation);
          }
        } else {
          findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
          if (!selectedEquations.contains(interaction.cursor!.rootEquation)) {
            findComponentAsType<ComponentElevation>()!
                .showElevatedCursor(interaction.cursor!);
          }
        }
      } else {
        findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
        findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
      }
    } else {
      var deltaX = dx - preMx;
      var deltaY = dy - preMy;
      if (deltaY.abs() > 0.1 || deltaX.abs() > 0.1) {
        mDrag = true;
        if ((interactedDown!.nearEquation != null &&
                selectedEquations.contains(interactedDown!.nearEquation!)) ||
            (interactedDown!.cursor != null &&
                selectedEquations
                    .contains(interactedDown!.cursor!.rootEquation))) {
          startNewEventStack(_DragSelectedEquationsEventStack(
              preMx, preMy, selectedEquations));
        } else {
          startNewEventStack(EditorMovingEventStack(preMx, preMy));
        }
      }
    }
  }

  @override
  void mouseUp(double dx, double dy) {
    if (!mDrag) {
      interactedDown ??= MouseInteractedData(
          findComponentAsType<ComponentCursor>()!, mathCanvasData, dx, dy);

      findComponentAsType<ComponentElevation>()!.dismissHoverEquations();
      if (shiftDown) {
        if (interactedDown!.nearEquation != null) {
          if (selectedEquations.contains(interactedDown!.nearEquation!)) {
            dismissSelectedEquation(interactedDown!.nearEquation!);
            if (selectedEquations.isEmpty) {
              closeEventStack(false);
              return;
            }
          } else {
            selectEquation(interactedDown!.nearEquation!);
          }
        } else if (interactedDown!.cursor != null) {
          if (selectedEquations
              .contains(interactedDown!.cursor!.rootEquation)) {
            dismissSelectedEquation(interactedDown!.cursor!.rootEquation);
            if (selectedEquations.isEmpty) {
              closeEventStack(false);
              return;
            }
          } else {
            selectEquation(interactedDown!.cursor!.rootEquation);
          }
        } else {
          closeEventStack(false);
        }
      } else {
        if (interactedDown!.nearEquation != null) {
          if (selectedEquations.contains(interactedDown!.nearEquation!)) {
            var toDismiss = [];
            for (var eq in selectedEquations) {
              if (eq != interactedDown!.nearEquation) toDismiss.add(eq);
            }
            for (var eq in toDismiss) {
              dismissSelectedEquation(eq);
            }
          } else {
            dismissAllSelectedEquations();
            selectEquation(interactedDown!.nearEquation!);
          }
        } else {
          if (interactedDown!.cursor != null) {
            findComponentAsType<ComponentCursor>()!
                .focusTo(interactedDown!.cursor!);
            findComponentAsType<ComponentElevation>()!.hideElevatedCursor();
          }
          dismissAllSelectedEquations();
          closeEventStack(false);
        }
      }
    } else {}
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

class _DragSelectedEquationsEventStack extends EventStack {
  double preMx;
  double preMy;
  List<MathCanvasEquationData> selectedEquations;

  _DragSelectedEquationsEventStack(
      this.preMx, this.preMy, this.selectedEquations);

  @override
  void initialize() {
    addEvent(_DragSelectedEquationsEvent(preMx, preMy, selectedEquations));
    super.initialize();
  }
}

class _DragSelectedEquationsEvent extends Event {
  double preMx;
  double preMy;
  List<MathCanvasEquationData> selectedEquations;

  _DragSelectedEquationsEvent(this.preMx, this.preMy, this.selectedEquations);

  List<Offset> prePos = [];
  double preEx = 0;
  double preEy = 0;

  bool applied = false;

  @override
  void initialize() {
    for (int i = 0; i < selectedEquations.length; i++) {
      prePos.add(
          Offset(selectedEquations[i].anchorX, selectedEquations[i].anchorY));
      findComponentAsType<ComponentElevation>()!.elevateEquation(
        selectedEquations[i],
        shadowStrength: 2.5,
        finishDataChange: true,
        onEndShadowLerp: () {
          applied = true;
        },
      );
    }
    mathCanvasData.editorData.finishDataChange();
    super.initialize();
  }

  @override
  void mouseExistEditor() {
    closeEventStack(true);
  }

  @override
  void mouseUp(double dx, double dy) {
    for (int i = 0; i < selectedEquations.length; i++) {
      findComponentAsType<ComponentElevation>()!.elevateEquation(
          selectedEquations[i],
          shadowStrength: 1.0,
          finishDataChange: false);
    }
    mathCanvasData.editorData.finishDataChange();
    closeEventStack(true);
  }

  @override
  void mouseMove(double dx, double dy) {
    var deltaX = dx - preMx;
    var deltaY = dy - preMy;
    if (applied) {
      for (int i = 0; i < selectedEquations.length; i++) {
        selectedEquations[i].anchorPos = Offset(
            prePos[i].dx + deltaX / mathCanvasData.editorData.scale,
            prePos[i].dy + deltaY / mathCanvasData.editorData.scale);
      }
      mathCanvasData.editorData.finishDataChange();
    }
  }

  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    //Todo : make scaling from center origin.
    mathCanvasData.editorData.scale -= scrollDelta.dy / 1000;
    findComponentAsType<ComponentScaleIndicator>()!.updateScaleIndicator();
    mathCanvasData.editorData.finishDataChange();
  }
}
