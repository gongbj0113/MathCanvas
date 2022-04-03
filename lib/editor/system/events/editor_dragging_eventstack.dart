import 'package:flutter/material.dart';
import 'package:math_canvas/editor/system/event_system.dart';

import '../animated_value.dart';

class EditorDraggingEventStack extends EventStack {
  double preMx;
  double preMy;

  EditorDraggingEventStack(this.preMx, this.preMy);

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

  Widget buildScaleIndicator(double scale, double mx, double my) {
    return Positioned(
      left: mx - 40,
      top: my - 35,
      child: Opacity(
        opacity:
            scaleIndicatorOpacity != null ? scaleIndicatorOpacity!.value : 0.0,
        child: Container(
          decoration: const ShapeDecoration(
            shape: StadiumBorder(),
            color: Colors.black54,
          ),
          width: 80,
          height: 30,
          alignment: Alignment.center,
          child: Text(
            "${(scale * 100).toInt()}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  int id = -1;
  AnimatedValue<double>? scaleIndicatorOpacity;

  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    //Todo : make scaling from center origin.
    mathCanvasData.editorData.scale -= scrollDelta.dy / 1000;

    if (id == -1) {
      scaleIndicatorOpacity = AnimatedValue<double>(
          initialValue: 0.01,
          vsync: getTickerProvider(),
          duration: const Duration(milliseconds: 500));
      scaleIndicatorOpacity!.addListener(() {
        if (scaleIndicatorOpacity!.value == 1.0) {
          scaleIndicatorOpacity!.value = 0.0;
        }
        if (scaleIndicatorOpacity!.value == 0.0) {
          scaleIndicatorOpacity!.dispose();
          scaleIndicatorOpacity = null;
          mathCanvasData.editorData.detachWidget(id);
          id = -1;
        } else {
          mathCanvasData.editorData.updateWidget(
              id,
              buildScaleIndicator(
                  mathCanvasData.editorData.scale, lastMouseX, lastMouseY));
        }

        mathCanvasData.editorData.finishDataChange();
      });
      id = mathCanvasData.editorData.attachWidget(
        buildScaleIndicator(mathCanvasData.editorData.scale, dx, dy),
      );
    } else {
      mathCanvasData.editorData.updateWidget(
          id, buildScaleIndicator(mathCanvasData.editorData.scale, dx, dy));
    }
    scaleIndicatorOpacity!.value = 1.0;
    mathCanvasData.editorData.finishDataChange();
    print(scrollDelta);
  }
}
