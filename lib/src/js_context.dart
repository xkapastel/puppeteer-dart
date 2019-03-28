import 'dart:async';

import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';
import 'package:chrome_dev_tools/src/remote_object.dart';

import 'tab.dart';

class ExecutionContext {
  final RuntimeApi _runtime;
  final ExecutionContextId _contextId;

  ExecutionContext(this._runtime, this._contextId);

  static Future<ExecutionContext> create(Tab tab) async {
    var executionContext = tab.runtime.onExecutionContextCreated.first;
    await tab.runtime.enable();
    ExecutionContextId contextId = (await executionContext).id;

    return ExecutionContext(tab.runtime, contextId);
  }

  Future evaluate(String javascriptCode) async {
    EvaluateResult result = await _runtime.evaluate(javascriptCode,
        returnByValue: true, userGesture: true, awaitPromise: true);
    RemoteObject object = result.result;

    dynamic value =
        await remoteObject(_runtime, object, executionContextId: _contextId);
    return value;
  }

  // TODO(xha): $eval(selector, javascriptCode)
  // $$eval(selectorAll, javascript pour chaque element)
  // $(selector)
  // $$(selectorAll)

  // ==> renommer les fonctions
}
