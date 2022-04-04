import 'package:flutter/material.dart'
    show
        Alignment,
        Colors,
        Container,
        Offset,
        Opacity,
        Positioned,
        ShapeDecoration,
        StadiumBorder,
        Text,
        TextStyle,
        Widget;
import 'package:math_canvas/editor/system/animated_value.dart';
import 'package:math_canvas/editor/system/components/scale_indicator.dart';
import 'package:math_canvas/editor/system/events/initial_stack/editor_dragging_eventstack.dart';
import 'package:math_canvas/editor/system/event_system.dart';

class EditorDragEvent extends Event {
  EditorDragEvent();

  bool m_down = false;
  double preMx = 0;
  double preMy = 0;

  @override
  void mouseDown(double dx, double dy) {
    m_down = true;
    preMx = dx;
    preMy = dy;
  }

  @override
  void mouseExistEditor() {
    m_down = false;
  }

  @override
  void mouseUp(double dx, double dy) {
    m_down = false;
  }

  @override
  void mouseMove(double dx, double dy) {
    if (m_down) {
      var deltaX = dx - preMx;
      var deltaY = dy - preMy;
      if (deltaY.abs() > 0.1 || deltaX.abs() > 0.1) {
        startNewEventStack(EditorDraggingEventStack(preMx, preMy));
      }
    }
  }

  /*
  Widget buildScaleIndicator(double scale) {
    return Opacity(
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
    );
  }

  int id = -1;
  AnimatedValue<double>? scaleIndicatorOpacity;
*/

  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    mathCanvasData.editorData.scale -= scrollDelta.dy / 1000;
    findComponentAsType<ComponentScaleIndicator>()!.updateScaleIndicator();
/*
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
          mathCanvasData.editorData.detachWidgetForeground(id);
          id = -1;
        } else {
          mathCanvasData.editorData.updateWidgetForeground(
            id,
            buildScaleIndicator(mathCanvasData.editorData.scale),
            Offset(lastMouseX - 40, lastMouseY - 35),
            localPosition: false,
          );
        }

        mathCanvasData.editorData.finishDataChange();
      });
      id = mathCanvasData.editorData.attachWidgetForeground(
        buildScaleIndicator(mathCanvasData.editorData.scale),
        Offset(dx - 40, dy - 35),
        localPosition: false,
      );
    } else {
      mathCanvasData.editorData.updateWidgetForeground(
        id,
        buildScaleIndicator(mathCanvasData.editorData.scale),
        Offset(dx - 40, dy - 35),
        localPosition: false,
      );
    }
    scaleIndicatorOpacity!.value = 1.0;*/
    mathCanvasData.editorData.finishDataChange();
    print(scrollDelta);
  }
}
