library charted.core.listenable;

import 'package:flutter/widgets.dart';
import 'dart:async';

class Listenable {
  final Set<VoidCallback> _listeners = new Set<VoidCallback>();

  void addListener(VoidCallback listener) {
    assert(!_listeners.contains(listener));
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    assert(_listeners.contains(listener));
    _listeners.remove(listener);
  }

  void notifyListeners() {
    if (_notificationScheduled)
      return;
    _notificationScheduled = true;
    scheduleMicrotask(_dispatchNotifications);
  }

  bool _notificationScheduled = false;

  void _dispatchNotifications() {
    _notificationScheduled = false;
    List<VoidCallback> localListeners = new List<VoidCallback>.from(_listeners);
    for (VoidCallback listener in localListeners)
      listener();
  }
}
