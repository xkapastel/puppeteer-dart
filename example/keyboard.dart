import 'package:chrome_dev_tools/chrome_dev_tools.dart';
import 'package:chrome_dev_tools/domains/dom.dart';
import 'package:chrome_dev_tools/domains/runtime.dart';

import 'utils.dart';

//http://w3c.github.io/uievents/tools/key-event-viewer
main() async {
  await tabOnPage('html/keyboard.html', (Tab tab) async {
    await tab.waitUntilNetworkIdle();

    Node document = await tab.dom.getDocument();

    NodeId input = await tab.dom.querySelector(document.nodeId, 'input');
    RemoteObject element = await tab.dom.resolveNode(nodeId: input);

    await tab.dom.focus(nodeId: input);

    await tab.keyboard.type("éàê Hello");

    await tab.keyboard.down(Key.shift);
    await tab.keyboard.press(Key.arrowLeft);
    await tab.keyboard.press(Key.arrowLeft);
    await tab.keyboard.press(Key.backspace);
    await tab.keyboard.up(Key.shift);


    var properties = await tab.remoteObjectProperties(element);
    print(properties['value']);

    print(properties);


    // - Ecrire du texte
    // - revenir en arrière et effacer certains mot (flèches + backspace)
    // - Gérer la selection (flèche, ctrl, backspace)
    // - faire les raccourcit clavier


    // Tester les events sur la page: http://w3c.github.io/uievents/tools/key-event-viewer?
  });
}
