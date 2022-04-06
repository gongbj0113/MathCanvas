import 'package:math_canvas/editor/system/element_system.dart';
import 'package:math_canvas/editor/system/event_system.dart';
import 'package:flutter/material.dart';
import '../canvas_data.dart';

class CursorPosition {
  CursorPosition(this.rootEquation, this.index);

  MathCanvasEquationData rootEquation;
  List<int> index;

  Offset getLocalPosition() {
    ElementLayout parent = rootEquation.rootElement as ElementLayout;
    double localX = rootEquation.localX;
    double localY = rootEquation.localY;

    for (int i = 0; i < index.length - 1; i++) {
      localX += parent.childElements[index[i]].position.x;
      localY += parent.childElements[index[i]].position.y;
      parent = parent.childElements[index[i]].children! as ElementLayout;
    }
    var lastOffset = parent.getAnchorPosition(index.last);

    return Offset(localX + lastOffset.dx, localY + lastOffset.dy);
  }

  double getFontSize() {
    ElementLayout parent = rootEquation.rootElement as ElementLayout;
    for (int i = 0; i < index.length - 1; i++) {
      parent = parent.childElements[index[i]].children! as ElementLayout;
    }

    return parent.elementFontOption.size;
  }
}

enum CursorStatus { unfocused, focused, selection }

class ComponentCursor extends EventSystemComponent {
  CursorStatus _status = CursorStatus.unfocused;

  CursorStatus get status => _status;

  CursorWidget? _cursorWidget;
  int? _cursorWidgetId;
  CursorPosition? pos;

  CursorPosition? start;
  CursorPosition? end;

  void focusTo(CursorPosition pos) {
    if (_status == CursorStatus.focused) {
      mathCanvasData.editorData.updateWidgetForeground(
        _cursorWidgetId!,
        _cursorWidget!,
        pos.getLocalPosition(),
        local: true,
      );
    } else {
      _status = CursorStatus.focused;
      _cursorWidget = CursorWidget(fontSize: pos.getFontSize());
      _cursorWidgetId = mathCanvasData.editorData.attachWidgetForeground(
        _cursorWidget!,
        pos.getLocalPosition(),
        local: true,
      );
      this.pos = pos;
    }
  }

  void unFocus(){
    if(status == CursorStatus.focused){
      _status = CursorStatus.unfocused;
      mathCanvasData.editorData.detachWidgetForeground(_cursorWidgetId!);
    }else if(status == CursorStatus.selection){
      //TOdo : write selection code.
    }
  }
}

class CursorWidget extends StatefulWidget {
  final double fontSize;
  final Color color;

  const CursorWidget(
      {required this.fontSize, this.color = Colors.black, Key? key})
      : super(key: key);

  @override
  State<CursorWidget> createState() => _CursorWidgetState();
}

class _CursorWidgetState extends State<CursorWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation _tweenAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _tweenAnimation =
        CurveTween(curve: Curves.easeInOut).animate(_animationController);
    _animationController.addListener(() {
      setState(() {});
    });
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-1.5, -widget.fontSize / 2),
      child: Opacity(
        opacity: _tweenAnimation.value,
        child: Container(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: widget.color,
          ),
          width: 3,
          height: widget.fontSize,
        ),
      ),
    );
  }
}
