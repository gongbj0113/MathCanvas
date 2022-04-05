import 'package:math_canvas/editor/system/event_system.dart';
import 'package:math_canvas/editor/system/events/initial_stack/editor_scaling_event.dart';
import '../../components/scale_indicator_component.dart';
import 'editor_mouse_event.dart';

class EditorInitialEventStack extends EventStack{
  @override
  void initialize() {
    addEvent(EditorDragEvent());
    addEvent(EditorScalingEvent());
    addComponent(ComponentScaleIndicator());
    super.initialize();
  }
}