import 'dart:math';
import 'dart:ui' show Offset, PathMetric;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:math_canvas/editor/system/canvas_data.dart';

import 'package:math_canvas/editor/system/event_system.dart';
import '../animated_value.dart';
import 'cursor_component.dart';

class ComponentElevation extends EventSystemComponent {
  int? _elevatedCursorWidgetId;
  AnimatedValue<Offset>? _elevatedCursorPosition;

  int? _hoveredBackgroundWidgetId;

  void hoverEquationBackground(MathCanvasEquationData eq) {
    if (_hoveredBackgroundWidgetId != null) {
      mathCanvasData.editorData
          .detachWidgetBackground(_hoveredBackgroundWidgetId!);
    }
    _hoveredBackgroundWidgetId =
        mathCanvasData.editorData.attachWidgetBackground(
      _EquationHoveredBackground(
        eq.rootElement.width + MathCanvasEquationData.outlineMargin,
        eq.rootElement.height + MathCanvasEquationData.outlineMargin,
        durationMilli: 800,
        dashLength: 4.2,
        gapPercent: 1.3,
      ),
      Offset(
        eq.localX - MathCanvasEquationData.outlineMargin / 2,
        eq.localY - MathCanvasEquationData.outlineMargin / 2,
      ),
    );
    mathCanvasData.editorData.finishDataChange();
  }

  void dismissHoverEquationBackgrounds() {
    if (_hoveredBackgroundWidgetId != null) {
      mathCanvasData.editorData
          .detachWidgetBackground(_hoveredBackgroundWidgetId!);
    }
    _hoveredBackgroundWidgetId = null;
  }

  void showElevatedCursor(CursorPosition pos) {
    /*if (status == CursorStatus.focused && this.pos == pos) {
      hideElevatedCursor();
      return;
    }*/

    if (_elevatedCursorWidgetId != null) {
      _elevatedCursorPosition!.value = pos.getLocalPosition();
    } else {
      _elevatedCursorPosition = AnimatedValue(
          initialValue: pos.getLocalPosition(),
          duration: const Duration(milliseconds: 70),
          vsync: getTickerProvider());
      _elevatedCursorWidgetId =
          mathCanvasData.editorData.attachWidgetForeground(
        CursorWidget(
          fontSize: pos.getFontSize(),
          color: Colors.teal,
          elevated: true,
        ),
        pos.getLocalPosition(),
        local: true,
      );
      _elevatedCursorPosition!.addListener(() {
        mathCanvasData.editorData.updateWidgetForeground(
          _elevatedCursorWidgetId!,
          CursorWidget(
            fontSize: pos.getFontSize(),
            color: Colors.teal,
            elevated: true,
          ),
          _elevatedCursorPosition!.value,
          local: true,
        );
        mathCanvasData.editorData.finishDataChange();
      });
    }
    mathCanvasData.editorData.finishDataChange();
  }

  void hideElevatedCursor() {
    if (_elevatedCursorWidgetId != null) {
      mathCanvasData.editorData
          .detachWidgetForeground(_elevatedCursorWidgetId!);
      _elevatedCursorWidgetId = null;
      _elevatedCursorPosition!.dispose();
      _elevatedCursorPosition = null;
    }
    mathCanvasData.editorData.finishDataChange();
  }
}

class _EquationHoveredBackground extends StatefulWidget {
  final double width;
  final double height;
  final int durationMilli;
  final double dashLength;
  final double gapPercent;

  const _EquationHoveredBackground(this.width, this.height,
      {this.durationMilli = 500,
      this.dashLength = 3.0,
      this.gapPercent = 1,
      Key? key})
      : super(key: key);

  @override
  State<_EquationHoveredBackground> createState() =>
      _EquationHoveredBackgroundState();
}

class _EquationHoveredBackgroundState extends State<_EquationHoveredBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.durationMilli));
    animationController.addListener(() {
      setState(() {});
    });
    animationController.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: _EquationHoveredBackgroundPaint(
        widget.width,
        widget.height,
        offset: animationController.value,
        dashLength: widget.dashLength,
        gapPercent: widget.gapPercent,
      ),
    );
  }
}

class _EquationHoveredBackgroundPaint extends CustomPainter {
  final double width;
  final double height;
  final double radius;
  final double offset; //0.0 ~ 1.0
  final double strokeWidth;
  final Color color;
  final double dashLength;
  final double gapPercent;

  _EquationHoveredBackgroundPaint(this.width, this.height,
      {required this.offset,
      this.dashLength = 2.0,
      this.radius = 2.0,
      this.strokeWidth = 1.0,
      this.gapPercent = 1.0,
      this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final Path rrectPath = Path()
      ..addRRect(RRect.fromLTRBR(0, 0, width, height, Radius.circular(radius)));

    final Path dashed = Path();
    for (final PathMetric metric in rrectPath.computeMetrics()) {
      final length = metric.length;
      final lengthSingleSet =
          length / (length ~/ (dashLength * (1 + gapPercent)));

      double offsetLength = lengthSingleSet * offset;
      if (offset > gapPercent / (gapPercent + 1)) {
        dashed.addPath(
          metric.extractPath(
            0,
            dashLength *
                (offset - gapPercent / (gapPercent + 1)) /
                (1 - gapPercent / (gapPercent + 1)),
          ),
          Offset.zero,
        );
      }
      while (offsetLength < length) {
        dashed.addPath(
            metric.extractPath(
                offsetLength, min(offsetLength + dashLength, length)),
            Offset.zero);
        offsetLength += lengthSingleSet;
      }
    }

    Paint paint = Paint()
      ..strokeWidth = 1
      ..color = color
      ..style = PaintingStyle.stroke;

    //canvas.drawPath(rrectPath, paint);
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}