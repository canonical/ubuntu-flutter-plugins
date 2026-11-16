import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:timezone_map/timezone_map.dart';
import 'package:ubuntu_localizations/ubuntu_localizations.dart';
import 'package:ubuntu_test/ubuntu_test.dart';
import 'package:ubuntu_widgets/ubuntu_widgets.dart';
import 'package:wizard_router/wizard_router.dart';
import 'package:yaru/yaru.dart';

void main() {
  testWidgets('Yaru application selects a menu and navigates to the map', (
    tester,
  ) async {
    String? selected;
    LatLng? pressed;
    await tester.pumpWidget(
      MaterialApp(
        theme: yaruLight,
        localizationsDelegates: const [
          ...GlobalUbuntuLocalizations.delegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: UbuntuLocalizations.supportedLocales,
        home: Wizard(
          routes: {
            '/first': WizardRoute(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    MenuButtonBuilder<String>(
                      values: const ['first', 'second'],
                      itemBuilder: (_, value, _) => Text(value),
                      onSelected: (value) => selected = value,
                      style: OutlinedButton.styleFrom(),
                      menuStyle: const MenuStyle(),
                    ),
                    PushButton.filled(
                      style: FilledButton.styleFrom(),
                      onPressed: () => Wizard.of(context).next(),
                      child: Text(UbuntuLocalizations.of(context).nextLabel),
                    ),
                  ],
                ),
              ),
            ),
            '/map': WizardRoute(
              builder: (_) => Scaffold(
                body: SizedBox(
                  width: 400,
                  height: 200,
                  child: TimezoneMap(
                    marker: const LatLng(0, 0),
                    onPressed: (value) => pressed = value,
                  ),
                ),
              ),
            ),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('second').last);
    await tester.pumpAndSettle();
    expect(selected, 'second');
    await tester.tapNext();
    await tester.pumpAndSettle();
    expect(find.byType(TimezoneMap), findsOneWidget);
    await tester.tap(find.byType(TimezoneMap));
    expect(pressed, isNotNull);
    expect(find.byIcon(Icons.place), findsOneWidget);
  });
}
