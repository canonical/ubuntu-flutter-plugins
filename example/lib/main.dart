import 'package:flutter/material.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:yaru/yaru.dart' as yaru;

void main() {
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
            FutureBuilder(
              future: XdgIconThemeInfo.fromName('Yaru'),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return SizedBox.shrink();
                }
                return XdgIcon(
                  name: 'computer',
                  size: 64,
                  scale: 1,
                  theme: snapshot.data as XdgIconThemeInfo,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
