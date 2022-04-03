import 'package:flutter/cupertino.dart';

class AnimatedValue<T> {
  late AnimationController _animationController;
  Animation? _tweenAnimation;
  late T _trueValue;

  AnimatedValue({required T initialValue, required TickerProvider vsync, Duration? duration}) {
    _animationController = AnimationController(vsync: vsync, duration: duration ?? const Duration(milliseconds: 500));
    _trueValue = initialValue;
  }

  void setDuration(Duration duration){
    _animationController.duration = duration;
  }

  void addListener(VoidCallback listener){
    _animationController.addListener(listener);
  }

  void addStatusListener(AnimationStatusListener listener){
    _animationController.addStatusListener(listener);
  }

  void removeListener(VoidCallback listener){
    _animationController.removeListener(listener);
  }

  void removeStatusListener(AnimationStatusListener listener){
    _animationController.removeStatusListener(listener);
  }

  bool get isAnimating =>
      _tweenAnimation != null && _animationController.isAnimating;

  T get value {
    if (isAnimating) {
      return _tweenAnimation!.value;
    } else {
      return _trueValue;
    }
  }

  set value(T v) {
    T pre = value;
    _animationController.reset();
    _tweenAnimation =
        Tween<T>(begin: pre, end: v).animate(_animationController);
    _animationController.forward();
  }

  void setValueAsInitial(T initialValue){
    _animationController.reset();
    _trueValue = initialValue;
  }

  T get trueValue => _trueValue;

  void dispose(){
    _animationController.dispose();
  }
}
