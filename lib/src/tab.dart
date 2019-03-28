import 'dart:async';

import 'package:chrome_dev_tools/src/js_context.dart';

import '../domains/runtime.dart';
import 'connection.dart';
import 'tab_mixin.dart';
import 'wait_until.dart' as helper;
import 'remote_object.dart' as helper;
import 'keyboard.dart';

export 'keyboard.dart' show Key, KeyLocation;

class Tab extends Object with TabMixin {
  @override
  final Session session;
  Keyboard _keyboard;

  Tab(this.session) {
    _keyboard = Keyboard(input);
  }

  Keyboard get keyboard => _keyboard;

  Future waitUntilNetworkIdle(
          {Duration idleDuration = const Duration(milliseconds: 1000),
          int idleInFlight = 0}) =>
      helper.waitUntilNetworkIdle(network,
          idleDuration: idleDuration, idleInFlight: idleInFlight);

  Future waitUntilConsoleContains(String text) =>
      helper.waitUntilConsoleContains(log, text);

  Future<Map<String, dynamic>> remoteObjectProperties(
          RemoteObject remoteObject) =>
      helper.remoteObjectProperties(runtime, remoteObject);

  Future<dynamic> remoteObject(RemoteObject remoteObject) =>
      helper.remoteObject(runtime, remoteObject);

  Future close() => session.close();

  Future<dynamic> evaluate(String javascriptExpression) async {
    String javascriptFunction = '($javascriptExpression)';

    EvaluateResult result = await runtime.evaluate(javascriptFunction,
        returnByValue: true, userGesture: true, awaitPromise: true);
    RemoteObject object = result.result;

    dynamic value = await remoteObject(object);
    return value;
  }

  Future<ExecutionContext> executionContext() {
    return ExecutionContext.create(this);
  }
}
