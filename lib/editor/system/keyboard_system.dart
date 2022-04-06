import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class KeyboardEventData {
  static const alphabetLogicalKey = [
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyB,
    LogicalKeyboardKey.keyC,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.keyF,
    LogicalKeyboardKey.keyG,
    LogicalKeyboardKey.keyH,
    LogicalKeyboardKey.keyI,
    LogicalKeyboardKey.keyJ,
    LogicalKeyboardKey.keyK,
    LogicalKeyboardKey.keyL,
    LogicalKeyboardKey.keyM,
    LogicalKeyboardKey.keyN,
    LogicalKeyboardKey.keyO,
    LogicalKeyboardKey.keyP,
    LogicalKeyboardKey.keyQ,
    LogicalKeyboardKey.keyR,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyT,
    LogicalKeyboardKey.keyU,
    LogicalKeyboardKey.keyV,
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyX,
    LogicalKeyboardKey.keyY,
    LogicalKeyboardKey.keyZ
  ];

  static const numpadLogicalKey = [
    LogicalKeyboardKey.numpad0,
    LogicalKeyboardKey.numpad1,
    LogicalKeyboardKey.numpad2,
    LogicalKeyboardKey.numpad3,
    LogicalKeyboardKey.numpad4,
    LogicalKeyboardKey.numpad5,
    LogicalKeyboardKey.numpad6,
    LogicalKeyboardKey.numpad7,
    LogicalKeyboardKey.numpad8,
    LogicalKeyboardKey.numpad9
  ];

  static const digitLogicalKey = [
    LogicalKeyboardKey.digit0,
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
    LogicalKeyboardKey.digit7,
    LogicalKeyboardKey.digit8,
    LogicalKeyboardKey.digit9
  ];

  static const symbolLogicalKey = [
    LogicalKeyboardKey.backquote, // `
    LogicalKeyboardKey.tilde, //~
    LogicalKeyboardKey.exclamation, // !
    LogicalKeyboardKey.at, // @
    LogicalKeyboardKey.numberSign, // #
    LogicalKeyboardKey.dollar, // $,
    LogicalKeyboardKey.percent, // %
    LogicalKeyboardKey.caret, // ^
    LogicalKeyboardKey.ampersand, // &
    LogicalKeyboardKey.asterisk, //*,
    LogicalKeyboardKey.parenthesisLeft, //(
    LogicalKeyboardKey.parenthesisRight, //(
    LogicalKeyboardKey.minus, //-,
    LogicalKeyboardKey.underscore, //_
    LogicalKeyboardKey.equal, // =
    LogicalKeyboardKey.add, // +,
    LogicalKeyboardKey.bracketLeft, // [
    LogicalKeyboardKey.bracketRight, // ]
    LogicalKeyboardKey.braceLeft, // {
    LogicalKeyboardKey.braceRight, // }
    LogicalKeyboardKey.semicolon, // ;
    LogicalKeyboardKey.colon, // :
    LogicalKeyboardKey.quoteSingle, // '
    LogicalKeyboardKey.quote, // "
    LogicalKeyboardKey.comma, // ,
    LogicalKeyboardKey.less, // <
    LogicalKeyboardKey.period, // .
    LogicalKeyboardKey.greater, // >
    LogicalKeyboardKey.slash, // /
    LogicalKeyboardKey.question, // ?
    LogicalKeyboardKey.backslash, // \
    LogicalKeyboardKey.bar, // |
    LogicalKeyboardKey.numpadDivide,
    LogicalKeyboardKey.numpadMultiply,
    LogicalKeyboardKey.numpadSubtract,
    LogicalKeyboardKey.numpadAdd,
    LogicalKeyboardKey.numpadDecimal,
  ];

  static const numpadActionLogicalKey = [
    LogicalKeyboardKey.numpadDivide,
    LogicalKeyboardKey.numpadMultiply,
    LogicalKeyboardKey.numpadSubtract,
    LogicalKeyboardKey.numpadAdd,
    LogicalKeyboardKey.numpadEnter,
    LogicalKeyboardKey.numpadDecimal,
  ];

  static const actionLogicalKey = [
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.escape,
    LogicalKeyboardKey.backspace,
    LogicalKeyboardKey.delete,
    LogicalKeyboardKey.home,
    LogicalKeyboardKey.end,
    LogicalKeyboardKey.arrowUp,
    LogicalKeyboardKey.arrowDown,
    LogicalKeyboardKey.arrowLeft,
    LogicalKeyboardKey.arrowRight,
    LogicalKeyboardKey.tab,
  ];

  static const commandLogicalKey = [
    LogicalKeyboardKey.capsLock,
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftLeft,
    LogicalKeyboardKey.shiftRight,
    LogicalKeyboardKey.shiftLevel5,
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlLeft,
    LogicalKeyboardKey.controlRight,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altLeft,
    LogicalKeyboardKey.altRight,
  ];

  static const alphabetPhysicalKey = [
    PhysicalKeyboardKey.keyA,
    PhysicalKeyboardKey.keyB,
    PhysicalKeyboardKey.keyC,
    PhysicalKeyboardKey.keyD,
    PhysicalKeyboardKey.keyE,
    PhysicalKeyboardKey.keyF,
    PhysicalKeyboardKey.keyG,
    PhysicalKeyboardKey.keyH,
    PhysicalKeyboardKey.keyI,
    PhysicalKeyboardKey.keyJ,
    PhysicalKeyboardKey.keyK,
    PhysicalKeyboardKey.keyL,
    PhysicalKeyboardKey.keyM,
    PhysicalKeyboardKey.keyN,
    PhysicalKeyboardKey.keyO,
    PhysicalKeyboardKey.keyP,
    PhysicalKeyboardKey.keyQ,
    PhysicalKeyboardKey.keyR,
    PhysicalKeyboardKey.keyS,
    PhysicalKeyboardKey.keyT,
    PhysicalKeyboardKey.keyU,
    PhysicalKeyboardKey.keyV,
    PhysicalKeyboardKey.keyW,
    PhysicalKeyboardKey.keyX,
    PhysicalKeyboardKey.keyY,
    PhysicalKeyboardKey.keyZ
  ];

  static const numpadPhysicalKey = [
    PhysicalKeyboardKey.numpad0,
    PhysicalKeyboardKey.numpad1,
    PhysicalKeyboardKey.numpad2,
    PhysicalKeyboardKey.numpad3,
    PhysicalKeyboardKey.numpad4,
    PhysicalKeyboardKey.numpad5,
    PhysicalKeyboardKey.numpad6,
    PhysicalKeyboardKey.numpad7,
    PhysicalKeyboardKey.numpad8,
    PhysicalKeyboardKey.numpad9
  ];

  static const digitPhysicalKey = [
    PhysicalKeyboardKey.digit0,
    PhysicalKeyboardKey.digit1,
    PhysicalKeyboardKey.digit2,
    PhysicalKeyboardKey.digit3,
    PhysicalKeyboardKey.digit4,
    PhysicalKeyboardKey.digit5,
    PhysicalKeyboardKey.digit6,
    PhysicalKeyboardKey.digit7,
    PhysicalKeyboardKey.digit8,
    PhysicalKeyboardKey.digit9
  ];

  static const symbolPhysicalKey = [
    PhysicalKeyboardKey.backquote, // `
    PhysicalKeyboardKey.minus, //-,
    PhysicalKeyboardKey.equal, // =
    PhysicalKeyboardKey.bracketLeft, // [
    PhysicalKeyboardKey.bracketRight, // ]
    PhysicalKeyboardKey.semicolon, // ;
    PhysicalKeyboardKey.quote, // "
    PhysicalKeyboardKey.comma, // ,
    PhysicalKeyboardKey.period, // .
    PhysicalKeyboardKey.slash, // /
    PhysicalKeyboardKey.backslash, // \
    PhysicalKeyboardKey.numpadDivide,
    PhysicalKeyboardKey.numpadMultiply,
    PhysicalKeyboardKey.numpadSubtract,
    PhysicalKeyboardKey.numpadAdd,
    PhysicalKeyboardKey.numpadDecimal,
  ];

  static const numpadActionPhysicalKey = [
    PhysicalKeyboardKey.numpadDivide,
    PhysicalKeyboardKey.numpadMultiply,
    PhysicalKeyboardKey.numpadSubtract,
    PhysicalKeyboardKey.numpadAdd,
    PhysicalKeyboardKey.numpadEnter,
    PhysicalKeyboardKey.numpadDecimal,
  ];

  static const actionPhysicalKey = [
    PhysicalKeyboardKey.space,
    PhysicalKeyboardKey.escape,
    PhysicalKeyboardKey.backspace,
    PhysicalKeyboardKey.delete,
    PhysicalKeyboardKey.home,
    PhysicalKeyboardKey.end,
    PhysicalKeyboardKey.arrowUp,
    PhysicalKeyboardKey.arrowDown,
    PhysicalKeyboardKey.arrowLeft,
    PhysicalKeyboardKey.arrowRight,
    PhysicalKeyboardKey.tab,
  ];

  static const commandPhysicalKey = [
    PhysicalKeyboardKey.capsLock,
    PhysicalKeyboardKey.shiftLeft,
    PhysicalKeyboardKey.shiftRight,
    PhysicalKeyboardKey.controlLeft,
    PhysicalKeyboardKey.controlRight,
    PhysicalKeyboardKey.altLeft,
    PhysicalKeyboardKey.altRight,
  ];

  late final KeyEvent _keyEvent;

  late bool _isShiftPressed;
  late bool _isControlPressed;
  late bool _isAltPressed;

  late bool _isCapsLockOn;
  late bool _isNumLockOn;
  late bool _isScrollLockOn;

  KeyboardEventData(this._keyEvent) {
    var logicalKeysPressed = HardwareKeyboard.instance.logicalKeysPressed;
    var lockModesEnabled = HardwareKeyboard.instance.lockModesEnabled;

    _isShiftPressed = logicalKeysPressed.contains(LogicalKeyboardKey.shift) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.shiftRight) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.shiftLevel5) ||
        logicalKeysPressed.contains(PhysicalKeyboardKey.shiftLeft) ||
        logicalKeysPressed.contains(PhysicalKeyboardKey.shiftRight);

    _isControlPressed =
        logicalKeysPressed.contains(LogicalKeyboardKey.control) ||
            logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            logicalKeysPressed.contains(LogicalKeyboardKey.controlRight) ||
            logicalKeysPressed.contains(PhysicalKeyboardKey.controlLeft) ||
            logicalKeysPressed.contains(PhysicalKeyboardKey.controlRight);

    _isAltPressed = logicalKeysPressed.contains(LogicalKeyboardKey.alt) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.altRight) ||
        logicalKeysPressed.contains(LogicalKeyboardKey.altRight) ||
        logicalKeysPressed.contains(PhysicalKeyboardKey.altLeft) ||
        logicalKeysPressed.contains(PhysicalKeyboardKey.altRight);

    _isCapsLockOn = lockModesEnabled.contains(KeyboardLockMode.capsLock);
    _isNumLockOn = lockModesEnabled.contains(KeyboardLockMode.numLock);
    _isScrollLockOn = lockModesEnabled.contains(KeyboardLockMode.scrollLock);
  }

  LogicalKeyboardKey get logicalKey => _keyEvent.logicalKey;

  PhysicalKeyboardKey get physicalKey => _keyEvent.physicalKey;

  String? get physicalKeyName => _keyEvent.physicalKey.debugName;

  String? get logicalKeyName => _keyEvent.logicalKey.debugName;

  String get logicalString {
    if (kIsWeb) {
      if (isAlphabet()) {
        if ((isShiftPressed && !isCapsLockOn) ||
            (!isShiftPressed && isCapsLockOn)) {
          return logicalKey.keyLabel.toUpperCase();
        } else {
          return logicalKey.keyLabel.toLowerCase();
        }
      } else {
        return logicalKey.keyLabel;
      }
    } else {
      if (isAlphabet()) {
        if ((isShiftPressed && !isCapsLockOn) ||
            (!isShiftPressed && isCapsLockOn)) {
          return logicalKey.keyLabel.toUpperCase();
        } else {
          return logicalKey.keyLabel.toLowerCase();
        }
      } else if (isSymbol() || isNumber()) {
        //Todo : Flutter has SERIOUS ERROR ON WINDOWS PLATFORM. I hope they will fix it soon. Temporary, I'll hard code manually : (digit 1 -> ! when shift pressed)
        if (isShiftPressed) {
          if (physicalKey == PhysicalKeyboardKey.digit1) {
            return "!";
          } else if (physicalKey == PhysicalKeyboardKey.digit2) {
            return "@";
          } else if (physicalKey == PhysicalKeyboardKey.digit3) {
            return "#";
          } else if (physicalKey == PhysicalKeyboardKey.digit4) {
            return "\$";
          } else if (physicalKey == PhysicalKeyboardKey.digit5) {
            return "%";
          } else if (physicalKey == PhysicalKeyboardKey.digit6) {
            return "^";
          } else if (physicalKey == PhysicalKeyboardKey.digit7) {
            return "&";
          } else if (physicalKey == PhysicalKeyboardKey.digit8) {
            return "*";
          } else if (physicalKey == PhysicalKeyboardKey.digit9) {
            return "(";
          } else if (physicalKey == PhysicalKeyboardKey.digit0) {
            return ")";
          } else if (physicalKey == PhysicalKeyboardKey.backquote) {
            return "~";
          } else if (physicalKey == PhysicalKeyboardKey.minus) {
            return "_";
          } else if (physicalKey == PhysicalKeyboardKey.equal) {
            return "+";
          } else if (physicalKey == PhysicalKeyboardKey.bracketLeft) {
            return "{";
          } else if (physicalKey == PhysicalKeyboardKey.bracketRight) {
            return "}";
          } else if (physicalKey == PhysicalKeyboardKey.semicolon) {
            return ":";
          } else if (physicalKey == PhysicalKeyboardKey.quote) {
            return "\"";
          } else if (physicalKey == PhysicalKeyboardKey.comma) {
            return "<";
          } else if (physicalKey == PhysicalKeyboardKey.period) {
            return ">";
          } else if (physicalKey == PhysicalKeyboardKey.slash) {
            return "?";
          } else if (physicalKey == PhysicalKeyboardKey.backslash) {
            return "|";
          } else {
            return logicalKey.keyLabel;
          }
        } else {
          //shift not pressed
          if (physicalKey == PhysicalKeyboardKey.backquote) {
            return "`";
          } else if (physicalKey == PhysicalKeyboardKey.minus) {
            return "-";
          } else if (physicalKey == PhysicalKeyboardKey.equal) {
            return "=";
          } else if (physicalKey == PhysicalKeyboardKey.bracketLeft) {
            return "[";
          } else if (physicalKey == PhysicalKeyboardKey.bracketRight) {
            return "]";
          } else if (physicalKey == PhysicalKeyboardKey.semicolon) {
            return ";";
          } else if (physicalKey == PhysicalKeyboardKey.quote) {
            return "'";
          } else if (physicalKey == PhysicalKeyboardKey.comma) {
            return ",";
          } else if (physicalKey == PhysicalKeyboardKey.period) {
            return ".";
          } else if (physicalKey == PhysicalKeyboardKey.slash) {
            return "/";
          } else if (physicalKey == PhysicalKeyboardKey.backslash) {
            return "\\";
          } else {
            return logicalKey.keyLabel;
          }
        }
      } else {
        return logicalKey.keyLabel;
      }
    }
  }

  bool isLetter() {
    if (alphabetPhysicalKey.contains(physicalKey) ||
        alphabetLogicalKey.contains(logicalKey) ||
        symbolPhysicalKey.contains(physicalKey) ||
        symbolLogicalKey.contains(logicalKey) ||
        digitPhysicalKey.contains(physicalKey) ||
        digitLogicalKey.contains(logicalKey) ||
        numpadPhysicalKey.contains(physicalKey) ||
        numpadLogicalKey.contains(logicalKey)) {
      return true;
    }
    return false;
  }

  bool isSymbol() {
    if (symbolLogicalKey.contains(logicalKey) ||
        symbolPhysicalKey.contains(physicalKey)) {
      return true;
    }
    return false;
  }

  bool isAlphabet() {
    if (alphabetPhysicalKey.contains(physicalKey) ||
        alphabetLogicalKey.contains(logicalKey)) {
      return true;
    }
    return false;
  }

  bool isAction() {
    if (actionPhysicalKey.contains(physicalKey) ||
        actionLogicalKey.contains(logicalKey)) {
      return true;
    }
    return false;
  }

  bool isNumber() {
    if (digitLogicalKey.contains(logicalKey) ||
        digitPhysicalKey.contains(physicalKey) ||
        numpadLogicalKey.contains(logicalKey) ||
        numpadPhysicalKey.contains(physicalKey)) {
      return true;
    }
    return false;
  }

  bool get isShiftPressed => _isShiftPressed;

  bool get isAltPressed => _isAltPressed;

  bool get isControlPressed => _isControlPressed;

  bool get isCapsLockOn => _isCapsLockOn;

  bool get isNumLockOn => _isNumLockOn;

  bool get isScrollLockOn => _isScrollLockOn;

  @override
  String toString() {
    return "------------------------------------\n" +
        "physicalKeyName : $physicalKeyName\n" +
        "logicalKeyName : $logicalKeyName\n" +
        "logicalString : $logicalString\n" +
        "isLetter : ${isLetter()}\n" +
        "isSymbol : ${isSymbol()}\n" +
        "isAlphabet : ${isAlphabet()}\n" +
        "isAction : ${isAction()}\n" +
        "isNumber : ${isNumber()}\n" +
        "isShiftPressed : $isShiftPressed\n" +
        "isAltPressed : $isAltPressed\n" +
        "isControlPressed : $isControlPressed\n" +
        "isCapsLockOn : $isCapsLockOn\n" +
        "isNumLockOn : $isNumLockOn\n" +
        "isScrollLockOn : $isScrollLockOn\n" +
        "------------------------------------\n";
  }
}
