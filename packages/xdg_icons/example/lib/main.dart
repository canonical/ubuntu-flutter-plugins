import 'package:flutter/material.dart';
import 'package:xdg_icons/xdg_icons.dart';
import 'package:yaru/yaru.dart';

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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      builder: (context, yaru, child) {
        return MaterialApp(
          theme: yaru.variant?.theme ?? yaruLight,
          darkTheme: yaru.variant?.darkTheme ?? yaruDark,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('XDG icons')),
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
              ],
            ),
            for (final icon in kIcons)
              TableRow(
                children: [
                  Text(icon, style: Theme.of(context).textTheme.bodySmall),
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
