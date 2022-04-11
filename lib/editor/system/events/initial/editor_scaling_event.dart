import 'dart:ui';

import 'package:math_canvas/editor/system/event_system.dart';

import '../../components/scale_indicator_component.dart';

class EditorScalingEvent extends Event{
  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    mathCanvasData.editorData.scale -= scrollDelta.dy / 1000;
    findComponentAsType<ComponentScaleIndicator>()!.updateScaleIndicator();
  }
}