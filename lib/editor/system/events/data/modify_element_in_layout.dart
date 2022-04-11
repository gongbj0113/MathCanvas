import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/components/cursor_component.dart';
import 'package:math_canvas/editor/system/element_system.dart';

import '../../event_system.dart';

class AddElementInLayout extends DataEvent{
  CursorPosition _cursorPosition;
  Element _element;
  void Function(CursorPosition cursorPosition)? onElementAdded;
  void Function(CursorPosition cursorPosition)? onElementRemoved;

  AddElementInLayout(this._cursorPosition, this._element, {this.onElementAdded, this.onElementRemoved});

  @override
  void evaluate(MathCanvasData mathCanvasData) {
    _cursorPosition.getLastElementLayout().addElement(_cursorPosition.index.last, _element);
    _cursorPosition.rootEquation.rootElement.layout();
    if(onElementAdded != null){
      CursorPosition n = _cursorPosition.copy();
      n.index[n.index.length - 1] = n.index[n.index.length - 1] + 1;
      onElementAdded!(n);
    }
    _cursorPosition.rootEquation.requestRepaint();
  }

  @override
  void undo(MathCanvasData mathCanvasData) {
    // TODO: implement undo
  }

}

class DeleteElementInLayout extends DataEvent{
  CursorPosition _cursorPosition;
  void Function(CursorPosition cursorPosition)? onElementAdded;
  void Function(CursorPosition cursorPosition)? onElementRemoved;

  DeleteElementInLayout(this._cursorPosition, {this.onElementAdded, this.onElementRemoved});

  @override
  void evaluate(MathCanvasData mathCanvasData) {
    _cursorPosition.getLastElementLayout().deleteElement(_cursorPosition.index.last);
    _cursorPosition.rootEquation.rootElement.layout();
    if(onElementAdded != null){
      CursorPosition n = _cursorPosition.copy();
      onElementAdded!(n);
    }
    _cursorPosition.rootEquation.requestRepaint();
  }

  @override
  void undo(MathCanvasData mathCanvasData) {
    // TODO: implement undo
  }

}