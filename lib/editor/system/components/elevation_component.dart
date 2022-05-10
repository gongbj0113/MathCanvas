import 'dart:math';
import 'dart:ui' show Offset, PathMetric;
import 'package:flutter/material.dart';
import 'package:math_canvas/editor/system/canvas_data.dart';

import 'package:math_canvas/editor/system/event_system.dart';
import 'package:tuple/tuple.dart';
import '../animated_value.dart';
import 'cursor_component.dart';

class ComponentElevation extends EventSystemComponent {
  int? _elevatedCursorWidgetId;
  AnimatedValue<Offset>? _elevatedCursorPosition;

  int? _hoveredBackgroundWidgetId;

  List<Tuple2<MathCanvasEquationData, int>> evaluatedEquations = [];

  void elevateEquation(MathCanvasEquationData eq,
      {bool finishDataChange = true,
      double shadowStrength = 1.0,
      VoidCallback? onEndShadowLerp}) {
    for (var item in evaluatedEquations) {
      if (item.item1 == eq) {
        mathCanvasData.editorData.updateWidgetBackground(
          item.item2,
          _EquationElevationBackground(
            true,
            eq,
            item.item2,
            mathCanvasData,
            shadow: shadowStrength,
            onEndShadowLerp: onEndShadowLerp,
          ),
          Offset(
            eq.localX - MathCanvasEquationData.outlineMargin,
            eq.localY - MathCanvasEquationData.outlineMargin,
          ),
        );
        if (finishDataChange) mathCanvasData.editorData.finishDataChange();
        return;
      }
    }
    int newId = mathCanvasData.editorData.attachWidgetBackground(
      _EquationElevationBackground(
        true,
        eq,
        mathCanvasData.editorData.getNextId(),
        mathCanvasData,
      ),
      Offset(
        eq.localX - MathCanvasEquationData.outlineMargin,
        eq.localY - MathCanvasEquationData.outlineMargin,
      ),
    );
    evaluatedEquations.add(Tuple2(eq, newId));
    if (finishDataChange) mathCanvasData.editorData.finishDataChange();
  }

  void dismissElevatedEquation(MathCanvasEquationData eq,
      {bool finishDataChange = true}) {
    for (var item in evaluatedEquations) {
      if (item.item1 == eq) {
        mathCanvasData.editorData.updateWidgetBackground(
          item.item2,
          _EquationElevationBackground(
            false,
            eq,
            item.item2,
            mathCanvasData,
            onDisappear: () {
              mathCanvasData.editorData.detachWidgetBackground(item.item2);
              mathCanvasData.editorData.finishDataChange();
            },
          ),
          Offset(
            eq.localX - MathCanvasEquationData.outlineMargin,
            eq.localY - MathCanvasEquationData.outlineMargin,
          ),
        );
        evaluatedEquations.remove(item);
        if (finishDataChange) mathCanvasData.editorData.finishDataChange();
        return;
      }
    }
    print("There is no requested MathCanvasEquationData that is elevated");
  }

  void hoverEquation(MathCanvasEquationData eq) {
    if (_hoveredBackgroundWidgetId != null) {
      mathCanvasData.editorData
          .detachWidgetBackground(_hoveredBackgroundWidgetId!);
    }
    _hoveredBackgroundWidgetId =
        mathCanvasData.editorData.attachWidgetBackground(
      _EquationHoveredBackground(
        eq,
        mathCanvasData.editorData.getNextId(),
        mathCanvasData,
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

  void dismissHoverEquations() {
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
  final int durationMilli;
  final double dashLength;
  final double gapPercent;
  final MathCanvasEquationData eq;
  final MathCanvasData mathCanvasData;
  final int id;

  const _EquationHoveredBackground(this.eq, this.id, this.mathCanvasData,
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

  void positionChanged() {
    widget.mathCanvasData.editorData.updateWidgetBackground(
      widget.id,
      _EquationHoveredBackground(
        widget.eq,
        widget.id,
        widget.mathCanvasData,
        durationMilli: widget.durationMilli,
        dashLength: widget.dashLength,
        gapPercent: widget.gapPercent,
      ),
      Offset(
        widget.eq.localX - MathCanvasEquationData.outlineMargin / 2,
        widget.eq.localY - MathCanvasEquationData.outlineMargin / 2,
      ),
    );
    widget.mathCanvasData.editorData.finishDataChange();
  }

  void repaint() {
    setState(() {});
  }

  @override
  void initState() {
    widget.eq.addRepaintListener(repaint);
    widget.eq.addPositionChangedListener(positionChanged);
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
    widget.eq.removeRepaintListener(repaint);
    widget.eq.removePositionChangedListener(positionChanged);
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        widget.eq.rootElement.width + MathCanvasEquationData.outlineMargin,
        widget.eq.rootElement.height + MathCanvasEquationData.outlineMargin,
      ),
      painter: _EquationHoveredBackgroundPaint(
        widget.eq.rootElement.width + MathCanvasEquationData.outlineMargin,
        widget.eq.rootElement.height + MathCanvasEquationData.outlineMargin,
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

class _EquationElevationBackground extends StatefulWidget {
  final bool visibility;
  final MathCanvasEquationData eq;
  final VoidCallback? onDisappear;
  final VoidCallback? onEndShadowLerp;
  final int id;
  final MathCanvasData mathCanvasData;
  final double shadow;

  const _EquationElevationBackground(
      this.visibility, this.eq, this.id, this.mathCanvasData,
      {this.onDisappear, this.onEndShadowLerp, this.shadow = 1.0});

  @override
  State<_EquationElevationBackground> createState() =>
      _EquationElevationBackgroundState();
}

class _EquationElevationBackgroundState
    extends State<_EquationElevationBackground> with TickerProviderStateMixin {
  late AnimationController acOpacity;
  late AnimationController acShadow;

  late Animation<double> tweenOpacity;
  late Animation<double> tweenShadow;

  void positionChanged() {
    widget.mathCanvasData.editorData.updateWidgetBackground(
      widget.id,
      _EquationElevationBackground(
        true,
        widget.eq,
        widget.id,
        widget.mathCanvasData,
        shadow: widget.shadow,
      ),
      Offset(
        widget.eq.localX - MathCanvasEquationData.outlineMargin,
        widget.eq.localY - MathCanvasEquationData.outlineMargin,
      ),
    );
    widget.mathCanvasData.editorData.finishDataChange();
  }

  void repaint() {
    setState(() {});
  }

  @override
  void dispose() {
    acOpacity.dispose();
    acShadow.dispose();
    widget.eq.removePositionChangedListener(positionChanged);
    widget.eq.removeRepaintListener(repaint);
    super.dispose();
  }

  @override
  void initState() {
    widget.eq.addPositionChangedListener(positionChanged);
    widget.eq.addRepaintListener(repaint);

    acOpacity = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    acShadow = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    acOpacity.value = 0;
    acShadow.value = 0;

    tweenOpacity = Tween(begin: 0.0, end: 1.0).animate(acOpacity);
    tweenOpacity.addListener(() {
      setState(() {});
      if (tweenOpacity.value == 0 && widget.visibility == false) {
        if (widget.onDisappear != null) {
          widget.onDisappear!();
        }
      }
    });

    tweenShadow = Tween(begin: 0.0, end: widget.shadow).animate(acShadow);
    tweenShadow.addListener(() {
      setState(() {});
      if (widget.onEndShadowLerp != null) {
        widget.onEndShadowLerp!();
      }
    });

    acOpacity.forward();
    acShadow.forward();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _EquationElevationBackground oldWidget) {
    if (widget.eq != oldWidget.eq) {
      tweenOpacity = Tween(
              begin: widget.visibility ? 1.0 : 0.0,
              end: widget.visibility ? 1.0 : 0.0)
          .animate(acOpacity);
      tweenShadow =
          Tween(begin: widget.shadow, end: widget.shadow).animate(acShadow);
      oldWidget.eq.removePositionChangedListener(positionChanged);
      oldWidget.eq.removeRepaintListener(repaint);
      widget.eq.addPositionChangedListener(positionChanged);
      widget.eq.addRepaintListener(repaint);
    } else {
      tweenOpacity =
          Tween(begin: tweenOpacity.value, end: widget.visibility ? 1.0 : 0.0)
              .animate(acOpacity);
      acOpacity.reset();
      acOpacity.forward();

      tweenShadow =
          Tween(begin: tweenShadow.value, end: widget.shadow).animate(acShadow);
      acShadow.reset();
      acShadow.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: tweenOpacity.value,
      child: Container(
        width: widget.eq.rootElement.width +
            MathCanvasEquationData.outlineMargin * 2,
        height: widget.eq.rootElement.height +
            MathCanvasEquationData.outlineMargin * 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(180),
              blurRadius: 10 * tweenShadow.value,
              spreadRadius: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}
