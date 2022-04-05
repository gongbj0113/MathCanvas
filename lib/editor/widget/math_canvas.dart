import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HardwareKeyboard, KeyDownEvent, KeyUpEvent;
import 'package:math_canvas/editor/system/keyboard_system.dart';

import '../system/canvas_data.dart';
import '../system/event_system.dart';
import '../system/events/initial_stack/editor_initial_es.dart';

class MathCanvasWidget extends StatefulWidget {
  const MathCanvasWidget(this.width, this.height, {Key? key}) : super(key: key);
  final double width;
  final double height;

  @override
  State<MathCanvasWidget> createState() => _MathCanvasWidgetState();
}

class _MathCanvasWidgetState extends State<MathCanvasWidget>
    with TickerProviderStateMixin {
  late EventSystem _eventSystem;

  @override
  void initState() {
    super.initState();
    AnimationController(vsync: this, duration: const Duration(seconds: 1))
        .forward();

    _eventSystem = EventSystem(this);
    _eventSystem.addEventStack(EditorInitialEventStack());

    _eventSystem.mathCanvasData.editorData
        .attachDataChangedListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: widget.width,
      height: widget.height,
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _eventSystem.mouseWheel(event.scrollDelta, event.localPosition.dx,
                event.localPosition.dy);
          }
        },
        onPointerHover: (event) {
          _eventSystem.mouseMove(
              event.localPosition.dx, event.localPosition.dy);
        },
        onPointerMove: (event) {
          _eventSystem.mouseMove(
              event.localPosition.dx, event.localPosition.dy);
        },
        onPointerDown: (event) {
          _eventSystem.mouseDown(
              event.localPosition.dx, event.localPosition.dy);
        },
        onPointerUp: (event) {
          _eventSystem.mouseUp(event.localPosition.dx, event.localPosition.dy);
        },
        child: KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          autofocus: true,
          onKeyEvent: (keyEvent) {
            //print("");
            //print(keyEvent.logicalKey);
            if (keyEvent is KeyDownEvent) {
              _eventSystem.keyDown(keyEvent.physicalKey);
            } else if (keyEvent is KeyUpEvent) {
              KeyboardEventData a = KeyboardEventData(keyEvent);
              print(a.logicalString);
              //print("");
              //print(keyEvent);
              //print(HardwareKeyboard.instance.lockModesEnabled.toList());
              //print(HardwareKeyboard.instance.logicalKeysPressed);
              //print(keyEvent.logicalKey);
              _eventSystem.keyUp(keyEvent.physicalKey);
            }
          },
          child: MouseRegion(
            onEnter: (e) {
              _eventSystem.mouseEnterEditor();
            },
            onExit: (e) {
              _eventSystem.mouseExistEditor();
            },
            child: Stack(
              children: [
                CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _EditorGridBackground(
                      _eventSystem.mathCanvasData.editorData.x,
                      _eventSystem.mathCanvasData.editorData.y,
                      _eventSystem.mathCanvasData.editorData.scale),
                ),
                ...(_eventSystem.mathCanvasData.editorData
                    .getAdditionalWidgetBackground()),
                ..._eventSystem.mathCanvasData.equationData.map((eq) {
                  return StatefulBuilder(
                    builder: (context, setState) { // Todo : Optimization : Do not draw element that is out of screen.
                      eq.attachDataChangedListener(() => setState(() {}));
                      return Transform.translate(
                        offset: Offset(
                          ((eq.x - eq.rootElement.anchorPoint.x) - _eventSystem.mathCanvasData.editorData.x) *
                              _eventSystem.mathCanvasData.editorData.scale,
                          ((eq.y - eq.rootElement.anchorPoint.y) - _eventSystem.mathCanvasData.editorData.y) *
                              _eventSystem.mathCanvasData.editorData.scale,
                        ),
                        child: Transform.scale(
                          alignment: Alignment.topLeft,
                          scale: _eventSystem.mathCanvasData.editorData.scale,
                          child: CustomPaint(
                            size: Size(
                                eq.rootElement.width, eq.rootElement.height),
                            painter: _MathCanvasEquationPainter(eq),
                          ),
                        ),
                      );
                    },
                  );
                }),
                ...(_eventSystem.mathCanvasData.editorData
                    .getAdditionalWidgetForeground()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorGridBackground extends CustomPainter {
  double gridInterval;
  double x;
  double y;
  double scale;
  Color gridColor;

  _EditorGridBackground(this.x, this.y, this.scale,
      {this.gridInterval = 20, this.gridColor = Colors.grey});

  @override
  void paint(Canvas canvas, Size size) {
    double newInterval = gridInterval * scale;
    double xS = newInterval - (x * scale) % newInterval;
    double yS = newInterval - (y * scale) % newInterval;
    var p = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    //Todo : optimization when there's too many grid to draw.
    while (xS <= size.width) {
      canvas.drawLine(Offset(xS, 0), Offset(xS, size.height), p);
      xS += newInterval;
    }
    while (yS <= size.height) {
      canvas.drawLine(Offset(0, yS), Offset(size.width, yS), p);
      yS += newInterval;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MathCanvasEquationWidget extends StatefulWidget {
  const MathCanvasEquationWidget(this.mathCanvasEquationData, {Key? key})
      : super(key: key);
  final MathCanvasEquationData mathCanvasEquationData;

  @override
  State<MathCanvasEquationWidget> createState() =>
      _MathCanvasEquationWidgetState();
}

class _MathCanvasEquationWidgetState extends State<MathCanvasEquationWidget> {
  @override
  void initState() {
    widget.mathCanvasEquationData
        .attachDataChangedListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.mathCanvasEquationData.rootElement.width,
          widget.mathCanvasEquationData.rootElement.height),
      painter: _MathCanvasEquationPainter(widget.mathCanvasEquationData),
    );
  }
}

class _MathCanvasEquationPainter extends CustomPainter {
  final MathCanvasEquationData mathCanvasEquationData;

  _MathCanvasEquationPainter(this.mathCanvasEquationData);

  @override
  void paint(Canvas canvas, Size size) {
    mathCanvasEquationData.rootElement.render(canvas);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
