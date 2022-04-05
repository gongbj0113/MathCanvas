import 'package:math_canvas/editor/system/event_system.dart';

import '../canvas_data.dart';

class CursorPosition{
  CursorPosition(this.rootEquation, this.index);

  MathCanvasEquationData rootEquation;
  List<int> index;
}

class ComponentCursor extends EventSystemComponent{

}