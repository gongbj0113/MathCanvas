import 'package:flutter/material.dart';
import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/event_system.dart';

class MathCanvasWidget extends StatefulWidget {
  const MathCanvasWidget(this.width, this.height, {Key? key}) : super(key: key);
  final double width;
  final double height;

  @override
  State<MathCanvasWidget> createState() => _MathCanvasWidgetState();
}

class _MathCanvasWidgetState extends State<MathCanvasWidget> {
  late EventSystem _eventSystem;

  @override
  void initState() {
    _eventSystem = EventSystem();
    _eventSystem.mathCanvasData.editorData
        .attachDataChangedListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(widget.width, widget.height),
            painter: _EditorGridBackground(
                _eventSystem.mathCanvasData.editorData.x,
                _eventSystem.mathCanvasData.editorData.y,
                _eventSystem.mathCanvasData.editorData.scale),
          ),
          ..._eventSystem.mathCanvasData.equationData.map((eq) {
            return Positioned(
              top: ((eq.x - (eq.rootElement.anchorPoint.x)) -
                      _eventSystem.mathCanvasData.editorData.x) *
                  _eventSystem.mathCanvasData.editorData.scale,
              left: (eq.y - (eq.rootElement.anchorPoint.y)) -
                  (_eventSystem.mathCanvasData.editorData.y) *
                      _eventSystem.mathCanvasData.editorData.scale,
              child: Transform.scale(
                origin: const Offset(0, 0),
                scale: _eventSystem.mathCanvasData.editorData.scale,
                child: CustomPaint(
                  size: Size(eq.rootElement.width, eq.rootElement.height),
                  painter: _MathCanvasEquationPainter(eq),
                ),
              ),
            );
          }),
        ],
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
    double x_s = newInterval - (x * scale) % newInterval;
    double y_s = newInterval - (y * scale) % newInterval;
    var p = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    //Todo : optimization when there's too many grid to draw.
    while (x_s <= size.width) {
      canvas.drawLine(Offset(x_s, 0), Offset(x_s, size.height), p);
      x_s += newInterval;
    }
    while (y_s <= size.width) {
      canvas.drawLine(Offset(0, y_s), Offset(size.width, y_s), p);
      y_s += newInterval;
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
