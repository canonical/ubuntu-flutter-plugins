import 'package:flutter/material.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:yaru/yaru.dart' as yaru;

const kThemes = [null, 'Yaru', 'Adwaita', 'HighContrast'];
const kIcons = [
  'application-x-executable',
  'avatar-default',
  'audio-headphones',
  'computer',
  'distributor-logo',
  'edit-copy',
  'edit-cut',
  'edit-paste',
  'emblem-favorite',
  'folder',
  'input-keyboard',
  'media-removable',
  'network-server',
  'user-trash',
  'zoom-in',
];

void main() => runApp(const MyApp());

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                const SizedBox.shrink(),
                for (final theme in kThemes)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      theme ?? 'Default',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
              ],
            ),
            for (final icon in kIcons)
              TableRow(
                children: [
                  Text(icon, style: Theme.of(context).textTheme.caption),
                  for (final theme in kThemes)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: XdgIcon(name: icon, size: 48, theme: theme),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
