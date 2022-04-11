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
    _animationController.addListener((){
      if(!settingEvent){
        listener();
      }else{
        settingEvent = false;
      }
    });
  }

  void addStatusListener(AnimationStatusListener listener){
    _animationController.addStatusListener((status){
      if(!settingEvent){
        listener(status);
      }else{
        settingEvent = false;
      }
    });
  }

  // void removeListener(VoidCallback listener){
  //   _animationController.removeListener(listener);
  // }
  //
  // void removeStatusListener(AnimationStatusListener listener){
  //   _animationController.removeStatusListener(listener);
  // }

  bool get isAnimating =>
      _tweenAnimation != null && _animationController.isAnimating;

  T get value {
    if (isAnimating) {
      return _tweenAnimation!.value;
    } else {
      return _trueValue;
    }
  }

  bool settingEvent = false;

  set value(T v) {
    if(_trueValue == v){
      return;
    }
    T pre = value;
    _tweenAnimation =
        Tween<T>(begin: pre, end: v).animate(_animationController);

    _trueValue = v;
    settingEvent = true;
    _animationController.reset();
    settingEvent = true;
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
