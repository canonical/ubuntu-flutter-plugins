import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

void main() {
  testWidgets('tap link', (tester) async {
    final actual = <String?>[];
    final expected = <String?>[];

    await tester.pumpWidget(MaterialApp(
      home: Column(
        children: [
          Html(
            data: 'this is the <a href="https://first.link">first</a> link',
            onAnchorTap: (url, attributes, element) => actual.add(url),
          ),
          Html(
            data: 'this is <a href="https://second.link?q">the second</a> link',
            onAnchorTap: (url, attributes, element) => actual.add(url),
          ),
          Html(
            data: 'this is <a href="">the third</a> link',
            onAnchorTap: (url, attributes, element) => actual.add(url),
          ),
        ],
      ),
    ));
    await tester.pump();

    await tester.tapLink('first');
    expect(actual, expected..add('https://first.link'));

    await tester.tapLink('the second');
    expect(actual, expected..add('https://second.link?q'));

    await tester.tapLink('the third');
    expect(actual, expected..add(''));
  });
}
