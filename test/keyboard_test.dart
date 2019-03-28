import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'utils.dart';

main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  ChromeTester chrome = ChromeTester.create('test/data');

  test('Can type into a textarea', () async {
    Tab tab = await chrome.newTab('empty.html');

    var context = await tab.executionContext();

    await context.evaluate('''
var textarea = document.createElement('textarea');
document.body.appendChild(textarea);
textarea.focus();
''');

    var text = 'Hello world. éàê^';

    await tab.keyboard.type(text);
    expect(await context.evaluate('document.querySelector("textarea").value'),
        equals(text));
  });

  test('Press the metaKey', () async {
    Tab tab = await chrome.newTab('empty.html');
    var js = await tab.executionContext();

    await js.evaluate('''
window.keyPromise = new Promise(resolve => document.addEventListener('keydown', event => resolve(event.key)));
false; // Don't wait for the promise here
''');

    await tab.keyboard.press(Key.meta);

    expect(await js.evaluate('keyPromise'), equals('Meta'));
  });

  test('Move with the arrow key', () {

  });

  test('Type emoji', () async {
    Tab tab = await chrome.newTab('keyboard.html');
    await tab.waitUntilNetworkIdle();

    await tab.evaluate('document.querySelector("textarea").focus()');

    String text = '👹 Tokyo street Japan 🇯🇵';
    await tab.keyboard.type(text);

    expect(await tab.evaluate('document.querySelector("textarea").value'), equals(text));
  });
}
