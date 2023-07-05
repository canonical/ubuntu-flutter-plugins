import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_test/ubuntu_test.dart';

void main() {
  testWidgets('image asset', (tester) async {
    await tester.pumpWidget(Image.asset('assets/test.png'));
    expect(find.asset('assets/test.png'), findsOneWidget);
    expect(find.asset('assets/nothing.png'), findsNothing);
  });

  testWidgets('svg asset', (tester) async {
    await tester.pumpWidget(SvgPicture.asset('assets/test.svg'));
    expect(find.svg('assets/test.svg'), findsOneWidget);
    expect(find.svg('assets/nothing.svg'), findsNothing);
  });

  testWidgets('html data', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Html(data: '<p>foo</p>')));
    expect(find.html('<p>foo</p>'), findsOneWidget);
    expect(find.html('<p>nothing</p>'), findsNothing);
  });

  testWidgets('markdown data', (tester) async {
    await tester
        .pumpWidget(const MaterialApp(home: MarkdownBody(data: '**foo**')));
    expect(find.markdownBody('**foo**'), findsOneWidget);
    expect(find.markdownBody('**nothing**'), findsNothing);
  });
}
