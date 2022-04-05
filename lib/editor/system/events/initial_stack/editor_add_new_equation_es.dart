import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_canvas/editor/system/element_system.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/data/equation_create_new.dart';
import 'package:math_canvas/editor/system/events/initial_stack/editor_scaling_event.dart';

class EditorAddNewEquationEventStack extends EventStack {
  double editorX;
  double editorY;
  double fontSize;

  EditorAddNewEquationEventStack(this.editorX, this.editorY, this.fontSize);

  @override
  void initialize() {
    addEvent(_EditorAddNewEquationEvent(editorX, editorY, fontSize));
    addEvent(EditorScalingEvent());
    //startNewEventStack(EditorMovingEventStack(editorX, editorY));
    super.initialize();
  }
}

class _EditorAddNewEquationEvent extends Event {
  final double editorX;
  final double editorY;
  final double fontSize;

  _EditorAddNewEquationEvent(this.editorX, this.editorY, this.fontSize);

  late int id;

  Widget newCursorWidget() {
    return Container(
      color: Colors.red,
      width: 3,
      height: fontSize,
    );
  }

  @override
  void initialize() {
    id = mathCanvasData.editorData.attachWidgetForeground(
      newCursorWidget(),
      Offset(editorX - 1.5, editorY - fontSize / 2),
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

  var validKeys = [
    "!",
    "@",
    "#",
    "\$",
    "%",
    "^",
    "&",
    "*",
    "(",
    ")",
    "-",
    "_",
    "+",
    "=",
    "\"",
    "'",
    "[",
    "{",
    "]",
    "}",
    "\\",
    "|",
    ",",
    "<",
    ".",
    ">",
    "/",
    "?",
    ";",
    ":",
    "~",
    "`"
  ];

  @override
  void keyDown(PhysicalKeyboardKey key) {
    if ((key.usbHidUsage >= 0x00070004 &&
                key.usbHidUsage <= 0x0007001d) || // aA~zZ
            (key.usbHidUsage >= 0x0007001e &&
                key.usbHidUsage <= 0x00070027) || // digit 1~9, 0
            (key.usbHidUsage >= 0x00070059 &&
                key.usbHidUsage <= 0x00070062) || // numpad 1~9, 0
            (validKeys.contains(key.debugName)) // other symbols
        ) {
      //create new Equation
      startNewDataEvent(
        DataEventCreateEquation(
          Offset(editorX, editorY),
          initialElement: ElementSymbol(
            elementFontOption: ElementFontOption(),
            content: key.debugName ?? "?",
          ),
        ),
      );
    } else {
      closeEventStack(false);
      return;
    }
  }
}
