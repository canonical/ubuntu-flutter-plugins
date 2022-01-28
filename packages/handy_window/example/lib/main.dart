import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:handy_window/handy_window.dart';
import 'package:yaru/yaru.dart';

void main() {
  runApp(
    MaterialApp(
      theme: yaruLight,
      darkTheme: yaruDark,
      debugShowCheckedModeBanner: false,
      home: const ExamplePage(),
    ),
  );
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _title = TextEditingController();

  @override
  void initState() {
    super.initState();

    getWindowTitle().then((value) {
      setState(() => _title.text = value);
    });

    onWindowResized((size) => setState(() {}));

    onWindowClosing(() {
      if (isConfirmationDialogVisible(context)) {
        return false;
      }
      return showConfirmationDialog(context);
    });
  }

  Future<void> toggleMinimizedWindow() {
    return isWindowMinimized().then((minimized) {
      return minimizeWindow(!minimized);
    });
  }

  Future<void> toggleMaximizedWindow() {
    return isWindowMaximized().then((maximized) {
      return maximizeWindow(!maximized);
    });
  }

  Future<void> toggleFullscreenWindow() {
    return isWindowFullscreen().then((fullscreen) {
      return setWindowFullscreen(!fullscreen);
    });
  }

  Future<void> toggleWindowClosable() {
    return isWindowClosable().then((closable) {
      return setWindowClosable(!closable).then((_) => setState(() {}));
    });
  }

  Future<void> hideAndShowWindow() {
    return hideWindow().then((_) {
      Timer(const Duration(seconds: 3), showWindow);
    });
  }

  Future<void> setWindowSize({double? width, double? height}) {
    return getWindowSize().then((size) {
      return resizeWindow(Size(width ?? size.width, height ?? size.height));
    });
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Handy Window'),
        actions: [
          TextButton(
            onPressed: toggleMinimizedWindow,
            child: const Text('Minimize'),
          ),
          TextButton(
            onPressed: toggleMaximizedWindow,
            child: const Text('Maximize'),
          ),
          TextButton(
            onPressed: toggleFullscreenWindow,
            child: const Text('Fullscreen'),
          ),
          FutureBuilder(
            future: isWindowClosable(),
            builder: (context, snapshot) {
              return TextButton(
                onPressed: snapshot.data == true ? closeWindow : null,
                child: const Text('Close'),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              onChanged: setWindowTitle,
              onSubmitted: setWindowTitle,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 48),
            FutureBuilder<Size>(
              future: getWindowSize(),
              builder: (context, snapshot) {
                return Row(
                  children: [
                    Expanded(
                      child: SpinBox(
                        min: 320,
                        max: (1 << 32) - 1,
                        enabled: snapshot.hasData,
                        value: snapshot.data?.width ?? 0,
                        decoration: const InputDecoration(labelText: 'Width'),
                        onChanged: (width) => setWindowSize(width: width),
                      ),
                    ),
                    const SizedBox(width: 48),
                    Expanded(
                      child: SpinBox(
                        min: 240,
                        max: (1 << 32) - 1,
                        enabled: snapshot.hasData,
                        value: snapshot.data?.height ?? 0,
                        decoration: const InputDecoration(labelText: 'Height'),
                        onChanged: (height) => setWindowSize(height: height),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FutureBuilder(
        future: Future.wait([
          isWindowFullscreen(),
          isWindowClosable(),
        ]),
        builder: (context, snapshot) {
          return PopupMenuButton<Function>(
            onSelected: (select) => select(),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const ListTile(
                    title: Text('Hide & show'),
                    leading: Icon(Icons.timer_3),
                  ),
                  value: hideAndShowWindow,
                ),
                CheckedPopupMenuItem(
                  enabled: snapshot.hasData,
                  checked: (snapshot.data as List?)?.last ?? false,
                  child: const Text('Is closable'),
                  value: toggleWindowClosable,
                ),
              ];
            },
          );
        },
      ),
    );
  }
}

bool isConfirmationDialogVisible(BuildContext context) {
  return ModalRoute.of(context)?.isCurrent == false;
}

Future<bool?> showConfirmationDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to close the window?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      );
    },
  );
}
