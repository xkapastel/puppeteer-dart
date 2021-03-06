import 'dart:async';
import '../../protocol/network.dart';
import 'frame_manager.dart';
import 'network_manager.dart';

class LifecycleWatcher {
  final FrameManager frameManager;
  final PageFrame frame;
  final Until wait;
  final Duration timeout;
  List<StreamSubscription> _subscriptions;
  LoaderId _initialLoaderId;
  NetworkRequest _navigationRequest;
  final _sameDocumentNavigationCompleter = Completer<Exception>(),
      _lifecycleCompleter = Completer<Exception>(),
      _terminationCompleter = Completer<Exception>(),
      _newDocumentNavigationCompleter = Completer<Exception>();
  Future _timeoutFuture;
  bool _hasSameDocumentNavigation = false;
  Timer _timeoutTimer;

  LifecycleWatcher(this.frameManager, this.frame, {Until wait, this.timeout})
      : wait = wait ?? Until.load {
    _initialLoaderId = frame.loaderId;

    _subscriptions = [
      frameManager.onLifecycleEvent.listen(_checkLifecycleComplete),
      frameManager.onFrameNavigatedWithinDocument
          .listen(_navigatedWithinDocument),
      frameManager.onFrameDetached.listen(_onFrameDetached),
      frameManager.networkManager.onRequest.listen(_onRequest),
    ];

    _timeoutFuture = _createTimeoutFuture();
    _checkLifecycleComplete();
  }

  Future<Exception> get timeoutOrTermination {
    return Future.any([
      _timeoutFuture,
      _terminationCompleter.future,
      frameManager.page.session.closed.then((_) =>
          Exception('Navigation failed because browser has disconnected!'))
    ]);
  }

  Future<Exception> get newDocumentNavigation =>
      _newDocumentNavigationCompleter.future;

  Future<Exception> get sameDocumentNavigation =>
      _sameDocumentNavigationCompleter.future;

  Future<Exception> get lifecycle => _lifecycleCompleter.future;

  NetworkResponse get navigationResponse {
    return _navigationRequest != null ? _navigationRequest.response : null;
  }

  void _onRequest(NetworkRequest request) {
    if (request.frame != frame || !request.isNavigationRequest) {
      return;
    }
    _navigationRequest = request;
  }

  void _onFrameDetached(PageFrame frame) {
    if (this.frame == frame) {
      _terminationCompleter
          .complete(Exception('Navigating frame was detached'));
      return;
    }
    _checkLifecycleComplete();
  }

  Future<Exception> _createTimeoutFuture() {
    if (timeout == null || timeout == Duration.zero) {
      return Completer<Exception>().future;
    }
    var errorMessage =
        'Navigation Timeout Exceeded: ${timeout.inMilliseconds}ms exceeded';
    var completer = Completer<Exception>();
    _timeoutTimer = Timer(
        timeout, () => completer.complete(TimeoutException(errorMessage)));
    return completer.future;
  }

  void _navigatedWithinDocument(PageFrame frame) {
    if (frame != this.frame) return;
    _hasSameDocumentNavigation = true;
    _checkLifecycleComplete();
  }

  void _checkLifecycleComplete([_]) {
    // We expect navigation to commit.
    if (!_checkLifecycle(frame)) return;

    if (!_lifecycleCompleter.isCompleted) {
      _lifecycleCompleter.complete();
    }
    if (frame.loaderId == _initialLoaderId && !_hasSameDocumentNavigation) {
      return;
    }
    if (_hasSameDocumentNavigation) {
      _sameDocumentNavigationCompleter.complete();
    }
    if (frame.loaderId != _initialLoaderId) {
      if (!_newDocumentNavigationCompleter.isCompleted) {
        _newDocumentNavigationCompleter.complete();
      }
    }
  }

  bool _checkLifecycle(PageFrame frame) {
    for (var event in wait._events) {
      if (!frame.lifecycleEvents.contains(event)) return false;
    }
    for (var child in frame.children) {
      if (!_checkLifecycle(child)) return false;
    }
    return true;
  }

  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _timeoutTimer?.cancel();
  }
}

class Until {
  static final load = Until._('load');
  static final domContentLoaded = Until._('DOMContentLoaded');
  static final networkIdle = Until._('networkIdle');
  static final networkAlmostIdle = Until._('networkAlmostIdle');

  final List<String> _events = [];

  Until._(String event) {
    _events.add(event);
  }

  Until._multi(List<Until> waits) {
    for (Until wait in waits) {
      _events.addAll(wait._events);
    }
  }
}
