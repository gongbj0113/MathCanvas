import 'package:flutter/material.dart';

import 'package:math_canvas/editor/system/event_system.dart';

import '../animated_value.dart';


class ComponentScaleIndicator extends EventSystemComponent{
  int id = -1;
  AnimatedValue<double>? scaleIndicatorOpacity;

  bool get isVisible => id != -1;

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

  void updateScaleIndicator(){
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
            Offset(lastMx - 40, lastMy - 35),
            local: false,
          );
        }

        mathCanvasData.editorData.finishDataChange();
      });
      id = mathCanvasData.editorData.attachWidgetForeground(
        buildScaleIndicator(mathCanvasData.editorData.scale),
        Offset(lastMx - 40, lastMy - 35),
        local: false,
      );
    } else {
      mathCanvasData.editorData.updateWidgetForeground(
        id,
        buildScaleIndicator(mathCanvasData.editorData.scale),
        Offset(lastMx - 40, lastMy - 35),
        local: false,
      );
    }
    scaleIndicatorOpacity!.value = 1.0;
    mathCanvasData.editorData.finishDataChange();
  }

}