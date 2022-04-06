import 'package:flutter/cupertino.dart';
import 'package:math_canvas/editor/system/canvas_data.dart';
import 'package:math_canvas/editor/system/keyboard_system.dart';

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
  KeyboardEventData? key;

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

  void keyDown(KeyboardEventData key) {}

  void keyUp(KeyboardEventData key) {}
}

abstract class Event extends UserEventReceiver {
  //dynamic _postEventStackResult;
  late final EventStack _parentStack;
  bool _initialized = false;

  MathCanvasData get mathCanvasData => _parentStack._eventSystem.mathCanvasData;

  Event();

  /*
  void giveResult(dynamic result) {
    _postEventStackResult = result;
  }*/

  void startNewEvent(Event event) {
    _parentStack.addEvent(event);
  }

  void closeEvent() {
    _parentStack.removeEvent(this);
  }

  void startNewEventStack(EventStack eventStack, {String? tag}) {
    eventStack._starter = this;
    _parentStack.startNewEventStack(eventStack, tag: tag);
  }

  /*
  void startNewEventStackWithResult(
      EventStack eventStack, String tag) async {
    _postEventStackResult = null;
    startNewEventStack(eventStack, tag: tag);
     await Future.doWhile(() => _postEventStackResult == null);
    return _postEventStackResult;
  }*/

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

  void addComponent(EventSystemComponent component) =>
      _parentStack.addComponent(component);

  void removeComponent(EventSystemComponent component) =>
      _parentStack.removeComponent(component);

  List<T> findComponentsAsType<T>() => _parentStack.findComponentsAsType<T>();

  T? findComponentAsType<T>() => _parentStack.findComponentAsType<T>();

  TickerProvider getTickerProvider() => _parentStack.getTickerProvider();

  // Called when Upper EventStack was closed/
  void postEventStackClosed() {}

  void onEventStackResultReceived(dynamic result, String? tag) {}

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
  String? tag;
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

  void startNewEventStack(EventStack eventStack, {String? tag}) {
    _eventSystem.addEventStack(eventStack, tag: tag);
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
    _starter!.onEventStackResultReceived(result, tag);
    _starter!.postEventStackClosed();
  }

  List<T> findEventsInEventStack<T>() {
    List<T> list = [];
    for (Event e in _events) {
      if (e is T) list.add(e as T);
    }
    return list;
  }

  void addComponent(EventSystemComponent component) =>
      _eventSystem.addComponent(component);

  void removeComponent(EventSystemComponent component) =>
      _eventSystem.removeComponent(component);

  List<T> findComponentsAsType<T>() => _eventSystem.findComponentsAsType<T>();

  T? findComponentAsType<T>() => _eventSystem.findComponentAsType<T>();

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

  double get lastMx => _eventSystem.lastMx;

  double get lastMy => _eventSystem.lastMy;

  @override
  void mouseMove(double dx, double dy) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.mouseMove, dx: dx, dy: dy);
    for (var element in _events) {
      element.mouseMove(dx, dy);
    }
    curUserEvent = null;
  }

  @override
  void mouseDown(double dx, double dy) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.mouseDown, dx: dx, dy: dy);
    for (var element in _events) {
      element.mouseDown(dx, dy);
    }
    curUserEvent = null;
  }

  @override
  void mouseUp(double dx, double dy) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.mouseUp, dx: dx, dy: dy);
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
    for (var element in _events) {
      element.mouseWheel(scrollDelta, dx, dy);
    }
    curUserEvent = null;
  }

  @override
  void keyDown(KeyboardEventData key) {
    curUserEvent =
        UserEventData(userEventType: UserEventType.keyDown, key: key);
    for (var element in _events) {
      element.keyDown(key);
    }
    curUserEvent = null;
  }

  @override
  void keyUp(KeyboardEventData key) {
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

class EventSystemComponent extends UserEventReceiver {
  late EventSystem _eventSystem;

  MathCanvasData get mathCanvasData => _eventSystem.mathCanvasData;

  TickerProvider getTickerProvider() => _eventSystem.tickerProvider;
  double get lastMx => _eventSystem.lastMx;
  double get lastMy => _eventSystem.lastMy;

  void initialize() {}
  void dispose() {}
}

class EventSystem extends UserEventReceiver {
  TickerProvider tickerProvider;

  EventSystem(this.tickerProvider);

  final _eventStack = <EventStack>[];
  final _components = <EventSystemComponent>[];
  final MathCanvasData mathCanvasData = MathCanvasData();

  void addComponent(EventSystemComponent component) {
    component._eventSystem = this;
    _components.add(component);
    component.initialize();
  }

  void removeComponent(EventSystemComponent component) {
    component.dispose();
    _components.remove(component);
  }

  List<T> findComponentsAsType<T>() {
    List<T> list = [];
    for (EventSystemComponent e in _components) {
      if (e is T) list.add(e as T);
    }
    return list;
  }

  T? findComponentAsType<T>() {
    for (EventSystemComponent e in _components) {
      if (e is T) return (e as T);
    }
    return null;
  }

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

  void addEventStack(EventStack eventStack, {String? tag}) {
    eventStack._eventSystem = this;
    eventStack.tag = tag;
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
  double lastMx = 0;
  double lastMy = 0;

  @override
  void mouseEnterEditor() {
    getTopEventStack().mouseEnterEditor();
    for (EventSystemComponent esc in _components) {
      esc.mouseEnterEditor();
    }
  }

  @override
  void mouseExistEditor() {
    getTopEventStack().mouseExistEditor();
    for (EventSystemComponent esc in _components) {
      esc.mouseExistEditor();
    }
  }

  @override
  void mouseMove(double dx, double dy) {
    lastMx = dx;
    lastMy = dy;
    getTopEventStack().mouseMove(dx, dy);
    for (EventSystemComponent esc in _components) {
      esc.mouseMove(dx, dy);
    }
  }

  @override
  void mouseDown(double dx, double dy) {
    lastMx = dx;
    lastMy = dy;
    getTopEventStack().mouseDown(dx, dy);
    for (EventSystemComponent esc in _components) {
      esc.mouseDown(dx, dy);
    }
  }

  @override
  void mouseUp(double dx, double dy) {
    lastMx = dx;
    lastMy = dy;
    getTopEventStack().mouseUp(dx, dy);
    for (EventSystemComponent esc in _components) {
      esc.mouseUp(dx, dy);
    }
  }

  @override
  void mouseWheel(Offset scrollDelta, double dx, double dy) {
    lastMx = dx;
    lastMy = dy;
    getTopEventStack().mouseWheel(scrollDelta, dx, dy);
    for (EventSystemComponent esc in _components) {
      esc.mouseWheel(scrollDelta, dx, dy);
    }
  }

  @override
  void keyDown(KeyboardEventData key) {
    getTopEventStack().keyDown(key);
    for (EventSystemComponent esc in _components) {
      esc.keyDown(key);
    }
  }

  @override
  void keyUp(KeyboardEventData key) {
    getTopEventStack().keyUp(key);
    for (EventSystemComponent esc in _components) {
      esc.keyUp(key);
    }
  }
}
