import 'package:math_canvas/editor/system/components/elevation_component.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/initial/editor_keyboard_event.dart';
import 'package:math_canvas/editor/system/events/initial/editor_scaling_event.dart';
import '../components/cursor_component.dart';
import '../components/scale_indicator_component.dart';
import 'initial/editor_mouse_event.dart';

class EditorInitialEventStack extends EventStack{
  @override
  void initialize() {
    addComponent(ComponentScaleIndicator());
    addComponent(ComponentCursor());
    addComponent(ComponentElevation());

    addEvent(EditorMouseEvent());
    addEvent(EditorMouseHoverEvent());
    addEvent(EditorKeyboardEvent());
    addEvent(EditorScalingEvent());
    super.initialize();
  }
}