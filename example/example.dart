import 'package:xdg_icons/xdg_icons.dart';

Future<void> main(List<String> arguments) async {
  print(XdgIcons.extensions); // [png, svg, xpm]

  print(XdgIcons.searchPaths);
  // [/home/jpnurmi/.icons, /usr/share/icons, /usr/share/pixmaps]

  final theme = await XdgIconTheme.fromName('Yaru');
  print(theme.name); // Yaru

  print(await theme.findIcon('computer', 16, 2));
  // XdgIcon(path: /usr/share/icons/Yaru/16x16@2x/devices/computer.png, type: XdgIconType.threshold, size: 16, scale: 2)
}
