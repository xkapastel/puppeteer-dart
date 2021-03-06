# Puppeteer in Dart

[![Build Status](https://travis-ci.org/xvrh/puppeteer-dart.svg?branch=master)](https://travis-ci.org/xvrh/puppeteer-dart)

A Dart library to automate the Chrome browser over the DevTools Protocol.

This is a port of the [Puppeteer](https://pptr.dev/) Node.JS library in the Dart language.

###### What can I do?

Most things that you can do manually in the browser can be done using Puppeteer! Here are a few examples to get you started:

* Generate screenshots and PDFs of pages.
* Crawl a SPA (Single-Page Application) and generate pre-rendered content (i.e. "SSR" (Server-Side Rendering)).
* Automate form submission, UI testing, keyboard input, etc.
* Create an up-to-date, automated testing environment. Run your tests directly in the latest version of Chrome using the latest JavaScript and browser features.

## Usage
* [Launch chrome](#launch-chrome)
* [Generate a PDF from an HTML page](#generate-a-pdf-from-a-page)
* [Take a screenshot of a page](#take-a-screenshot-of-a-complete-html-page)
* [Take a screenshot of an element in a page](#take-a-screenshot-of-a-specific-node-in-the-page)
* [Create a static version of a Single Page Application](#create-a-static-version-of-a-single-page-application)

### Launch Chrome

Download the last revision of chrome and launch it.
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the `Chrome` process and connect to the DevTools
  // By default it is start in `headless` mode
  var browser = await puppeteer.launch();

  // Open a new tab
  var myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://www.github.com', wait: Until.networkIdle);

  // Do something... See other examples
  await myPage.screenshot();
  await myPage.pdf();
  await myPage.evaluate('() => document.title');

  // Kill the process
  await browser.close();
}
```

### Generate a PDF from a page

```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', wait: Until.networkIdle);

  // Force the "screen" media or some CSS @media print can change the look
  await page.emulateMedia('screen');

  // Capture the PDF and convert it to a List of bytes.
  var pdf = await page.pdf(
      format: PaperFormat.a4, printBackground: true, pageRanges: '1');

  // Save the bytes in a file
  await File('example/_github.pdf').writeAsBytes(pdf);

  await browser.close();
}
```

### Take a screenshot of a complete HTML page

```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  // Setup the dimensions and user-agent of a particular phone
  await page.emulate(puppeteer.devices.pixel2XL);

  await page.goto('https://www.github.com', wait: Until.networkIdle);

  // Take a screenshot of the page
  var screenshot = await page.screenshot();

  // Save it to a file
  await File('example/_github.png').writeAsBytes(screenshot);

  await browser.close();
}
```

### Take a screenshot of a specific node in the page
```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

main() async {
  // Start the browser and go to a web page
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://www.github.com', wait: Until.networkIdle);

  // Select an element on the page
  var form = await page.$('form[action="/join"]');

  // Take a screenshot of the element
  var screenshot = await form.screenshot();

  // Save it to a file
  await File('example/_github_form.png').writeAsBytes(screenshot);

  await browser.close();
}
```

### Interact with the page and scrap content
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  await page.goto('https://developers.google.com/web/');

  // Type into search box.
  await page.type('#searchbox input', 'Headless Chrome');

  // Wait for suggest overlay to appear and click "show all results".
  var allResultsSelector = '.devsite-suggest-all-results';
  await page.waitForSelector(allResultsSelector);
  await page.click(allResultsSelector);

  // Wait for the results page to load and display the results.
  const resultsSelector = '.gsc-results .gsc-thumbnail-inside a.gs-title';
  await page.waitForSelector(resultsSelector);

  // Extract the results from the page.
  var links = await page.evaluate(r'''resultsSelector => {
  const anchors = Array.from(document.querySelectorAll(resultsSelector));
  return anchors.map(anchor => {
    const title = anchor.textContent.split('|')[0].trim();
    return `${title} - ${anchor.href}`;
  });
}''', args: [resultsSelector]);
  print(links.join('\n'));

  await browser.close();
}
```

### Create a static version of a Single Page Application
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();
  await page.goto('https://www.w3.org');

  // Either use the helper to get the content
  var pageContent = await page.content;
  print(pageContent);

  // Or get the content directly by executing some Javascript
  var pageContent2 = await page.evaluate('document.documentElement.outerHTML');
  print(pageContent2);

  await browser.close();
}
```

### Low-level DevTools protocol
This package contains a fully typed API of the [Chrome DevTools protocol](https://chromedevtools.github.io/devtools-protocol/).
The code is generated from the [JSON Schema](https://github.com/ChromeDevTools/devtools-protocol) provided by Chrome.

With this API you have access to the entire capabilities of Chrome DevTools.

The code is in `lib/protocol`
```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  // Create a chrome's tab
  var page = await browser.newPage();

  // You can access the entire Chrome DevTools protocol.
  // This is useful to access information not exposed by the Puppeteer API
  // Be aware that this is a low-level, complex API.
  // Documentation of the protocol: https://chromedevtools.github.io/devtools-protocol/

  // Examples:

  // Access the Animation domain
  await page.devTools.animation.setPlaybackRate(10);

  // Access the CSS domain
  page.devTools.css.onFontsUpdated.listen((_) {});

  // Access the Memory domain
  await page.devTools.memory.getDOMCounters();

  await browser.close();
}
```

### Execute JavaScript code
A lot of the Puppeteer API exposes functions to run some javascript code in the browser.

Example in Node.JS:
```js
test(async () => {
  const result = await page.evaluate(x => {
    return Promise.resolve(8 * x);
  }, 7);
});
```

As of now, in the Dart port, you have to pass the JavaScript code as a string.
The example above is written as:
```dart
main() async {
  var result = await page.evaluate('''x => {
    return Promise.resolve(8 * x);
  }''', args: [7]);
}
```

The javascript code can be:
- A function declaration (in the classical form with the `function` keyword
 or with the shorthand format (`() => `))
- An expression. In which case you cannot pass any arguments to the `evaluate` method.

```dart
import 'package:puppeteer/puppeteer.dart';

main() async {
  var browser = await puppeteer.launch();
  var page = await browser.newPage();

  // function declaration syntax
  await page.evaluate('function(x) { return x > 0; }', args: [7]);

  // shorthand syntax
  await page.evaluate('(x) => x > 0', args: [7]);

  // Multi line shorthand syntax
  await page.evaluate('''(x) => {  
    return x > 0;
  }''', args: [7]);

  // shorthand syntax with async
  await page.evaluate('''async (x) => {
    return await x;
  }''', args: [7]);

  // An expression.
  await page.evaluate('document.body');

  await browser.close();
}
```

If you are using IntellJ (or Webstorm), you can enable syntax highlighting and code-analyzer
for the Javascript snippet with a comment like `// language=js` before the string.

```dart
main() {
  page.evaluate(
  //language=js
  '''function _(x) {
    return x > 0;
  }''', args: [7]);
}
```

Note: In a future version, we can image to compile the dart code to javascript on the fly before 
sending it to the browser (with ddc or dart2js). 

## Related work
 * [chrome-remote-interface](https://github.com/cyrus-and/chrome-remote-interface)
 * [puppeteer](https://github.com/GoogleChrome/puppeteer)
 * [webkit_inspection_protocol](https://github.com/google/webkit_inspection_protocol.dart)
 * [dart webdriver](https://github.com/google/webdriver.dart)
