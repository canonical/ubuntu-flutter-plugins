import 'package:flutter/material.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:yaru/yaru.dart' as yaru;

Future<void> main() async {
  await XdgIcons.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: yaru.lightTheme,
      darkTheme: yaru.darkTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('XDG icons')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const XdgIcon(name: 'computer'),
            const SizedBox(height: 24),
            const XdgIconTheme(
              data: XdgIconThemeData(name: 'Yaru', size: 24),
              child: XdgIcon(name: 'computer'),
            ),
            const SizedBox(height: 24),
            const XdgIconTheme(
              data: XdgIconThemeData(name: 'Adwaita'),
              child: XdgIcon(name: 'computer', size: 48),
            ),
          ],
        ),
      ),
    );
  }
}
