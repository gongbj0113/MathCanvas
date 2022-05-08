import 'package:flutter/material.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import '../../components/scale_indicator_component.dart';

class EditorMovingEventStack extends EventStack {
  double preMx;
  double preMy;

  EditorMovingEventStack(this.preMx, this.preMy);

  @override
  void initialize() {
    addEvent(_EditorDraggingEvent(preMx, preMy));
    super.initialize();
  }
}

class _EditorDraggingEvent extends Event {
  double preMx;
  double preMy;

  _EditorDraggingEvent(this.preMx, this.preMy);

  double preEx = 0;
  double preEy = 0;

  @override
  void initialize() {
    preEx = mathCanvasData.editorData.x;
    preEy = mathCanvasData.editorData.y;
    super.initialize();
  }

  @override
  void mouseExistEditor() {
    closeEventStack(true);
  }

  @override
  void mouseUp(double dx, double dy) {
    closeEventStack(true);
  }

  @override
  void mouseMove(double dx, double dy) {
    var deltaX = dx - preMx;
    var deltaY = dy - preMy;
    mathCanvasData.editorData.x =
        preEx - deltaX / mathCanvasData.editorData.scale;
    mathCanvasData.editorData.y =
        preEy - deltaY / mathCanvasData.editorData.scale;
    mathCanvasData.editorData.finishDataChange();
  }

  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    //Todo : make scaling from center origin.
    mathCanvasData.editorData.scale -= scrollDelta.dy / 1000;
    findComponentAsType<ComponentScaleIndicator>()!.updateScaleIndicator();
    mathCanvasData.editorData.finishDataChange();
  }
}

class EditorScalingEvent extends Event{
  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    mathCanvasData.editorData.scale -= scrollDelta.dy / 1000;
    findComponentAsType<ComponentScaleIndicator>()!.updateScaleIndicator();
  }
}