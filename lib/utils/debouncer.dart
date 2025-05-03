import 'dart:async';
import 'package:flutter/material.dart';


class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});
  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  dispose() {
    _timer?.cancel();
  }
}
