import 'package:flutter/material.dart';
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:math_canvas/editor/system/element_system.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/data/equation_create_new.dart';
import 'package:math_canvas/editor/system/events/initial_stack/editor_scaling_event.dart';

import '../../keyboard_system.dart';

class EditorAddNewEquationEventStack extends EventStack {
  double editorX;
  double editorY;
  double fontSize;

  EditorAddNewEquationEventStack(this.editorX, this.editorY, this.fontSize);

  @override
  void initialize() {
    addEvent(_EditorAddNewEquationEvent(editorX, editorY, fontSize));
    addEvent(EditorScalingEvent());
    super.initialize();
  }
}

class _EditorAddNewEquationEvent extends Event {
  final double editorX;
  final double editorY;
  final double fontSize;

  _EditorAddNewEquationEvent(this.editorX, this.editorY, this.fontSize);

  late int id;

  @override
  void initialize() {
    var cursorStatus = findComponentAsType<ComponentCursor>()!.status;
    if(cursorStatus == CursorStatus.focused || cursorStatus == CursorStatus.selection){
      findComponentAsType<ComponentCursor>()!.unFocus();
    }
    id = mathCanvasData.editorData.attachWidgetForeground(
      CursorWidget(fontSize: fontSize, color: Colors.redAccent),
      Offset(editorX, editorY),
      local: true,
    );
    mathCanvasData.editorData.finishDataChange();
    super.initialize();
  }

  @override
  void dispose() {
    mathCanvasData.editorData.detachWidgetForeground(id);
    mathCanvasData.editorData.finishDataChange();
    super.dispose();
  }

  @override
  void mouseDown(double dx, double dy) {
    closeEventStack(true);
  }

  @override
  void keyDown(KeyboardEventData key) {
    if (key.isLetter()) {
      //create new Equation

      startNewDataEvent(
        DataEventCreateEquation(
          Offset(editorX, editorY),
          initialElement: ElementSymbol(
            elementFontOption: ElementFontOption(),
            content: key.logicalString,
          ),
          onEquationCreated: (equationData) {
            findComponentAsType<ComponentCursor>()!.focusTo(
              CursorPosition(
                equationData,
                [1],
              ),
            );
          },
        ),
      );
      closeEventStack(false);
    } else if (key.isAction()) {
      closeEventStack(false);
      return;
    }
  }
}
