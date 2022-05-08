import 'package:flutter/services.dart';
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:math_canvas/editor/system/element_system.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/data/modify_element_in_layout.dart';
import 'package:math_canvas/editor/system/keyboard_system.dart';

class EditorKeyboardEvent extends Event {

  void _addElementInLayout(KeyboardEventData key) {
    ComponentCursor cursor = findComponentAsType<ComponentCursor>()!;
    startNewDataEvent(
      AddElementInLayout(
        cursor.pos!,
        ElementSymbol(
          content: key.logicalString,
          elementFontOption: ElementFontOption(size: cursor.pos!.getFontSize()),
        ),
        onElementAdded: (cursorPosition) {
          cursor.focusTo(cursorPosition);
        },
        onElementRemoved: (cursorPosition) {
          cursor.focusTo(cursorPosition);
        },
      ),
    );
  }

  void _replaceElementInLayout(KeyboardEventData key) {
    // todo: write selection related codes.
  }

  void _deleteElementInLayout(KeyboardEventData key) {
    //Todo : check whether element can be deleted on current cursor position.
    ComponentCursor cursor = findComponentAsType<ComponentCursor>()!;
    startNewDataEvent(
      DeleteElementInLayout(
        cursor.pos!.copy()
          ..index.last -= 1,
        onElementAdded: (cursorPosition) {
          cursor.focusTo(cursorPosition);
        },
        onElementRemoved: (cursorPosition) {
          cursor.focusTo(cursorPosition);
        },
      ),
    );
  }

  @override
  void keyDown(KeyboardEventData key) {
    var compCursor = findComponentAsType<ComponentCursor>()!;
    if (key.isControlPressed && key.logicalKey == LogicalKeyboardKey.keyZ) {
      //TOdo : perform undo
    } else if (key.isShiftPressed &&
        key.isControlPressed &&
        key.logicalKey == LogicalKeyboardKey.keyZ) {
      //Todo : perform redo
    } else if (key.logicalKey == LogicalKeyboardKey.arrowRight) {
      if(compCursor.status == CursorStatus.focused){
        compCursor.focusTo(compCursor.findRightCursorPosition(compCursor.pos!));
      }
    } else if(key.logicalKey == LogicalKeyboardKey.arrowLeft){
      if(compCursor.status == CursorStatus.focused){
        compCursor.focusTo(compCursor.findLeftCursorPosition(compCursor.pos!));
      }
    }else if(key.logicalKey == LogicalKeyboardKey.arrowUp){
      if(compCursor.status == CursorStatus.focused){
        compCursor.focusTo(compCursor.findUpCursorPosition(compCursor.pos!));
      }
    }else if(key.logicalKey == LogicalKeyboardKey.arrowDown){
      if(compCursor.status == CursorStatus.focused){
        compCursor.focusTo(compCursor.findDownCursorPosition(compCursor.pos!));
      }
    }
    else if (key.isLetter()) {
      if (findComponentAsType<ComponentCursor>()!.status ==
          CursorStatus.focused) {
        _addElementInLayout(key);
      } else if (findComponentAsType<ComponentCursor>()!.status ==
          CursorStatus.selection) {
        _replaceElementInLayout(key);
      }
    } else if (key.logicalKey == LogicalKeyboardKey.backspace) {
      if (findComponentAsType<ComponentCursor>()!.status ==
          CursorStatus.focused) {
        _deleteElementInLayout(key);
      } else if (findComponentAsType<ComponentCursor>()!.status ==
          CursorStatus.selection) {
        _replaceElementInLayout(key);
      }
    }
  }
}
