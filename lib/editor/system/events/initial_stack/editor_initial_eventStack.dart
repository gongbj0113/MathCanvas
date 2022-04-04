import 'package:math_canvas/editor/system/event_system.dart';
import '../../components/scale_indicator.dart';
import 'editor_mouse_event.dart';

class EditorInitialEventStack extends EventStack{
  @override
  void initialize() {
    addEvent(EditorDragEvent());
    addComponent(ComponentScaleIndicator());
    super.initialize();
  }
}