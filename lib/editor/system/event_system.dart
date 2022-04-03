import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:math_canvas/editor/system/canvas_data.dart';

enum UserEventType {
  mouseEnterEditor,
  mouseExistEditor,
  mouseMove,
  mouseDown,
  mouseUp,
  mouseWheel,
  keyDown,
  keyUp
}

class UserEventData {
  UserEventType userEventType;
  double? dx;
  double? dy;
  Offset? scrollDelta;
  PhysicalKeyboardKey? key;

  UserEventData(
      {required this.userEventType,
      this.dx,
      this.dy,
      this.scrollDelta,
      this.key});

  void sendEvent(UserEventReceiver userEventReceiver) {
    if (userEventType == UserEventType.mouseEnterEditor) {
      userEventReceiver.mouseEnterEditor();
    } else if (userEventType == UserEventType.mouseExistEditor) {
      userEventReceiver.mouseExistEditor();
    } else if (userEventType == UserEventType.mouseDown) {
      userEventReceiver.mouseDown(dx!, dy!);
    } else if (userEventType == UserEventType.mouseMove) {
      userEventReceiver.mouseMove(dx!, dy!);
    } else if (userEventType == UserEventType.mouseUp) {
      userEventReceiver.mouseUp(dx!, dy!);
    } else if (userEventType == UserEventType.mouseWheel) {
      userEventReceiver.mouseWheel(scrollDelta!, dx!, dy!);
    } else if (userEventType == UserEventType.keyDown) {
      userEventReceiver.keyDown(key!);
    } else if (userEventType == UserEventType.keyUp) {
      userEventReceiver.keyUp(key!);
    }
  }
}

class UserEventReceiver {
  void mouseEnterEditor() {}

  void mouseExistEditor() {}

  void mouseMove(double dx, double dy) {}

  void mouseDown(double dx, double dy) {}

  void mouseUp(double dx, double dy) {}

  void mouseWheel(Offset scrollDelta, double dx, double dy) {}

  void keyDown(PhysicalKeyboardKey key) {}

  void keyUp(PhysicalKeyboardKey key) {}
}

abstract class Event extends UserEventReceiver {
  dynamic _postEventStackResult;
  late final EventStack _parentStack;
  bool _initialized = false;

  MathCanvasData get mathCanvasData => _parentStack._eventSystem.mathCanvasData;

  Event();

  void giveResult(dynamic result) {
    _postEventStackResult = result;
  }

  void startNewEvent(Event event) {
    _parentStack.addEvent(event);
  }

  void closeEvent() {
    _parentStack.removeEvent(this);
  }

  void startNewEventStack(EventStack eventStack) {
    eventStack._starter = this;
    _parentStack.startNewEventStack(eventStack);
  }

  Future<dynamic> startNewEventStackWithResult(EventStack eventStack) async {
    _postEventStackResult = null;
    startNewEventStack(eventStack);
    await Future.doWhile(() => _postEventStackResult == null);
    return _postEventStackResult;
  }

  // Pop the Event Stack.
  void closeEventStack(bool handOverUserEvent) {
    _parentStack.closeEventStack(handOverUserEvent);
  }

  void closeEventStackWithResult(dynamic result, bool handOverUserEvent) {
    _parentStack.closeEventStackWithResult(result, handOverUserEvent);
  }

  void startNewDataEvent(DataEvent dataEvent) {
    _parentStack.startNewDataEvent(dataEvent);
  }

  List<T> findEventsInEventStack<T>() {
    return _parentStack.findEventsInEventStack<T>();
  }

  TickerProvider getTickerProvider() => _parentStack.getTickerProvider();

  // Called when Upper EventStack was closed/
  void postEventStackClosed() {}

  bool get isInitialized => _initialized;
  double get lastMouseX => _parentStack.lastMx;
  double get lastMouseY => _parentStack.lastMy;

  void initialize() {
    _initialized = true;
  }

  void dispose() {
    _initialized = false;
  }
}

class EventStack extends UserEventReceiver {
  late final EventSystem _eventSystem;
  Event? _starter; // The Event started this event stack.
  UserEventData? curUserEvent;


  final _events = <Event>[];

  void addEvent(Event event) {
    event._parentStack = this;
    _events.add(event);
    event.initialize();
  }

  void startNewDataEvent(DataEvent dataEvent) {
    _eventSystem.addDataEvent(dataEvent);
  }

  void removeEvent(Event event) {
    event.dispose();
    _events.remove(event);
  }

  void startNewEventStack(EventStack eventStack) {
    _eventSystem.addEventStack(eventStack);
  }

  void closeEventStack(bool handOverUserEvent) {
    if (handOverUserEvent && curUserEvent != null) {
      _eventSystem.popEventStackWithUserEvent(curUserEvent!);
    } else {
      _eventSystem.popEventStack();
    }
    _starter?.postEventStackClosed();
  }

  void closeEventStackWithResult(dynamic result, bool handOverUserEvent) {
    assert(_starter != null);
    if (handOverUserEvent && curUserEvent != null) {
      _eventSystem.popEventStackWithUserEvent(curUserEvent!);
    } else {
      _eventSystem.popEventStack();
    }
    _starter!.giveResult(result);
    _starter!.postEventStackClosed();
  }

  List<T> findEventsInEventStack<T>() {
    List<T> list = [];
    for (Event e in _events) {
      if (e is T) list.add(e as T);
    }
    return list;
  }

  TickerProvider getTickerProvider() => _eventSystem.tickerProvider;

  void initialize() {
    for (var element in _events) {
      if (!element.isInitialized) element.initialize();
    }
  }

  void dispose() {
    for (var element in _events) {
      element.dispose();
    }
  }

  // Handle User Events
  @override
  void mouseEnterEditor() {
    curUserEvent = UserEventData(userEventType: UserEventType.mouseEnterEditor);
    for (var element in _events) {
      element.mouseEnterEditor();
    }
    curUserEvent = null;
  }

  @override
  void mouseExistEditor() {
    curUserEvent = UserEventData(userEventType: UserEventType.mouseExistEditor);
    for (var element in _events) {
      element.mouseExistEditor();
    }
    curUserEvent = null;
  }

  double lastMx = 0;
  double lastMy = 0;

  @override
  void mouseMove(double dx, double dy) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.mouseMove, dx: dx, dy: dy);
    lastMx = dx;
    lastMy = dy;
    for (var element in _events) {
      element.mouseMove(dx, dy);
    }
    curUserEvent = null;
  }

  @override
  void mouseDown(double dx, double dy) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.mouseDown, dx: dx, dy: dy);
    lastMx = dx;
    lastMy = dy;
    for (var element in _events) {
      element.mouseDown(dx, dy);
    }
    curUserEvent = null;
  }

  @override
  void mouseUp(double dx, double dy) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.mouseUp, dx: dx, dy: dy);
    lastMx = dx;
    lastMy = dy;
    for (var element in _events) {
      element.mouseUp(dx, dy);
    }
    curUserEvent = null;
  }

  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    curUserEvent = UserEventData(
        userEventType: UserEventType.mouseWheel,
        scrollDelta: scrollDelta,
        dx: dx,
        dy: dy);
    lastMx = dx;
    lastMy = dy;
    for (var element in _events) {
      element.mouseWheel(scrollDelta, dx, dy);
    }
    curUserEvent = null;
  }

  @override
  void keyDown(PhysicalKeyboardKey key) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.keyDown, key: key);
    for (var element in _events) {
      element.keyDown(key);
    }
    curUserEvent = null;
  }

  @override
  void keyUp(PhysicalKeyboardKey key) {
    curUserEvent = UserEventData(userEventType: UserEventType.keyUp, key: key);
    for (var element in _events) {
      element.keyUp(key);
    }
    curUserEvent = null;
  }
}

abstract class DataEvent {
  void evaluate(MathCanvasData mathCanvasData);

  void undo(MathCanvasData mathCanvasData);
}

class EventSystem extends UserEventReceiver {
  TickerProvider tickerProvider;

  EventSystem(this.tickerProvider);

  final _eventStack = <EventStack>[];
  final MathCanvasData mathCanvasData = MathCanvasData();

  //Redo & Undo
  final _dataEvent = <DataEvent>[];
  bool _availableRedo = false;
  int _curIndex = 0;

  bool isRedoAvailable() => _availableRedo;

  bool isUndoAvailable() {
    if (_availableRedo) {
      return _curIndex > 0;
    } else {
      return _dataEvent.isNotEmpty;
    }
  }

  void addDataEvent(DataEvent dataEvent) {
    if (_availableRedo) {
      var r = _dataEvent.length - _curIndex;
      for (int i = 0; i < r; i++) {
        _dataEvent.removeAt(_dataEvent.length - 1);
      }
      _availableRedo = false;
    }
    _dataEvent.add(dataEvent);
    dataEvent.evaluate(mathCanvasData);
  }

  void undoDataEvent() {
    assert(isUndoAvailable());
    if (_availableRedo) {
      _curIndex--;
      _dataEvent[_curIndex].undo(mathCanvasData);
    } else {
      _dataEvent.last.undo(mathCanvasData);
      _availableRedo = true;
      _curIndex = _dataEvent.length - 1;
    }
  }

  void redoDataEvent() {
    assert(isRedoAvailable());
    _dataEvent[_curIndex].evaluate(mathCanvasData);
    _curIndex++;
    if (_curIndex >= _dataEvent.length) {
      _availableRedo = false;
    }
  }

  void addEventStack(EventStack eventStack) {
    eventStack._eventSystem = this;
    _eventStack.add(eventStack);
    eventStack.initialize();
  }

  // Return the Top EventStack.
  EventStack getTopEventStack() => _eventStack.last;

  // Remove the Top EventStack and return it.
  EventStack popEventStack() {
    assert(_eventStack.length >= 2);
    var last = _eventStack.last;
    last.dispose();
    _eventStack.removeAt(_eventStack.length - 1);

    return last;
  }

  EventStack popEventStackWithUserEvent(UserEventData userEventData) {
    var popped = popEventStack();
    userEventData.sendEvent(_eventStack.last);
    return popped;
  }

  // Send Events to the Top EventStack
  @override
  void mouseEnterEditor() {
    getTopEventStack().mouseEnterEditor();
  }

  @override
  void mouseExistEditor() {
    getTopEventStack().mouseExistEditor();
  }

  @override
  void mouseMove(double dx, double dy) {
    getTopEventStack().mouseMove(dx, dy);
  }

  @override
  void mouseDown(double dx, double dy) {
    getTopEventStack().mouseDown(dx, dy);
  }

  @override
  void mouseUp(double dx, double dy) {
    getTopEventStack().mouseUp(dx, dy);
  }

  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    getTopEventStack().mouseWheel(scrollDelta, dx, dy);
  }

  @override
  void keyDown(PhysicalKeyboardKey key) {
    getTopEventStack().keyDown(key);
  }

  @override
  void keyUp(PhysicalKeyboardKey key) {
    getTopEventStack().keyUp(key);
  }
}
